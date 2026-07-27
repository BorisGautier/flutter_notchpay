import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPayCurrencyFormatter.format', () {
    test('formats a zero-decimal currency without decimals', () {
      expect(NotchPayCurrencyFormatter.format(1500, 'XAF'), '1 500 XAF');
    });

    test('groups large amounts by thousands', () {
      expect(NotchPayCurrencyFormatter.format(1234567, 'XAF'), '1 234 567 XAF');
    });

    test('keeps decimals for non zero-decimal currencies', () {
      expect(NotchPayCurrencyFormatter.format(19.9, 'USD'), '19.90 USD');
    });

    test('upper-cases the currency code', () {
      expect(NotchPayCurrencyFormatter.format(100, 'xaf'), '100 XAF');
    });

    test('formats a small amount without a leading grouping space', () {
      expect(NotchPayCurrencyFormatter.format(500, 'XAF'), '500 XAF');
    });
  });
}
