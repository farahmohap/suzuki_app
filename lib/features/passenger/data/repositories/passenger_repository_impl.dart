import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/landmark_entity.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/entities/seat_booking_entity.dart';
import '../../domain/repositories/passenger_repository.dart';
import '../datasources/passenger_local_data_source.dart';
import '../datasources/passenger_remote_data_source.dart';
import '../models/passenger_models.dart';

@LazySingleton(as: PassengerRepository)
class PassengerRepositoryImpl implements PassengerRepository {
  const PassengerRepositoryImpl({
    required PassengerRemoteDataSource remoteDataSource,
    required PassengerLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _network = networkInfo;

  final PassengerRemoteDataSource _remote;
  final PassengerLocalDataSource _local;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, List<RouteEntity>>> getAvailableRoutes({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final routes = await _remote.getAvailableRoutes(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      return Right(routes);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, SeatBookingEntity>> bookSeat({
    required String routeId,
    required int seatNumber,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final booking =
          await _remote.bookSeat(routeId: routeId, seatNumber: seatNumber);
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, SeatBookingEntity?>> getActiveBooking() async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final booking = await _remote.getActiveBooking();
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> cancelBooking(
      {required String bookingId}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remote.cancelBooking(bookingId: bookingId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<LandmarkEntity>>> getSavedLandmarks() async {
    // Local-first strategy
    try {
      final local = await _local.getCachedLandmarks();
      if (local.isNotEmpty) return Right(local);
    } catch (_) {}

    if (!await _network.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final remote = await _remote.getLandmarks();
      await _local.cacheLandmarks(remote);
      return Right(remote);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, LandmarkEntity>> saveLandmark(
      LandmarkEntity landmark) async {
    try {
      final model = LandmarkModel.fromEntity(landmark);
      if (await _network.isConnected) {
        final remote = await _remote.saveLandmark(model);
        await _local.addLandmark(remote);
        return Right(remote);
      } else {
        await _local.addLandmark(model);
        return Right(model);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteLandmark(
      {required String landmarkId}) async {
    try {
      await _local.deleteLandmark(landmarkId);
      if (await _network.isConnected) {
        await _remote.deleteLandmark(landmarkId: landmarkId);
      }
      return const Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
