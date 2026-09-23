import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../models/passenger_models.dart';

abstract class PassengerLocalDataSource {
  Future<List<LandmarkModel>> getCachedLandmarks();
  Future<void> cacheLandmarks(List<LandmarkModel> landmarks);
  Future<void> addLandmark(LandmarkModel landmark);
  Future<void> deleteLandmark(String landmarkId);
  Future<void> clearLandmarks();
}

/// Hive-backed local data source for passenger landmarks.
@LazySingleton(as: PassengerLocalDataSource)
class PassengerLocalDataSourceImpl implements PassengerLocalDataSource {
  PassengerLocalDataSourceImpl();

  static const _boxName = 'passenger_landmarks';

  Box<String> get _box => Hive.box<String>(_boxName);

  /// Opens the Hive box — call during app bootstrap.
  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  @override
  Future<List<LandmarkModel>> getCachedLandmarks() async {
    try {
      return _box.values
          .map((json) =>
              LandmarkModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException(message: 'تعذّر تحميل المعالم المحفوظة');
    }
  }

  @override
  Future<void> cacheLandmarks(List<LandmarkModel> landmarks) async {
    try {
      await _box.clear();
      final entries = {
        for (final l in landmarks) l.id: jsonEncode(l.toJson()),
      };
      await _box.putAll(entries);
    } catch (_) {
      throw const CacheException(message: 'تعذّر حفظ المعالم');
    }
  }

  @override
  Future<void> addLandmark(LandmarkModel landmark) async {
    try {
      await _box.put(landmark.id, jsonEncode(landmark.toJson()));
    } catch (_) {
      throw const CacheException(message: 'تعذّر إضافة المعلم');
    }
  }

  @override
  Future<void> deleteLandmark(String landmarkId) async {
    try {
      await _box.delete(landmarkId);
    } catch (_) {
      throw const CacheException(message: 'تعذّر حذف المعلم');
    }
  }

  @override
  Future<void> clearLandmarks() => _box.clear();
}
