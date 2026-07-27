import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NotchPay', () {
    test('instance throws a configuration error before init() is called', () {
      expect(NotchPay.isInitialized, isFalse);
      expect(() => NotchPay.instance,
          throwsA(isA<NotchPayConfigurationException>()));
    });

    test('init() configures the shared instance', () {
      NotchPay.init(publicKey: 'pk_test_123');

      expect(NotchPay.isInitialized, isTrue);
      expect(NotchPay.instance, same(NotchPay.instance));
    });

    test('a standalone instance exposes every service', () {
      final notchPay = NotchPay(
        publicKey: 'pk_test_123',
        httpClient: MockClient((request) async => http.Response('{}', 200)),
      );

      expect(notchPay.customers, isA<NotchPayCustomerService>());
      expect(notchPay.payments, isA<NotchPayPaymentService>());
      expect(notchPay.resources, isA<NotchPayResourceService>());
      expect(notchPay.paymentMethods, isA<NotchPayPaymentMethodService>());
      expect(notchPay.recipients, isA<NotchPayRecipientService>());
      expect(notchPay.transfers, isA<NotchPayTransferService>());
      expect(notchPay.refunds, isA<NotchPayRefundService>());
      expect(notchPay.balance, isA<NotchPayBalanceService>());
      expect(notchPay.sync, isA<NotchPaySyncService>());
      expect(notchPay.identity, isA<NotchPayIdentityService>());

      notchPay.dispose();
    });
  });
}
