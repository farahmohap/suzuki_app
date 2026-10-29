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
    late final VerificationInfo statusInfo;

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
        statusInfo = info as VerificationInfo;
        return true;
      },
    );
    if (!sFold) return;

    // Prepopulate any already-uploaded documents reported by backend
    final Map<DocType, DocSlot> docs = {};
    for (final doc in statusInfo.documents) {
      if (doc.status == 'uploaded' || doc.status == 'approved') {
        docs[doc.type] = const DocSlot(
          status: DocUploadStatus.uploaded,
          localPath: 'existing',
          progress: 1,
        );
      }
    }

    emit(DriverOnboardingLoadedState(
      step: statusInfo.nextStepIndex,
      districts: districts,
      docs: docs,
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

  void _setSlot(DocType type, DocSlot slot) {
    final data = _loaded;
    if (data == null) return;
    final docs = Map<DocType, DocSlot>.from(data.docs)..[type] = slot;
    emit(data.copyWith(docs: docs));
  }

  // ── Step 1 ──────────────────────────────────────────────────────────────

  /// Sends Step 1 personal details and avatar file directly via multipart form data.
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
    if (path == null || path.isEmpty) {
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
      (stepResponse) {
        final nextStep = stepResponse.nextStepIndex > 0
            ? stepResponse.nextStepIndex
            : 1;
        final next = data.copyWith(step: nextStep);
        emit(DriverOnboardingSavePersonalSuccessState(
          data: next,
          response: stepResponse,
        ));
        emit(next);
      },
    );
  }

  // ── Step 2 ──────────────────────────────────────────────────────────────

  /// Vehicle and plate.
  Future<void> saveVehicle(VehicleInput input) async {
    final data = _loaded;
    if (data == null) return;

    const vehicleDocumentTypes = [
      DocType.vehicleFront,
      DocType.vehicleRear,
      DocType.vehicleInterior,
    ];
    final missing = vehicleDocumentTypes.where((type) {
      final slot = data.slot(type);
      return !slot.isUploaded || slot.localPath == 'existing';
    }).toList();
    if (missing.isNotEmpty) {
      emit(DriverOnboardingSaveVehicleFailureState(
        errorMessage:
            'ارفع صور السيارة المطلوبة أولًا (${missing.map((type) => type.labelAr).join('، ')})',
        data: data,
      ));
      return;
    }

    final request = VehicleInput(
      plateNumbers: input.plateNumbers,
      plateLetters: input.plateLetters,
      model: input.model,
      color: input.color,
      documents: [
        for (final type in vehicleDocumentTypes)
          DriverDocumentInput(
            type: type.apiKey,
            filePath: data.slot(type).localPath!,
          ),
      ],
    );

    emit(DriverOnboardingSaveVehicleLoadingState(data: data));

    final r = await _repo.saveStep2(request);
    r.fold(
      (f) => emit(DriverOnboardingSaveVehicleFailureState(
        errorMessage: f.message,
        data: data,
      )),
      (stepResponse) {
        final nextStep = stepResponse.nextStepIndex > 1
            ? stepResponse.nextStepIndex
            : 2;
        final next = data.copyWith(step: nextStep);
        emit(DriverOnboardingSaveVehicleSuccessState(
          data: next,
          response: stepResponse,
        ));
        emit(next);
      },
    );
  }

  // ── Step 3 ──────────────────────────────────────────────────────────────

  /// Records picked document locally; files are sent directly upon submit.
  void uploadDocument(DocType type, String path) {
    final data = _loaded;
    if (data == null) return;

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
    final data = _loaded;
    if (data == null) return;

    final docs = Map<DocType, DocSlot>.from(data.docs)..remove(type);
    emit(data.copyWith(docs: docs));
  }

  /// Sends step 3 documents directly and submits the application.
  Future<void> submit() async {
    final data = _loaded;
    if (data == null) return;

    const step3DocumentTypes = [
      DocType.nationalIdFront,
      DocType.nationalIdBack,
      DocType.drivingLicense,
      DocType.vehicleLicense,
      DocType.criminalRecord,
    ];
    final missing =
        step3DocumentTypes.where((t) => !data.slot(t).isUploaded).toList();
    if (missing.isNotEmpty) {
      emit(DriverOnboardingSubmitFailureState(
        errorMessage:
            'ارفع كل المستندات والصور المطلوبة أولًا (${missing.map((e) => e.labelAr).join("، ")})',
        data: data,
      ));
      return;
    }

    emit(DriverOnboardingSubmitLoadingState(data: data));

    final filePaths = {
      for (final t in step3DocumentTypes) t: data.slot(t).localPath!,
    };

    final r = await _repo.saveDocumentsAndSubmit(filePaths);
    r.fold(
      (f) => emit(DriverOnboardingSubmitFailureState(
        errorMessage: f.message,
        data: data,
      )),
      (stepResponse) => emit(DriverOnboardingSubmitSuccessState(
        response: stepResponse,
      )),
    );
  }
}
