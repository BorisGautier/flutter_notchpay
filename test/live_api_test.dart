import 'dart:io';

import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final publicKey = Platform.environment['NOTCHPAY_TEST_PUBLIC_KEY'];
  final privateKey = Platform.environment['NOTCHPAY_TEST_PRIVATE_KEY'];

  group('Live NotchPay Sandbox API Integration Tests', () {
    test('fetches real reference data (channels, currencies, countries)',
        () async {
      if (publicKey == null) {
        // Skipped unless NOTCHPAY_TEST_PUBLIC_KEY is provided
        return;
      }

      final notchPay = NotchPay(publicKey: publicKey);

      final channels = await notchPay.resources.channels(country: 'cm');
      expect(channels, isNotEmpty);

      final currencies = await notchPay.resources.currencies();
      expect(currencies, isNotEmpty);

      final countries = await notchPay.resources.countries();
      expect(countries, isNotEmpty);

      notchPay.dispose();
    });

    test('initializes and fetches a real sandbox payment', () async {
      if (publicKey == null) return;

      final notchPay = NotchPay(publicKey: publicKey);

      final payment = await notchPay.payments.initialize(
        const NotchPayCheckoutRequest(
          amount: 500,
          currency: 'XAF',
          description: 'Live Test Payment',
          customer: NotchPayCheckoutCustomer(
            name: 'Live Test Customer',
            email: 'test@notchpay.co',
            phone: '+237655728267',
          ),
        ),
      );

      expect(payment.reference, isNotEmpty);
      expect(payment.amount, 500.0);

      final fetched = await notchPay.payments.fetch(payment.reference);
      expect(fetched.reference, payment.reference);

      notchPay.dispose();
    });

    test('fetches balance with private key when provided', () async {
      if (publicKey == null || privateKey == null) return;

      final notchPay = NotchPay(
        publicKey: publicKey,
        privateKey: privateKey,
      );

      final balance = await notchPay.balance.fetch();
      expect(balance, isNotNull);

      notchPay.dispose();
    });
  });
}
