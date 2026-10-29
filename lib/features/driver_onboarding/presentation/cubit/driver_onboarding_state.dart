import 'package:equatable/equatable.dart';

import '../../../profile/data/models/profile_models.dart';
import '../../data/models/onboarding_models.dart';

// ---------------------------------------------------------------------------
// Document slot
// ---------------------------------------------------------------------------

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

  bool get isUploaded =>
      status == DocUploadStatus.uploaded && localPath != null;

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

// ---------------------------------------------------------------------------
// Base state
// ---------------------------------------------------------------------------

class DriverOnboardingState extends Equatable {
  const DriverOnboardingState();

  @override
  List<Object?> get props => [];
}

// ---------------------------------------------------------------------------
// Init / Districts
// ---------------------------------------------------------------------------

class DriverOnboardingInitialState extends DriverOnboardingState {
  const DriverOnboardingInitialState();
}

class DriverOnboardingLoadingState extends DriverOnboardingState {
  const DriverOnboardingLoadingState();
}

/// Wizard loaded — holds all mutable wizard data.
class DriverOnboardingLoadedState extends DriverOnboardingState {
  const DriverOnboardingLoadedState({
    required this.step,
    required this.districts,
    this.avatarPath,
    this.docs = const {},
  });

  /// 0 = personal, 1 = vehicle, 2 = documents.
  final int step;
  final List<DistrictModel> districts;
  final String? avatarPath;
  final Map<DocType, DocSlot> docs;

  DocSlot slot(DocType t) => docs[t] ?? const DocSlot();

  bool get allDocsUploaded =>
      DocType.values.every((t) => slot(t).isUploaded);

  bool get anyUploading =>
      docs.values.any((d) => d.status == DocUploadStatus.uploading);

  DriverOnboardingLoadedState copyWith({
    int? step,
    List<DistrictModel>? districts,
    String? avatarPath,
    Map<DocType, DocSlot>? docs,
  }) =>
      DriverOnboardingLoadedState(
        step: step ?? this.step,
        districts: districts ?? this.districts,
        avatarPath: avatarPath ?? this.avatarPath,
        docs: docs ?? this.docs,
      );

  @override
  List<Object?> get props => [step, districts, avatarPath, docs];
}

class DriverOnboardingLoadFailureState extends DriverOnboardingState {
  final String errorMessage;
  const DriverOnboardingLoadFailureState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ---------------------------------------------------------------------------
// Step 1 — Personal
// ---------------------------------------------------------------------------

class DriverOnboardingSavePersonalLoadingState extends DriverOnboardingState {
  final DriverOnboardingLoadedState data;
  const DriverOnboardingSavePersonalLoadingState({required this.data});

  @override
  List<Object?> get props => [data];
}

class DriverOnboardingSavePersonalSuccessState extends DriverOnboardingState {
  final DriverOnboardingLoadedState data;
  final DriverStepResponse response;
  const DriverOnboardingSavePersonalSuccessState({
    required this.data,
    required this.response,
  });

  @override
  List<Object?> get props => [data, response];
}

class DriverOnboardingSavePersonalFailureState extends DriverOnboardingState {
  final String errorMessage;
  final DriverOnboardingLoadedState data;
  const DriverOnboardingSavePersonalFailureState({
    required this.errorMessage,
    required this.data,
  });

  @override
  List<Object?> get props => [errorMessage, data];
}

// ---------------------------------------------------------------------------
// Step 2 — Vehicle
// ---------------------------------------------------------------------------

class DriverOnboardingSaveVehicleLoadingState extends DriverOnboardingState {
  final DriverOnboardingLoadedState data;
  const DriverOnboardingSaveVehicleLoadingState({required this.data});

  @override
  List<Object?> get props => [data];
}

class DriverOnboardingSaveVehicleSuccessState extends DriverOnboardingState {
  final DriverOnboardingLoadedState data;
  final DriverStepResponse response;
  const DriverOnboardingSaveVehicleSuccessState({
    required this.data,
    required this.response,
  });

  @override
  List<Object?> get props => [data, response];
}

class DriverOnboardingSaveVehicleFailureState extends DriverOnboardingState {
  final String errorMessage;
  final DriverOnboardingLoadedState data;
  const DriverOnboardingSaveVehicleFailureState({
    required this.errorMessage,
    required this.data,
  });

  @override
  List<Object?> get props => [errorMessage, data];
}

// ---------------------------------------------------------------------------
// Step 3 — Submit
// ---------------------------------------------------------------------------

class DriverOnboardingSubmitLoadingState extends DriverOnboardingState {
  final DriverOnboardingLoadedState data;
  const DriverOnboardingSubmitLoadingState({required this.data});

  @override
  List<Object?> get props => [data];
}

class DriverOnboardingSubmitSuccessState extends DriverOnboardingState {
  final DriverStepResponse? response;
  const DriverOnboardingSubmitSuccessState({this.response});

  @override
  List<Object?> get props => [response];
}

class DriverOnboardingSubmitFailureState extends DriverOnboardingState {
  final String errorMessage;
  final DriverOnboardingLoadedState data;
  const DriverOnboardingSubmitFailureState({
    required this.errorMessage,
    required this.data,
  });

  @override
  List<Object?> get props => [errorMessage, data];
}
