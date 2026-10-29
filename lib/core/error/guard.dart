import 'package:fpdart/fpdart.dart';

import '../network/network_info.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Runs [body], converting every [AppException] into a typed [Failure].
/// One place for the try/catch that every repository used to repeat.
Future<Either<Failure, T>> guardCall<T>(
  NetworkInfo network,
  Future<T> Function() body, {
  bool requireNetwork = true,
}) async {
  if (requireNetwork && !await network.isConnected) {
    return const Left(NetworkFailure());
  }
  try {
    return Right(await body());
  } on ServerException catch (e) {
    return Left(ServerFailure.fromException(e));
  } on NetworkException catch (e) {
    return Left(NetworkFailure.fromException(e));
  } on AuthException catch (e) {
    return Left(AuthFailure.fromException(e));
  } on SessionExpiredException {
    return const Left(SessionExpiredFailure());
  } on CacheException catch (e) {
    return Left(CacheFailure.fromException(e));
  } catch (_) {
    return const Left(UnknownFailure());
  }
}
