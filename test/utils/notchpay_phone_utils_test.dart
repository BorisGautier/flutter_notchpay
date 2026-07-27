import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPayPhoneUtils.normalize', () {
    test('strips the +237 country code', () {
      expect(NotchPayPhoneUtils.normalize('+237655728267'), '655728267');
    });

    test('strips the 237 country code without a plus', () {
      expect(NotchPayPhoneUtils.normalize('237655728267'), '655728267');
    });

    test('strips a leading trunk zero', () {
      expect(NotchPayPhoneUtils.normalize('0655728267'), '655728267');
    });

    test('strips spaces and dashes', () {
      expect(NotchPayPhoneUtils.normalize('655 728-267'), '655728267');
    });
  });

  group('NotchPayPhoneUtils.detectCameroonOperator', () {
    test('detects MTN prefixes', () {
      for (final number in [
        '+237650123456',
        '+237654123456',
        '+237671234567'
      ]) {
        expect(
          NotchPayPhoneUtils.detectCameroonOperator(number),
          NotchPayChannelKind.mtn,
          reason: number,
        );
      }
    });

    test('detects Orange prefixes', () {
      for (final number in [
        '+237655728267',
        '+237659123456',
        '+237691234567'
      ]) {
        expect(
          NotchPayPhoneUtils.detectCameroonOperator(number),
          NotchPayChannelKind.orange,
          reason: number,
        );
      }
    });

    test('falls back to generic mobile money for unrecognized prefixes', () {
      expect(
        NotchPayPhoneUtils.detectCameroonOperator('+23762'),
        NotchPayChannelKind.mobileMoney,
      );
    });
  });

  group('NotchPayPhoneUtils.isValidCameroonMobile', () {
    test('accepts a well-formed 9 digit mobile number', () {
      expect(NotchPayPhoneUtils.isValidCameroonMobile('+237655728267'), isTrue);
    });

    test('rejects a number that is too short', () {
      expect(NotchPayPhoneUtils.isValidCameroonMobile('+23765572'), isFalse);
    });

    test('rejects a number not starting with 6', () {
      expect(
          NotchPayPhoneUtils.isValidCameroonMobile('+237255728267'), isFalse);
    });
  });
}
