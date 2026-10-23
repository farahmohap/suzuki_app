import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../profile/presentation/cubit/profile_cubit.dart' show LoadStatus;
import '../../data/models/onboarding_models.dart';
import '../../data/repositories/driver_onboarding_repository.dart';

class DriverStatusState extends Equatable {
  const DriverStatusState({
    this.status = LoadStatus.initial,
    this.info,
    this.error,
    this.replacing = const {},
  });

  final LoadStatus status;
  final VerificationInfo? info;
  final String? error;

  /// Document types currently being re-uploaded.
  final Set<DocType> replacing;

  DriverStatusState copyWith({
    LoadStatus? status,
    VerificationInfo? info,
    String? error,
    bool clearError = false,
    Set<DocType>? replacing,
  }) =>
      DriverStatusState(
        status: status ?? this.status,
        info: info ?? this.info,
        error: clearError ? null : (error ?? this.error),
        replacing: replacing ?? this.replacing,
      );

  @override
  List<Object?> get props => [status, info, error, replacing];
}

/// Verification status screen (pending / rejected / approved / suspended).
@injectable
class DriverStatusCubit extends Cubit<DriverStatusState> {
  DriverStatusCubit(this._repo) : super(const DriverStatusState());

  final DriverOnboardingRepository _repo;

  Future<void> load() async {
    // Keep the old info on screen while refreshing.
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    final r = await _repo.getStatus();
    r.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, error: f.message)),
      (info) => emit(state.copyWith(status: LoadStatus.success, info: info)),
    );
  }

  /// Re-uploads a rejected document, then reloads the status.
  Future<void> replaceDocument(DocType type, String path) async {
    emit(state.copyWith(replacing: {...state.replacing, type}, clearError: true));
    final up = await _repo.uploadFile(path: path, kind: type.apiKey);
    await up.fold(
      (f) async => emit(state.copyWith(
        error: f.message,
        replacing: {...state.replacing}..remove(type),
      )),
      (key) async {
        final r = await _repo.replaceDocument(type, key);
        r.fold(
          (f) => emit(state.copyWith(error: f.message)),
          (_) {},
        );
        emit(state.copyWith(replacing: {...state.replacing}..remove(type)));
        await load();
      },
    );
  }
}
