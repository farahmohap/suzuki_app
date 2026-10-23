import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/onboarding_models.dart';

abstract class DriverOnboardingRemoteDataSource {
  Future<void> saveStep1(PersonalInput input);
  Future<void> saveStep2(VehicleInput input);
  Future<void> saveStep3(Map<DocType, String> fileKeys);
  Future<void> submit();
  Future<VerificationInfo> getStatus();
  Future<void> replaceDocument(DocType type, String fileKey);
}

@LazySingleton(as: DriverOnboardingRemoteDataSource)
class DriverOnboardingRemoteDataSourceImpl
    implements DriverOnboardingRemoteDataSource {
  DriverOnboardingRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<void> saveStep1(PersonalInput input) =>
      _run(() => _dio.put(ApiEndpoints.driverStep1, data: input.toJson()));

  @override
  Future<void> saveStep2(VehicleInput input) =>
      _run(() => _dio.put(ApiEndpoints.driverStep2, data: input.toJson()));

  @override
  Future<void> saveStep3(Map<DocType, String> fileKeys) => _run(
        () => _dio.put(
          ApiEndpoints.driverStep3,
          data: {
            'documents': [
              for (final e in fileKeys.entries)
                {'type': e.key.apiKey, 'file_key': e.value},
            ],
          },
        ),
      );

  @override
  Future<void> submit() => _run(() => _dio.post(ApiEndpoints.driverSubmit));

  @override
  Future<VerificationInfo> getStatus() => _run(() async {
        final res = await _dio.get(ApiEndpoints.driverVerificationStatus);
        return VerificationInfo.fromJson(res.data as Map<String, dynamic>);
      });

  @override
  Future<void> replaceDocument(DocType type, String fileKey) => _run(
        () => _dio.post(
          ApiEndpoints.driverDocument(type.apiKey),
          data: {'file_key': fileKey},
        ),
      );
}
