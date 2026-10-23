import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../error/exceptions.dart';
import 'api_endpoints.dart';
import 'api_response.dart';
import 'dio_client.dart';

/// Two-step upload: (1) ask the backend for a presigned URL,
/// (2) PUT the file straight to storage, (3) hand back the `file_key`.
@lazySingleton
class UploadService {
  UploadService(this._api);

  /// Authenticated API client (used only for the presign call).
  final Dio _api;

  static const maxBytes = 8 * 1024 * 1024;

  /// Uploads [path] and returns the storage `file_key`.
  /// [kind] is a free label for the backend (e.g. `avatar`, `national_id_front`).
  Future<String> upload({
    required String path,
    required String kind,
    void Function(double progress)? onProgress,
  }) async {
    final file = File(path);
    final length = await file.length();
    if (length > maxBytes) {
      throw const ServerException(
        message: 'حجم الصورة كبير (الحد الأقصى 8 ميجا)',
        code: 'FILE_TOO_LARGE',
      );
    }
    final contentType = _contentType(path);

    try {
      final presign = await _api.post(
        ApiEndpoints.presignUpload,
        data: {'kind': kind, 'content_type': contentType, 'size': length},
      );
      final body = unwrapData(presign.data);
      final url = body['upload_url'] as String?;
      final key = body['file_key'] as String?;
      if (url == null || key == null) {
        throw const ServerException(
          message: 'استجابة رفع غير صحيحة',
          code: 'BAD_PRESIGN',
        );
      }

      // Plain Dio on purpose: a presigned URL must NOT receive our
      // Authorization header or the storage provider rejects the signature.
      await Dio().put(
        url,
        data: file.openRead(),
        options: Options(
          headers: {
            Headers.contentLengthHeader: length,
            Headers.contentTypeHeader: contentType,
          },
        ),
        onSendProgress: (sent, total) =>
            onProgress?.call(total <= 0 ? 0 : sent / total),
      );
      return key;
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  String _contentType(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
