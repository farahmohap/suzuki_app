import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/auth_model.dart';
import '../models/profile_models.dart';

abstract class ProfileRemoteDataSource {
  Future<List<DistrictModel>> getDistricts();
  Future<AuthModel> savePassengerProfile(PassengerProfileInput input);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<DistrictModel>> getDistricts() async {
    try {
      final res = await _dio.get(ApiEndpoints.districts);
      return unwrapList(
        res.data,
      ).whereType<Map>().map((m) => DistrictModel.fromJson(m)).toList();
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<AuthModel> savePassengerProfile(PassengerProfileInput input) async {
    try {
      await _dio.post(ApiEndpoints.passengerRegister, data: input.toJson());
      final me = await _dio.get(ApiEndpoints.me);
      // A successful registration means this passenger has completed the
      // profile, even if /users/me omits or briefly returns a stale flag.
      return AuthModel.fromJson(
        me.data as Map<String, dynamic>,
      ).copyWith(profileComplete: true);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }
}
