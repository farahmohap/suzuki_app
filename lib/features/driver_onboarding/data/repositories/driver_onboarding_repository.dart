import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/upload_service.dart';
import '../datasources/driver_onboarding_remote_data_source.dart';
import '../models/onboarding_models.dart';

abstract class DriverOnboardingRepository {
  Future<Either<Failure, String>> uploadFile({
    required String path,
    required String kind,
    void Function(double progress)? onProgress,
  });
  Future<Either<Failure, Unit>> saveStep1(PersonalInput input);
  Future<Either<Failure, Unit>> saveStep2(VehicleInput input);

  /// Saves step 3 and submits the application for review.
  Future<Either<Failure, Unit>> saveDocumentsAndSubmit(
    Map<DocType, String> fileKeys,
  );
  Future<Either<Failure, VerificationInfo>> getStatus();
  Future<Either<Failure, Unit>> replaceDocument(DocType type, String fileKey);
}

@LazySingleton(as: DriverOnboardingRepository)
class DriverOnboardingRepositoryImpl implements DriverOnboardingRepository {
  const DriverOnboardingRepositoryImpl(
    this._remote,
    this._upload,
    this._network,
  );

  final DriverOnboardingRemoteDataSource _remote;
  final UploadService _upload;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, String>> uploadFile({
    required String path,
    required String kind,
    void Function(double progress)? onProgress,
  }) =>
      guardCall(
        _network,
        () => _upload.upload(path: path, kind: kind, onProgress: onProgress),
      );

  @override
  Future<Either<Failure, Unit>> saveStep1(PersonalInput input) =>
      guardCall(_network, () async {
        await _remote.saveStep1(input);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> saveStep2(VehicleInput input) =>
      guardCall(_network, () async {
        await _remote.saveStep2(input);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> saveDocumentsAndSubmit(
    Map<DocType, String> fileKeys,
  ) =>
      guardCall(_network, () async {
        await _remote.saveStep3(fileKeys);
        await _remote.submit();
        return unit;
      });

  @override
  Future<Either<Failure, VerificationInfo>> getStatus() =>
      guardCall(_network, _remote.getStatus);

  @override
  Future<Either<Failure, Unit>> replaceDocument(
    DocType type,
    String fileKey,
  ) =>
      guardCall(_network, () async {
        await _remote.replaceDocument(type, fileKey);
        return unit;
      });
}
