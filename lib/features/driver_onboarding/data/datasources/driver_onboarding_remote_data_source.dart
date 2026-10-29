import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/onboarding_models.dart';

abstract class DriverOnboardingRemoteDataSource {
  Future<DriverStepResponse> saveStep1(PersonalInput input);
  Future<DriverStepResponse> saveStep2(VehicleInput input);
  Future<DriverStepResponse> saveStep3(Map<DocType, String> filePaths);
  Future<DriverStepResponse> submit();
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

  Future<Response<dynamic>> _sendMultipartPut(
    String path,
    FormData formData,
  ) async {
    // Add _method: PUT for Laravel/PHP multipart method spoofing
    if (!formData.fields.any((e) => e.key == '_method')) {
      formData.fields.add(const MapEntry('_method', 'PUT'));
    }
    try {
      return await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 405) {
        return await _dio.put(
          path,
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      }
      rethrow;
    }
  }

  @override
  Future<DriverStepResponse> saveStep1(PersonalInput input) =>
      _run(() async {
        final formData = FormData.fromMap({
          '_method': 'PUT',
          'full_name': input.fullName,
          'national_id': input.nationalId,
          'birth_date': input.birthDateFormatted,
          'gender': input.gender.apiValue,
          'district_id': input.districtId,
          'avatar_key': await MultipartFile.fromFile(input.avatarPath),
          'avatar': await MultipartFile.fromFile(input.avatarPath),
        });
        final res = await _sendMultipartPut(ApiEndpoints.driverStep1, formData);
        return DriverStepResponse.fromJson(res.data as Map<String, dynamic>);
      });

  @override
  Future<DriverStepResponse> saveStep2(VehicleInput input) => _run(() async {
        final res = await _dio.put(
          ApiEndpoints.driverStep2,
          data: input.toJson(),
        );
        return DriverStepResponse.fromJson(res.data as Map<String, dynamic>);
      });

  @override
  Future<DriverStepResponse> saveStep3(Map<DocType, String> filePaths) =>
      _run(() async {
        final formData = FormData();
        formData.fields.add(const MapEntry('_method', 'PUT'));
        for (final entry in filePaths.entries) {
          formData.files.add(MapEntry(
            'documents[${entry.key.apiKey}]',
            await MultipartFile.fromFile(entry.value),
          ));
          formData.files.add(MapEntry(
            entry.key.apiKey,
            await MultipartFile.fromFile(entry.value),
          ));
        }
        final res = await _sendMultipartPut(ApiEndpoints.driverStep3, formData);
        return DriverStepResponse.fromJson(res.data as Map<String, dynamic>);
      });

  @override
  Future<DriverStepResponse> submit() => _run(() async {
        final res = await _dio.post(ApiEndpoints.driverSubmit);
        return DriverStepResponse.fromJson(res.data as Map<String, dynamic>);
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
          'document': await MultipartFile.fromFile(filePath),
        });
        await _dio.post(
          ApiEndpoints.driverDocument(type.apiKey),
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      });
}
