import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/data/models/auth_model.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_models.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<DistrictModel>>> getDistricts();

  /// Saves the passenger profile; returns the updated user
  /// (`profileComplete == true`).
  Future<Either<Failure, AuthModel>> savePassengerProfile(
    PassengerProfileInput input,
  );
}

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote, this._network);

  final ProfileRemoteDataSource _remote;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, List<DistrictModel>>> getDistricts() =>
      guardCall(_network, _remote.getDistricts);

  @override
  Future<Either<Failure, AuthModel>> savePassengerProfile(
    PassengerProfileInput input,
  ) =>
      guardCall(_network, () => _remote.savePassengerProfile(input));
}
