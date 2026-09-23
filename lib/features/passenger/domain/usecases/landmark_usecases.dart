import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/landmark_entity.dart';
import '../repositories/passenger_repository.dart';

/// Returns all saved landmarks for the current user (local cache first).
@injectable
class GetSavedLandmarksUseCase {
  const GetSavedLandmarksUseCase(this._repository);

  final PassengerRepository _repository;

  Future<Either<Failure, List<LandmarkEntity>>> call() =>
      _repository.getSavedLandmarks();
}

/// Saves a new landmark to local storage and syncs to remote.
@injectable
class SaveLandmarkUseCase {
  const SaveLandmarkUseCase(this._repository);

  final PassengerRepository _repository;

  Future<Either<Failure, LandmarkEntity>> call(LandmarkEntity landmark) {
    if (landmark.name.trim().isEmpty) {
      return Future.value(
        Left(const ValidationFailure(message: 'اسم المعلم مطلوب')),
      );
    }
    return _repository.saveLandmark(landmark);
  }
}

/// Deletes a landmark by ID.
@injectable
class DeleteLandmarkUseCase {
  const DeleteLandmarkUseCase(this._repository);

  final PassengerRepository _repository;

  Future<Either<Failure, bool>> call({required String landmarkId}) =>
      _repository.deleteLandmark(landmarkId: landmarkId);
}
