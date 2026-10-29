import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../profile/data/models/profile_models.dart';
import '../../data/models/onboarding_models.dart';
import '../../data/repositories/driver_onboarding_repository.dart';

enum DocUploadStatus { empty, uploading, uploaded, failed }

class DocSlot extends Equatable {
  const DocSlot({
    this.status = DocUploadStatus.empty,
    this.localPath,
    this.progress = 0,
  });

  final DocUploadStatus status;
  final String? localPath;
  final double progress;

  DocSlot copyWith({
    DocUploadStatus? status,
    String? localPath,
    double? progress,
  }) =>
      DocSlot(
        status: status ?? this.status,
        localPath: localPath ?? this.localPath,
        progress: progress ?? this.progress,
      );

  @override
  List<Object?> get props => [status, localPath, progress];
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = 0,
    this.busy = false,
    this.error,
    this.avatarPath,
    this.docs = const {},
    this.submitted = false,
  });

  /// 0 = personal, 1 = vehicle, 2 = documents.
  final int step;
  final bool busy;
  final String? error;
  final String? avatarPath;
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
    String? avatarPath,
    Map<DocType, DocSlot>? docs,
    bool? submitted,
  }) =>
      OnboardingState(
        step: step ?? this.step,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
        avatarPath: avatarPath ?? this.avatarPath,
        docs: docs ?? this.docs,
        submitted: submitted ?? this.submitted,
      );

  @override
  List<Object?> get props => [
        step,
        busy,
        error,
        avatarPath,
        docs,
        submitted,
      ];
}

/// Drives the 3-step driver registration wizard.
@injectable
class DriverOnboardingCubit extends Cubit<OnboardingState> {
  DriverOnboardingCubit(this._repo) : super(const OnboardingState());

  final DriverOnboardingRepository _repo;

  /// Resumes at the first incomplete step reported by the backend.
  Future<void> init() async {
    final status = await _repo.getStatus();
    status.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (info) => emit(state.copyWith(step: info.nextStepIndex)),
    );
  }

  void back() {
    if (state.step > 0) emit(state.copyWith(step: state.step - 1, clearError: true));
  }

  void setAvatar(String path) =>
      emit(state.copyWith(avatarPath: path));

  /// Step 1: sends personal details and the avatar as multipart form data.
  Future<void> savePersonal({
    required String fullName,
    required String nationalId,
    required DateTime birthDate,
    required Gender gender,
  }) async {
    final path = state.avatarPath;
    if (path == null) {
      emit(state.copyWith(error: 'الصورة الشخصية مطلوبة'));
      return;
    }
    emit(state.copyWith(busy: true, clearError: true));

    final r = await _repo.saveStep1(PersonalInput(
      fullName: fullName,
      nationalId: nationalId,
      birthDate: birthDate,
      gender: gender,
      avatarPath: path,
    ));
    r.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (_) => emit(state.copyWith(
        busy: false,
        step: 1,
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

  /// Step 3: keeps selected files locally; they are sent together on submit.
  Future<void> uploadDocument(DocType type, String path) async {
    _setSlot(
      type,
      DocSlot(
        status: DocUploadStatus.uploaded,
        localPath: path,
        progress: 1,
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
    final filePaths = {
      for (final t in DocType.values) t: state.slot(t).localPath!,
    };
    final r = await _repo.saveDocumentsAndSubmit(filePaths);
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
