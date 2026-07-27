import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPayCardUtils.detectBrand', () {
    test('detects Visa', () {
      expect(NotchPayCardUtils.detectBrand('4242424242424242'),
          NotchPayCardBrand.visa);
    });

    test('detects Mastercard', () {
      expect(NotchPayCardUtils.detectBrand('5454545454545454'),
          NotchPayCardBrand.mastercard);
      expect(NotchPayCardUtils.detectBrand('2223000048400011'),
          NotchPayCardBrand.mastercard);
    });

    test('detects American Express', () {
      expect(NotchPayCardUtils.detectBrand('378282246310005'),
          NotchPayCardBrand.americanExpress);
    });

    test('returns unknown for an empty or unrecognized number', () {
      expect(NotchPayCardUtils.detectBrand(''), NotchPayCardBrand.unknown);
      expect(NotchPayCardUtils.detectBrand('9999999999999999'),
          NotchPayCardBrand.unknown);
    });
  });

  group('NotchPayCardUtils.isValidLuhn', () {
    test('accepts known-valid test card numbers', () {
      expect(NotchPayCardUtils.isValidLuhn('4242424242424242'), isTrue);
      expect(NotchPayCardUtils.isValidLuhn('378282246310005'), isTrue);
    });

    test('rejects an invalid checksum', () {
      expect(NotchPayCardUtils.isValidLuhn('4242424242424241'), isFalse);
    });

    test('rejects a too-short number', () {
      expect(NotchPayCardUtils.isValidLuhn('42424242'), isFalse);
    });
  });

  group('NotchPayCardUtils.isValidExpiry', () {
    test('rejects a malformed expiry', () {
      expect(NotchPayCardUtils.isValidExpiry('13/99'), isFalse);
      expect(NotchPayCardUtils.isValidExpiry('not-a-date'), isFalse);
    });

    test('rejects a date in the past', () {
      expect(NotchPayCardUtils.isValidExpiry('01/20'), isFalse);
    });

    test('accepts a date far in the future', () {
      expect(NotchPayCardUtils.isValidExpiry('12/99'), isTrue);
    });
  });

  group('NotchPayCardUtils.formatForDisplay', () {
    test('groups digits by 4', () {
      expect(NotchPayCardUtils.formatForDisplay('4242424242424242'),
          '4242 4242 4242 4242');
    });
  });
}
