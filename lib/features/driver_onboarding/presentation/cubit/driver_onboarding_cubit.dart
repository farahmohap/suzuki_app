import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../profile/data/models/profile_models.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/models/onboarding_models.dart';
import '../../data/repositories/driver_onboarding_repository.dart';
import 'driver_onboarding_state.dart';

export 'driver_onboarding_state.dart';

/// Drives the 3-step driver registration wizard.
@injectable
class DriverOnboardingCubit extends Cubit<DriverOnboardingState> {
  DriverOnboardingCubit(this._repo, this._profileRepo)
      : super(const DriverOnboardingInitialState());

  final DriverOnboardingRepository _repo;
  final ProfileRepository _profileRepo;

  // ── helpers ──────────────────────────────────────────────────────────────

  DriverOnboardingLoadedState? get _loaded {
    final s = state;
    if (s is DriverOnboardingLoadedState) return s;
    if (s is DriverOnboardingSavePersonalLoadingState) return s.data;
    if (s is DriverOnboardingSavePersonalFailureState) return s.data;
    if (s is DriverOnboardingSavePersonalSuccessState) return s.data;
    if (s is DriverOnboardingSaveVehicleLoadingState) return s.data;
    if (s is DriverOnboardingSaveVehicleFailureState) return s.data;
    if (s is DriverOnboardingSaveVehicleSuccessState) return s.data;
    if (s is DriverOnboardingSubmitLoadingState) return s.data;
    if (s is DriverOnboardingSubmitFailureState) return s.data;
    return null;
  }

  // ── init ─────────────────────────────────────────────────────────────────

  /// Loads districts + resumes at the first incomplete step reported by the
  /// backend.
  Future<void> init() async {
    emit(const DriverOnboardingLoadingState());

    // Load districts and onboarding status in parallel.
    final results = await Future.wait([
      _profileRepo.getDistricts(),
      _repo.getStatus(),
    ]);

    final districtsResult = results[0];
    final statusResult = results[1];

    late final List<DistrictModel> districts;
    late final int step;

    // Districts
    final dFold = districtsResult.fold(
      (f) {
        emit(DriverOnboardingLoadFailureState(errorMessage: f.message));
        return false;
      },
      (list) {
        districts = list as List<DistrictModel>;
        return true;
      },
    );
    if (!dFold) return;

    // Status
    final sFold = statusResult.fold(
      (f) {
        emit(DriverOnboardingLoadFailureState(errorMessage: f.message));
        return false;
      },
      (info) {
        step = (info as VerificationInfo).nextStepIndex;
        return true;
      },
    );
    if (!sFold) return;

    emit(DriverOnboardingLoadedState(
      step: step,
      districts: districts,
    ));
  }

  // ── navigation ──────────────────────────────────────────────────────────

  void back() {
    final data = _loaded;
    if (data == null || data.step <= 0) return;
    emit(data.copyWith(step: data.step - 1));
  }

  void setAvatar(String path) {
    final data = _loaded;
    if (data == null) return;
    emit(data.copyWith(avatarPath: path));
  }

  // ── Step 1 ──────────────────────────────────────────────────────────────

  /// Sends personal details + avatar as multipart form data.
  Future<void> savePersonal({
    required String fullName,
    required String nationalId,
    required DateTime birthDate,
    required Gender gender,
    required int districtId,
  }) async {
    final data = _loaded;
    if (data == null) return;

    final path = data.avatarPath;
    if (path == null) {
      emit(DriverOnboardingSavePersonalFailureState(
        errorMessage: 'الصورة الشخصية مطلوبة',
        data: data,
      ));
      return;
    }

    emit(DriverOnboardingSavePersonalLoadingState(data: data));

    final r = await _repo.saveStep1(PersonalInput(
      fullName: fullName,
      nationalId: nationalId,
      birthDate: birthDate,
      gender: gender,
      avatarPath: path,
      districtId: districtId,
    ));

    r.fold(
      (f) => emit(DriverOnboardingSavePersonalFailureState(
        errorMessage: f.message,
        data: data,
      )),
      (_) {
        final next = data.copyWith(step: 1);
        emit(DriverOnboardingSavePersonalSuccessState(data: next));
        emit(next);
      },
    );
  }

  // ── Step 2 ──────────────────────────────────────────────────────────────

  /// Vehicle and plate.
  Future<void> saveVehicle(VehicleInput input) async {
    final data = _loaded;
    if (data == null) return;

    emit(DriverOnboardingSaveVehicleLoadingState(data: data));

    final r = await _repo.saveStep2(input);
    r.fold(
      (f) => emit(DriverOnboardingSaveVehicleFailureState(
        errorMessage: f.message,
        data: data,
      )),
      (_) {
        final next = data.copyWith(step: 2);
        emit(DriverOnboardingSaveVehicleSuccessState(data: next));
        emit(next);
      },
    );
  }

  // ── Step 3 ──────────────────────────────────────────────────────────────

  /// Keeps selected files locally; they are sent together on submit.
  Future<void> uploadDocument(DocType type, String path) async {
    final data = _loaded;
    if (data == null) return;

    final docs = Map<DocType, DocSlot>.from(data.docs)
      ..[type] = DocSlot(
        status: DocUploadStatus.uploaded,
        localPath: path,
        progress: 1,
      );
    emit(data.copyWith(docs: docs));
  }

  void removeDocument(DocType type) {
    final data = _loaded;
    if (data == null) return;

    final docs = Map<DocType, DocSlot>.from(data.docs)..remove(type);
    emit(data.copyWith(docs: docs));
  }

  /// Saves step 3 and submits the application.
  Future<void> submit() async {
    final data = _loaded;
    if (data == null) return;

    if (!data.allDocsUploaded) {
      emit(DriverOnboardingSubmitFailureState(
        errorMessage: 'ارفع كل المستندات والصور أولًا',
        data: data,
      ));
      return;
    }

    emit(DriverOnboardingSubmitLoadingState(data: data));

    final filePaths = {
      for (final t in DocType.values) t: data.slot(t).localPath!,
    };

    final r = await _repo.saveDocumentsAndSubmit(filePaths);
    r.fold(
      (f) => emit(DriverOnboardingSubmitFailureState(
        errorMessage: f.message,
        data: data,
      )),
      (_) => emit(const DriverOnboardingSubmitSuccessState()),
    );
  }
}
