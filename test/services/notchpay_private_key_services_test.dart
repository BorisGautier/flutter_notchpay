import 'dart:convert';

import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Private-key-only services', () {
    test('NotchPayBalanceService.fetch requires a private key', () {
      final service = NotchPayBalanceService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient:
              MockClient((request) async => http.Response(jsonEncode({}), 200)),
        ),
      );

      expect(service.fetch(), throwsA(isA<NotchPayConfigurationException>()));
    });

    test(
        'NotchPayTransferService.initiate sends X-Grant when a private key is set',
        () async {
      late http.Request captured;
      final service = NotchPayTransferService(
        NotchPayClient(
          publicKey: 'pk_test',
          privateKey: 'sk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'transfer': {
                  'reference': 'trf.abc',
                  'amount': 500,
                  'currency': 'XAF'
                },
              }),
              200,
            );
          }),
        ),
      );

      final transfer = await service.initiate(
        amount: 500,
        currency: 'XAF',
        channel: 'cm.mobile',
        recipient: {
          'account_number': '+237651608133',
          'country': 'CM',
          'name': 'Ada'
        },
      );

      expect(captured.headers['X-Grant'], 'sk_test');
      expect(transfer.reference, 'trf.abc');
    });

    test('NotchPayRecipientService.list requires a private key', () {
      final service = NotchPayRecipientService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient:
              MockClient((request) async => http.Response(jsonEncode({}), 200)),
        ),
      );

      expect(service.list(), throwsA(isA<NotchPayConfigurationException>()));
    });

    test('NotchPayRefundService.list requires a private key', () {
      final service = NotchPayRefundService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient:
              MockClient((request) async => http.Response(jsonEncode({}), 200)),
        ),
      );

      expect(service.list(), throwsA(isA<NotchPayConfigurationException>()));
    });
  });
}
