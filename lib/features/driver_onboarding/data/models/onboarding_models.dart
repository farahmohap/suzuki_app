import 'package:equatable/equatable.dart';

import '../../../../core/network/api_response.dart';
import '../../../auth/data/models/auth_model.dart';

/// Document / photo types the backend expects (`driver_documents.type`).
enum DocType {
  nationalIdFront('national_id_front', 'البطاقة الشخصية - الوجه'),
  nationalIdBack('national_id_back', 'البطاقة الشخصية - الظهر'),
  drivingLicense('driving_license', 'رخصة القيادة (مهنية / أجرة)'),
  vehicleLicense('vehicle_license', 'رخصة السيارة'),
  criminalRecord('criminal_record', 'الفيش والتشبيه'),
  vanFront('van_front', 'صورة السوزوكي - من الأمام'),
  vanRear('van_rear', 'صورة السوزوكي - من الخلف'),
  vanInterior('van_interior', 'صورة السوزوكي - من الداخل');

  const DocType(this.apiKey, this.labelAr);

  final String apiKey;
  final String labelAr;

  static DocType? fromApi(String? key) {
    for (final t in DocType.values) {
      if (t.apiKey == key) return t;
    }
    return null;
  }
}

class PersonalInput extends Equatable {
  const PersonalInput({
    required this.fullName,
    required this.nationalId,
    required this.birthDate,
    required this.districtId,
    this.avatarKey,
  });

  final String fullName;
  final String nationalId;
  final DateTime birthDate;
  final String districtId;
  final String? avatarKey;

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'national_id': nationalId,
        'birth_date':
            '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
        'district_id': districtId,
        if (avatarKey != null) 'avatar_key': avatarKey,
      };

  @override
  List<Object?> get props =>
      [fullName, nationalId, birthDate, districtId, avatarKey];
}

class VehicleInput extends Equatable {
  const VehicleInput({
    required this.plateNumbers,
    required this.plateLetters,
    required this.model,
    required this.year,
    required this.color,
  });

  /// e.g. `2845`
  final String plateNumbers;

  /// e.g. `ق ن ص`
  final String plateLetters;
  final String model;
  final int year;
  final String color;

  Map<String, dynamic> toJson() => {
        'plate_numbers': plateNumbers,
        'plate_letters': plateLetters,
        'model': model,
        'year': year,
        'color': color,
      };

  @override
  List<Object?> get props =>
      [plateNumbers, plateLetters, model, year, color];
}

/// Review state of one uploaded document (from `GET /drivers/me/status`).
class DocumentReview extends Equatable {
  const DocumentReview({
    required this.type,
    required this.status,
    this.rejectReason,
  });

  final DocType type;

  /// `uploaded` | `approved` | `rejected`
  final String status;
  final String? rejectReason;

  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [type, status, rejectReason];
}

/// `GET /drivers/me/status`.
class VerificationInfo extends Equatable {
  const VerificationInfo({
    required this.status,
    this.onboardingStep = 1,
    this.rejectionReason,
    this.documents = const [],
  });

  final VerificationStatus status;

  /// Next step to fill, 1..3 (resume point).
  final int onboardingStep;
  final String? rejectionReason;
  final List<DocumentReview> documents;

  factory VerificationInfo.fromJson(Map<String, dynamic> json) {
    final b = unwrapData(json);
    final docs = <DocumentReview>[];
    final raw = b['documents'];
    if (raw is List) {
      for (final d in raw.whereType<Map<String, dynamic>>()) {
        final type = DocType.fromApi(d['type'] as String?);
        if (type == null) continue;
        docs.add(DocumentReview(
          type: type,
          status: d['status'] as String? ?? 'uploaded',
          rejectReason: (d['reject_reason'] ?? d['reason']) as String?,
        ));
      }
    }
    return VerificationInfo(
      status: VerificationStatus.fromString(b['verification_status'] as String?),
      onboardingStep: (b['onboarding_step'] as num?)?.toInt() ?? 1,
      rejectionReason: b['rejection_reason'] as String?,
      documents: docs,
    );
  }

  @override
  List<Object?> get props => [status, onboardingStep, rejectionReason, documents];
}
