import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPayEnvironment.detect', () {
    test('recognizes common test key shapes as sandbox', () {
      for (final key in [
        'pk_test_123',
        'sk_test_456',
        'pk.test.abcdef',
        'pk-test-abcdef',
        'acc.test_SD9b2dwJ2nqX8XEclNpEcGGc',
        'PK_TEST_UPPERCASE',
      ]) {
        expect(
          NotchPayEnvironment.detect(key),
          NotchPayEnvironment.sandbox,
          reason: key,
        );
      }
    });

    test('treats keys without a test marker as live', () {
      for (final key in [
        'pk_live_123',
        'sk_live_456',
        'pk.live.abcdef',
        'pk_abcdef123456',
      ]) {
        expect(NotchPayEnvironment.detect(key), NotchPayEnvironment.live,
            reason: key);
      }
    });

    test('does not false-positive on "test" embedded without a separator', () {
      // "latest" contains "test" but not as its own segment.
      expect(
          NotchPayEnvironment.detect('pk_latest123'), NotchPayEnvironment.live);
    });

    test('isSandbox / isLive convenience getters', () {
      expect(NotchPayEnvironment.sandbox.isSandbox, isTrue);
      expect(NotchPayEnvironment.sandbox.isLive, isFalse);
      expect(NotchPayEnvironment.live.isLive, isTrue);
      expect(NotchPayEnvironment.live.isSandbox, isFalse);
    });
  });

  group('NotchPayClient.environment', () {
    test('is derived from the public key', () {
      expect(NotchPayClient(publicKey: 'pk_test_123').environment.isSandbox,
          isTrue);
      expect(
          NotchPayClient(publicKey: 'pk_live_123').environment.isLive, isTrue);
    });
  });
}
