import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// A saved landmark / favourite location for the passenger.
class LandmarkEntity extends Equatable {
  const LandmarkEntity({
    required this.id,
    required this.name,
    required this.location,
    this.address,
    this.type = LandmarkType.custom,
  });

  final String id;
  final String name;
  final LatLng location;
  final String? address;
  final LandmarkType type;

  @override
  List<Object?> get props => [id, name, location, address, type];
}

enum LandmarkType {
  home,
  work,
  custom;

  String get label {
    switch (this) {
      case home:
        return 'المنزل';
      case work:
        return 'العمل';
      case custom:
        return 'مخصص';
    }
  }

  String get icon {
    switch (this) {
      case home:
        return '🏠';
      case work:
        return '🏢';
      case custom:
        return '📍';
    }
  }
}
