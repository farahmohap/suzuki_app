import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../profile/data/models/profile_models.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/models/onboarding_models.dart';
import '../../data/repositories/driver_onboarding_repository.dart';

enum DocUploadStatus { empty, uploading, uploaded, failed }

class DocSlot extends Equatable {
  const DocSlot({
    this.status = DocUploadStatus.empty,
    this.localPath,
    this.fileKey,
    this.progress = 0,
  });

  final DocUploadStatus status;
  final String? localPath;
  final String? fileKey;
  final double progress;

  DocSlot copyWith({
    DocUploadStatus? status,
    String? localPath,
    String? fileKey,
    double? progress,
  }) =>
      DocSlot(
        status: status ?? this.status,
        localPath: localPath ?? this.localPath,
        fileKey: fileKey ?? this.fileKey,
        progress: progress ?? this.progress,
      );

  @override
  List<Object?> get props => [status, localPath, fileKey, progress];
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = 0,
    this.busy = false,
    this.error,
    this.districts = const [],
    this.avatarPath,
    this.avatarKey,
    this.docs = const {},
    this.submitted = false,
  });

  /// 0 = personal, 1 = vehicle, 2 = documents.
  final int step;
  final bool busy;
  final String? error;
  final List<DistrictModel> districts;
  final String? avatarPath;
  final String? avatarKey;
  final Map<DocType, DocSlot> docs;

  /// Application submitted; the screen should refresh the user.
  final bool submitted;

  DocSlot slot(DocType t) => docs[t] ?? const DocSlot();

  bool get allDocsUploaded => DocType.values
      .every((t) => slot(t).status == DocUploadStatus.uploaded);

  bool get anyUploading =>
      docs.values.any((d) => d.status == DocUploadStatus.uploading);

  OnboardingState copyWith({
    int? step,
    bool? busy,
    String? error,
    bool clearError = false,
    List<DistrictModel>? districts,
    String? avatarPath,
    String? avatarKey,
    Map<DocType, DocSlot>? docs,
    bool? submitted,
  }) =>
      OnboardingState(
        step: step ?? this.step,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
        districts: districts ?? this.districts,
        avatarPath: avatarPath ?? this.avatarPath,
        avatarKey: avatarKey ?? this.avatarKey,
        docs: docs ?? this.docs,
        submitted: submitted ?? this.submitted,
      );

  @override
  List<Object?> get props => [
        step,
        busy,
        error,
        districts,
        avatarPath,
        avatarKey,
        docs,
        submitted,
      ];
}

/// Drives the 3-step driver registration wizard.
@injectable
class DriverOnboardingCubit extends Cubit<OnboardingState> {
  DriverOnboardingCubit(this._repo, this._profileRepo)
      : super(const OnboardingState());

  final DriverOnboardingRepository _repo;
  final ProfileRepository _profileRepo;

  /// Loads districts and resumes at the step the backend says is next.
  Future<void> init() async {
    final districts = await _profileRepo.getDistricts();
    districts.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (list) => emit(state.copyWith(districts: list, clearError: true)),
    );
    final status = await _repo.getStatus();
    status.fold((_) {}, (info) {
      final step = (info.onboardingStep - 1).clamp(0, 2);
      emit(state.copyWith(step: step));
    });
  }

  void back() {
    if (state.step > 0) emit(state.copyWith(step: state.step - 1, clearError: true));
  }

  void setAvatar(String path) =>
      emit(state.copyWith(avatarPath: path, avatarKey: ''));

  /// Step 1: uploads the avatar (if a new one was chosen) then saves.
  Future<void> savePersonal({
    required String fullName,
    required String nationalId,
    required DateTime birthDate,
    required String districtId,
  }) async {
    emit(state.copyWith(busy: true, clearError: true));

    String? avatarKey = state.avatarKey;
    final path = state.avatarPath;
    if (path != null && (avatarKey == null || avatarKey.isEmpty)) {
      final up = await _repo.uploadFile(path: path, kind: 'avatar');
      final uploadError = up.fold<String?>((f) => f.message, (_) => null);
      if (uploadError != null) {
        emit(state.copyWith(busy: false, error: uploadError));
        return;
      }
      avatarKey = up.fold<String?>((_) => null, (key) => key);
    }
    final String? cleanKey =
        (avatarKey == null || avatarKey.isEmpty) ? null : avatarKey;

    final r = await _repo.saveStep1(PersonalInput(
      fullName: fullName,
      nationalId: nationalId,
      birthDate: birthDate,
      districtId: districtId,
      avatarKey: cleanKey,
    ));
    r.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (_) => emit(state.copyWith(
        busy: false,
        step: 1,
        avatarKey: cleanKey,
      )),
    );
  }

  /// Step 2: vehicle and plate.
  Future<void> saveVehicle(VehicleInput input) async {
    emit(state.copyWith(busy: true, clearError: true));
    final r = await _repo.saveStep2(input);
    r.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (_) => emit(state.copyWith(busy: false, step: 2)),
    );
  }

  /// Step 3: picks one file and uploads it with progress.
  Future<void> uploadDocument(DocType type, String path) async {
    _setSlot(type, DocSlot(status: DocUploadStatus.uploading, localPath: path));
    final r = await _repo.uploadFile(
      path: path,
      kind: type.apiKey,
      onProgress: (p) => _setSlot(
        type,
        state.slot(type).copyWith(
              status: DocUploadStatus.uploading,
              progress: p,
            ),
      ),
    );
    r.fold(
      (f) {
        _setSlot(
          type,
          DocSlot(status: DocUploadStatus.failed, localPath: path),
        );
        emit(state.copyWith(error: f.message));
      },
      (key) => _setSlot(
        type,
        DocSlot(
          status: DocUploadStatus.uploaded,
          localPath: path,
          fileKey: key,
          progress: 1,
        ),
      ),
    );
  }

  void removeDocument(DocType type) {
    final docs = Map<DocType, DocSlot>.from(state.docs)..remove(type);
    emit(state.copyWith(docs: docs));
  }

  /// Saves step 3 and submits the application.
  Future<void> submit() async {
    if (!state.allDocsUploaded) {
      emit(state.copyWith(error: 'ارفع كل المستندات والصور أولًا'));
      return;
    }
    emit(state.copyWith(busy: true, clearError: true));
    final keys = {
      for (final t in DocType.values) t: state.slot(t).fileKey!,
    };
    final r = await _repo.saveDocumentsAndSubmit(keys);
    r.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (_) => emit(state.copyWith(busy: false, submitted: true)),
    );
  }

  void _setSlot(DocType type, DocSlot slot) {
    final docs = Map<DocType, DocSlot>.from(state.docs)..[type] = slot;
    emit(state.copyWith(docs: docs));
  }
}
