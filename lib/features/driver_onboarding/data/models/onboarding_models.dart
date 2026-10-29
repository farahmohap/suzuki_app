import 'package:equatable/equatable.dart';

import '../../../../core/network/api_response.dart';
import '../../../auth/data/models/auth_model.dart';
import '../../../profile/data/models/profile_models.dart';

/// Document / photo types the backend expects (`driver_documents.type`).
enum DocType {
  nationalIdFront('national_id_front', 'البطاقة الشخصية - الوجه'),
  nationalIdBack('national_id_back', 'البطاقة الشخصية - الظهر'),
  drivingLicense('driving_license', 'رخصة القيادة (مهنية / أجرة)'),
  vehicleLicense('vehicle_license', 'رخصة السيارة'),
  criminalRecord('criminal_record', 'الفيش والتشبيه'),
  vehicleFront('vehicle_front', 'صورة السوزوكي - من الأمام'),
  vehicleRear('vehicle_back', 'صورة السوزوكي - من الخلف'),
  vehicleInterior('vehicle_interior', 'صورة السوزوكي - من الداخل');

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
    required this.gender,
    required this.avatarPath,
    required this.districtId,
  });

  final String fullName;
  final String nationalId;
  final DateTime birthDate;
  final Gender gender;

  /// Local file path — sent as multipart file.
  final String avatarPath;

  final int districtId;

  String get birthDateFormatted =>
      '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'national_id': nationalId,
        'birth_date': birthDateFormatted,
        'gender': gender.apiValue,
        'district_id': districtId,
      };

  @override
  List<Object?> get props =>
      [fullName, nationalId, birthDate, gender, avatarPath, districtId];
}

class VehicleInput extends Equatable {
  const VehicleInput({
    required this.plateNumbers,
    required this.plateLetters,
    required this.model,
    required this.color,
    this.documents = const [],
  });

  /// e.g. `2845`
  final String plateNumbers;

  /// e.g. `ق ن ص`
  final String plateLetters;
  final String model;
  final String color;
  final List<DriverDocumentInput> documents;

  Map<String, dynamic> toJson() => {
        'plate_numbers': plateNumbers,
        'plate_letters': plateLetters,
        'model': model,
        'color': color,
      };

  @override
  List<Object?> get props => [plateNumbers, plateLetters, model, color, documents];
}

/// A vehicle document file sent as multipart data in the step 2 request.
class DriverDocumentInput extends Equatable {
  const DriverDocumentInput({
    required this.type,
    required this.filePath,
  });

  final String type;
  final String filePath;

  @override
  List<Object?> get props => [type, filePath];
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

/// Unified response model for all 3 driver registration steps
/// (`/drivers/register/step1`, `/drivers/register/step2`, `/drivers/register/step3`,
/// and `/drivers/register/submit`).
class DriverStepResponse extends Equatable {
  const DriverStepResponse({
    required this.status,
    this.message,
    this.onboardingStep = 1,
    this.completedSteps = const [],
    this.rejectionReason,
    this.documents = const [],
    this.raw = const {},
  });

  final VerificationStatus status;
  final String? message;

  /// 1-based next step index (1, 2, or 3).
  final int onboardingStep;
  final List<int> completedSteps;
  final String? rejectionReason;
  final List<DocumentReview> documents;
  final Map<String, dynamic> raw;

  /// 0-indexed step for the wizard UI (0 = personal, 1 = vehicle, 2 = documents).
  int get nextStepIndex => (onboardingStep - 1).clamp(0, 2);

  factory DriverStepResponse.fromJson(Map<String, dynamic> json) {
    final body = unwrapData(json);
    final message = (json['message'] ?? body['message'])?.toString();

    final docs = <DocumentReview>[];
    final rawDocs = body['documents'];
    if (rawDocs is List) {
      for (final item in rawDocs) {
        if (item is Map) {
          final type = DocType.fromApi(item['type']?.toString());
          if (type == null) continue;
          docs.add(DocumentReview(
            type: type,
            status: (item['status'] ?? 'missing').toString(),
            rejectReason: (item['reject_reason'] ?? item['reason'])?.toString(),
          ));
        }
      }
    }

    final status = VerificationStatus.fromString(
      (body['status'] ?? body['verification_status'])?.toString(),
    );

    final completedSteps = <int>[];
    final rawCompleted = body['completed_steps'];
    if (rawCompleted is List) {
      for (final s in rawCompleted) {
        if (s is num) {
          completedSteps.add(s.toInt());
        } else if (s is String) {
          final n = int.tryParse(s);
          if (n != null) completedSteps.add(n);
        }
      }
    }
    final rawSteps = body['steps'];
    if (rawSteps is Map) {
      if (rawSteps['step1'] == true && !completedSteps.contains(1)) {
        completedSteps.add(1);
      }
      if (rawSteps['step2'] == true && !completedSteps.contains(2)) {
        completedSteps.add(2);
      }
      if (rawSteps['step3'] == true && !completedSteps.contains(3)) {
        completedSteps.add(3);
      }
    }

    int parseStep(dynamic raw) {
      if (raw == null) return 0;
      if (raw is num) return raw.toInt();
      if (raw is String) {
        final s = raw.toLowerCase().trim();
        if (s == 'step1' || s == '1') return 1;
        if (s == 'step2' || s == '2') return 2;
        if (s == 'step3' || s == '3') return 3;
        final n = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
        if (n != null) return n;
      }
      return 0;
    }

    final parsedFromNext =
        parseStep(body['next_step'] ?? body['onboarding_step']);

    final int onboardingStep = parsedFromNext > 0
        ? parsedFromNext
        : completedSteps.contains(2)
            ? 3
            : completedSteps.contains(1)
                ? 2
                : (status == VerificationStatus.needsDocuments ? 3 : 1);

    return DriverStepResponse(
      status: status,
      message: message,
      onboardingStep: onboardingStep,
      completedSteps: completedSteps,
      rejectionReason: body['rejection_reason']?.toString(),
      documents: docs,
      raw: body,
    );
  }

  VerificationInfo toVerificationInfo() => VerificationInfo(
        status: status,
        onboardingStep: onboardingStep,
        completedSteps: completedSteps,
        rejectionReason: rejectionReason,
        documents: documents,
      );

  @override
  List<Object?> get props => [
        status,
        message,
        onboardingStep,
        completedSteps,
        rejectionReason,
        documents,
      ];
}

/// `GET /drivers/me/status`.
class VerificationInfo extends Equatable {
  const VerificationInfo({
    required this.status,
    this.onboardingStep = 1,
    this.completedSteps = const [],
    this.rejectionReason,
    this.documents = const [],
  });

  final VerificationStatus status;

  /// Next step to fill, 1..3 (resume point).
  final int onboardingStep;
  final List<int> completedSteps;
  final String? rejectionReason;
  final List<DocumentReview> documents;

  int get nextStepIndex => (onboardingStep - 1).clamp(0, 2);

  factory VerificationInfo.fromJson(Map<String, dynamic> json) {
    return DriverStepResponse.fromJson(json).toVerificationInfo();
  }

  @override
  List<Object?> get props => [
        status,
        onboardingStep,
        completedSteps,
        rejectionReason,
        documents,
      ];
}
