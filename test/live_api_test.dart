import 'dart:io';

import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Read API keys from environment variables to prevent hardcoding secrets in git/pub.dev
  final publicKey = Platform.environment['NOTCHPAY_TEST_PUBLIC_KEY'];
  final privateKey = Platform.environment['NOTCHPAY_TEST_PRIVATE_KEY'];

  group('Live NotchPay Sandbox API Real Integration Tests', () {
    late NotchPay notchPay;
    late NotchPay notchPayPrivate;

    setUp(() {
      if (publicKey == null || privateKey == null) return;
      notchPay = NotchPay(publicKey: publicKey);
      notchPayPrivate = NotchPay(
        publicKey: publicKey,
        privateKey: privateKey,
      );
    });

    tearDown(() {
      if (publicKey == null || privateKey == null) return;
      notchPay.dispose();
      notchPayPrivate.dispose();
    });

    test('1. Environment auto-detection', () {
      if (publicKey == null) return;
      expect(notchPay.environment, NotchPayEnvironment.sandbox);
      expect(notchPay.isSandbox, isTrue);
      expect(notchPay.isLive, isFalse);
    });

    test('2. Real payment initialization & fetching', () async {
      if (publicKey == null) return;
      final payment = await notchPay.payments.initialize(
        const NotchPayCheckoutRequest(
          amount: 500,
          currency: 'XAF',
          description: 'Live Test Payment (Init)',
          customer: NotchPayCheckoutCustomer(
            name: 'Test Customer',
            email: 'test@notchpay.co',
            phone: '+237670000000',
          ),
        ),
      );

      expect(payment.reference, isNotEmpty);
      expect(payment.amount, 500.0);

      final fetched = await notchPay.payments.fetch(payment.reference);
      expect(fetched.reference, payment.reference);
    });

    test('3. Mobile Money payment completion (Success scenario: +237670000000)',
        () async {
      if (publicKey == null) return;
      final payment = await notchPay.payments.initialize(
        const NotchPayCheckoutRequest(
          amount: 1000,
          currency: 'XAF',
          description: 'Live Success Scenario Test',
          customer: NotchPayCheckoutCustomer(
            name: 'Success Tester',
            phone: '+237670000000',
          ),
        ),
      );

      final completed = await notchPay.payments.complete(
        payment.reference,
        channel: 'cm.mtn',
        data: {'phone': '+237670000000'},
      );

      expect(completed.reference, payment.reference);
      expect(completed.status, isNot(NotchPayPaymentStatus.unknown));
    });

    test(
        '4. Mobile Money payment completion (Insufficient funds scenario: +237670000001)',
        () async {
      if (publicKey == null) return;
      final payment = await notchPay.payments.initialize(
        const NotchPayCheckoutRequest(
          amount: 1000,
          currency: 'XAF',
          description: 'Live Insufficient Funds Test',
          customer: NotchPayCheckoutCustomer(
            name: 'Failure Tester',
            phone: '+237670000001',
          ),
        ),
      );

      final completed = await notchPay.payments.complete(
        payment.reference,
        channel: 'cm.mtn',
        data: {'phone': '+237670000001'},
      );

      expect(completed.reference, payment.reference);
    });

    test('5. Private key API: fetches account balance', () async {
      if (privateKey == null) return;
      final balances = await notchPayPrivate.balance.fetch();
      expect(balances, isNotNull);
    });

    test('6. Private key API: lists recipients and transfers', () async {
      if (privateKey == null) return;
      final recipients = await notchPayPrivate.recipients.list();
      expect(recipients, isNotNull);

      final transfers = await notchPayPrivate.transfers.list();
      expect(transfers, isNotNull);
    });
  });
}
