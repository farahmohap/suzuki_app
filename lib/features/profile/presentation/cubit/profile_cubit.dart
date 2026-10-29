import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failures.dart';
import '../../../auth/data/models/auth_model.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';

enum LoadStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.districtsStatus = LoadStatus.initial,
    this.districts = const [],
    this.saveStatus = LoadStatus.initial,
    this.savedUser,
    this.error,
    this.fieldErrors = const {},
  });

  final LoadStatus districtsStatus;
  final List<DistrictModel> districts;
  final LoadStatus saveStatus;

  /// Set when [saveStatus] is success.
  final AuthModel? savedUser;
  final String? error;

  /// Per-field messages returned by the backend (`error.fields`).
  final Map<String, String> fieldErrors;

  ProfileState copyWith({
    LoadStatus? districtsStatus,
    List<DistrictModel>? districts,
    LoadStatus? saveStatus,
    AuthModel? savedUser,
    String? error,
    Map<String, String>? fieldErrors,
  }) =>
      ProfileState(
        districtsStatus: districtsStatus ?? this.districtsStatus,
        districts: districts ?? this.districts,
        saveStatus: saveStatus ?? this.saveStatus,
        savedUser: savedUser ?? this.savedUser,
        error: error,
        fieldErrors: fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props => [
        districtsStatus,
        districts,
        saveStatus,
        savedUser,
        error,
        fieldErrors,
      ];
}

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileState());

  final ProfileRepository _repo;

  Future<void> loadDistricts() async {
    emit(state.copyWith(districtsStatus: LoadStatus.loading));
    final r = await _repo.getDistricts();
    r.fold(
      (f) => emit(state.copyWith(
        districtsStatus: LoadStatus.failure,
        error: f.message,
      )),
      (list) => emit(state.copyWith(
        districtsStatus: LoadStatus.success,
        districts: list,
      )),
    );
  }

  Future<void> savePassengerProfile(PassengerProfileInput input) async {
    emit(state.copyWith(saveStatus: LoadStatus.loading, fieldErrors: const {}));
    final r = await _repo.savePassengerProfile(input);
    r.fold(
      (f) => emit(state.copyWith(
        saveStatus: LoadStatus.failure,
        error: f.message,
        fieldErrors: f is ServerFailure ? (f.fields ?? const {}) : const {},
      )),
      (user) => emit(state.copyWith(
        saveStatus: LoadStatus.success,
        savedUser: user,
      )),
    );
  }
}
