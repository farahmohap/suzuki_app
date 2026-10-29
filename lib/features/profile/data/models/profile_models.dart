import 'package:equatable/equatable.dart';

enum Gender {
  male,
  female;

  String get apiValue => name;
  String get labelAr => this == Gender.male ? 'ذكر' : 'أنثى';
}

/// An Obour City district (`GET /districts`).
class DistrictModel extends Equatable {
  const DistrictModel({required this.id, required this.nameAr, this.code});

  final String id;
  final String nameAr;
  final String? code;

  factory DistrictModel.fromJson(Map<dynamic, dynamic> json) => DistrictModel(
        id: json['id'].toString(),
        nameAr: (json['name_ar'] ?? json['name'] ?? '').toString(),
        code: json['code']?.toString(),
      );

  @override
  List<Object?> get props => [id, nameAr, code];
}

/// Body of `PUT /users/me` for a passenger.
class PassengerProfileInput extends Equatable {
  const PassengerProfileInput({
    required this.fullName,
    required this.gender,
    required this.age,
    required this.districtId,
    required this.addressText,
    required this.latitude,
    required this.longitude,
  });

  final String fullName;
  final Gender gender;
  final int age;
  final String districtId;
  final String addressText;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'gender': gender.apiValue,
        'birth_year': DateTime.now().year - age,
        'district_id': districtId,
        'address_text': addressText,
        'location': {'lat': latitude, 'lng': longitude},
      };

  @override
  List<Object?> get props =>
      [fullName, gender, age, districtId, addressText, latitude, longitude];
}
