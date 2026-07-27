import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPayPayment', () {
    test('parses a transaction wrapped in a `transaction` key', () {
      final payment = NotchPayPayment.fromJson({
        'transaction': {
          'reference': 'trx.RoOvUhfZXi79G7ZrAkL3JUBt',
          'amount': 100,
          'currency': 'XAF',
          'status': 'pending',
          'description': 'ddd',
        },
      });

      expect(payment.reference, 'trx.RoOvUhfZXi79G7ZrAkL3JUBt');
      expect(payment.amount, 100);
      expect(payment.currency, 'XAF');
      expect(payment.status, NotchPayPaymentStatus.pending);
    });

    test('parses a flat transaction payload', () {
      final payment = NotchPayPayment.fromJson({
        'reference': 'trx.abc',
        'amount': 1500,
        'currency': 'XAF',
        'status': 'complete',
      });

      expect(payment.status, NotchPayPaymentStatus.complete);
      expect(payment.status.isSuccess, isTrue);
      expect(payment.status.isFinal, isTrue);
    });

    test('defaults to unknown status for unrecognized values', () {
      final payment = NotchPayPayment.fromJson({
        'reference': 'trx.abc',
        'amount': 1,
        'currency': 'XAF',
        'status': 'something_new',
      });

      expect(payment.status, NotchPayPaymentStatus.unknown);
      expect(payment.status.isFinal, isFalse);
    });
  });

  group('NotchPayPaymentStatus.parse', () {
    test('recognizes every documented status', () {
      expect(NotchPayPaymentStatus.parse('pending'),
          NotchPayPaymentStatus.pending);
      expect(NotchPayPaymentStatus.parse('processing'),
          NotchPayPaymentStatus.processing);
      expect(NotchPayPaymentStatus.parse('complete'),
          NotchPayPaymentStatus.complete);
      expect(
          NotchPayPaymentStatus.parse('failed'), NotchPayPaymentStatus.failed);
      expect(NotchPayPaymentStatus.parse('canceled'),
          NotchPayPaymentStatus.canceled);
      expect(NotchPayPaymentStatus.parse('cancelled'),
          NotchPayPaymentStatus.canceled);
      expect(NotchPayPaymentStatus.parse('rejected'),
          NotchPayPaymentStatus.rejected);
      expect(NotchPayPaymentStatus.parse('expired'),
          NotchPayPaymentStatus.expired);
      expect(NotchPayPaymentStatus.parse(null), NotchPayPaymentStatus.unknown);
    });
  });
}
