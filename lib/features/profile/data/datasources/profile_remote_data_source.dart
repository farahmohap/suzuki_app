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
      return unwrapList(res.data)
          .whereType<Map<String, dynamic>>()
          .map(DistrictModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<AuthModel> savePassengerProfile(PassengerProfileInput input) async {
    try {
      final res = await _dio.put(ApiEndpoints.me, data: input.toJson());
      return AuthModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }
}
