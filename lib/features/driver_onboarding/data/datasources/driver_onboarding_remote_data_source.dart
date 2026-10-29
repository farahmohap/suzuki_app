import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/onboarding_models.dart';

abstract class DriverOnboardingRemoteDataSource {
  Future<void> saveStep1(PersonalInput input);
  Future<void> saveStep2(VehicleInput input);
  Future<void> saveStep3(Map<DocType, String> filePaths);
  Future<VerificationInfo> getStatus();
  Future<void> replaceDocument(DocType type, String filePath);
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
  Future<void> saveStep1(PersonalInput input) => _run(() async {
        final formData = FormData.fromMap({
          ...input.toJson(),
          'avatar': await MultipartFile.fromFile(input.avatarPath),
        });
        await _dio.put(ApiEndpoints.driverStep1, data: formData);
      });

  @override
  Future<void> saveStep2(VehicleInput input) =>
      _run(() => _dio.put(ApiEndpoints.driverStep2, data: input.toJson()));

  @override
  Future<void> saveStep3(Map<DocType, String> filePaths) => _run(() async {
        final formData = FormData();
        for (final entry in filePaths.entries) {
          formData.files.add(MapEntry(
            'documents[${entry.key.apiKey}]',
            await MultipartFile.fromFile(entry.value),
          ));
        }
        await _dio.put(ApiEndpoints.driverStep3, data: formData);
      });


  @override
  Future<VerificationInfo> getStatus() => _run(() async {
        final res = await _dio.get(ApiEndpoints.driverVerificationStatus);
        return VerificationInfo.fromJson(res.data as Map<String, dynamic>);
      });

  @override
  Future<void> replaceDocument(DocType type, String filePath) => _run(() async {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath),
        });
        await _dio.post(ApiEndpoints.driverDocument(type.apiKey), data: formData);
      });
}
