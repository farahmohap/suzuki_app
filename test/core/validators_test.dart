import 'package:flutter_test/flutter_test.dart';
import 'package:suzuki_app/core/utils/validators.dart';

void main() {
  group('Egyptian phone', () {
    test('accepts local and international formats', () {
      for (final v in [
        '01012345678',
        '010 1234 5678',
        '+201012345678',
        '00201012345678',
        '201012345678',
        '٠١٠١٢٣٤٥٦٧٨', // Arabic-Indic digits
      ]) {
        expect(AppValidators.phone(v), isNull, reason: v);
        expect(AppValidators.normalizePhone(v), '+201012345678', reason: v);
      }
    });

    test('rejects non-Egyptian or malformed numbers', () {
      for (final v in ['', '0501234567', '01312345678', '0101234567', 'abc']) {
        expect(AppValidators.phone(v), isNotNull, reason: v);
      }
    });
  });

  test('national id must be 14 digits', () {
    expect(AppValidators.nationalId('29801011234567'), isNull);
    expect(AppValidators.nationalId('1234'), isNotNull);
  });

  test('plate numbers and letters', () {
    expect(AppValidators.plateNumbers('2845'), isNull);
    expect(AppValidators.plateNumbers('28451'), isNotNull);
    expect(AppValidators.plateLetters('ق ن ص'), isNull);
    expect(AppValidators.plateLetters('قنص'), isNull);
    expect(AppValidators.plateLetters('ABC'), isNotNull);
  });

  test('otp is exactly 6 digits', () {
    expect(AppValidators.otp('123456'), isNull);
    expect(AppValidators.otp('1234'), isNotNull);
  });
}
