import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPayCheckoutRequest', () {
    test('serializes the customer and metadata', () {
      const request = NotchPayCheckoutRequest(
        amount: 1500,
        currency: 'XAF',
        description: 'Order #4831',
        customer: NotchPayCheckoutCustomer(phone: '+237655728267'),
        metadata: {'orderId': '4831'},
      );

      expect(request.toJson(), {
        'amount': 1500,
        'currency': 'XAF',
        'description': 'Order #4831',
        'customer': {'phone': '+237655728267'},
        'metadata': {'orderId': '4831'},
      });
    });

    test('rejects a zero or negative amount', () {
      expect(
        () => NotchPayCheckoutRequest(amount: 0, currency: 'XAF'),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('NotchPayCheckoutCustomer', () {
    test('requires at least one field', () {
      // Deliberately not `const` here: a failing assert in a const
      // constructor invocation is a compile-time error, not a catchable
      // runtime AssertionError.
      expect(NotchPayCheckoutCustomer.new, throwsA(isA<AssertionError>()));
    });
  });

  group('NotchPayCheckoutResult', () {
    test('success wraps the payment and reports isSuccess', () {
      final payment = NotchPayPayment.fromJson({
        'reference': 'trx.abc',
        'amount': 100,
        'currency': 'XAF',
        'status': 'complete',
      });
      final result = NotchPayCheckoutResult.success(payment);

      expect(result.status, NotchPayCheckoutStatus.success);
      expect(result.isSuccess, isTrue);
      expect(result.payment, payment);
    });

    test('cancelled and failed report isSuccess false', () {
      const cancelled = NotchPayCheckoutResult.cancelled();
      const failed = NotchPayCheckoutResult.failed('boom');

      expect(cancelled.isSuccess, isFalse);
      expect(failed.isSuccess, isFalse);
      expect(failed.message, 'boom');
    });
  });
}
