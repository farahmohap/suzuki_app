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

/// Body of `POST /passengers/register` for a passenger.
class PassengerProfileInput extends Equatable {
  const PassengerProfileInput({
    required this.fullName,
    required this.birthDate,
    required this.gender,
    this.districtId,
    this.address,
  });

  final String fullName;
  final DateTime birthDate;
  final Gender gender;
  final String? districtId;
  final String? address;

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'birth_date':
        '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
    'gender': gender.apiValue,
    if (address != null && address!.trim().isNotEmpty)
      'address': address!.trim(),
    if (districtId != null) 'district_id': int.tryParse(districtId!),
  };

  @override
  List<Object?> get props => [fullName, birthDate, gender, districtId, address];
}
