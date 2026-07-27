import 'dart:convert';

import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NotchPayPaymentService', () {
    test('initialize posts the checkout request and parses the response',
        () async {
      late http.Request captured;
      final service = NotchPayPaymentService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'transaction': {
                  'reference': 'trx.abc',
                  'amount': 100,
                  'currency': 'XAF',
                  'status': 'pending',
                },
              }),
              200,
            );
          }),
        ),
      );

      final payment = await service.initialize(
        const NotchPayCheckoutRequest(
          amount: 100,
          currency: 'XAF',
          description: 'ddd',
          customer: NotchPayCheckoutCustomer(phone: '+237655728267'),
        ),
      );

      expect(captured.url.path, '/payments');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['amount'], 100);
      expect(body['currency'], 'XAF');
      expect(payment.reference, 'trx.abc');
      expect(payment.status, NotchPayPaymentStatus.pending);
    });

    test('complete submits the channel and data payload', () async {
      late http.Request captured;
      final service = NotchPayPaymentService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'reference': 'trx.abc',
                'amount': 100,
                'currency': 'XAF',
                'status': 'processing',
              }),
              200,
            );
          }),
        ),
      );

      final payment = await service.complete(
        'trx.abc',
        channel: 'cm.mobile',
        data: {'phone': '+237655728267'},
      );

      expect(captured.url.path, '/payments/trx.abc');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['channel'], 'cm.mobile');
      expect(body['data'], {'phone': '+237655728267'});
      expect(payment.status, NotchPayPaymentStatus.processing);
    });

    test('fetch returns the current transaction state', () async {
      final service = NotchPayPaymentService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({
                'reference': 'trx.abc',
                'amount': 100,
                'currency': 'XAF',
                'status': 'complete',
              }),
              200,
            );
          }),
        ),
      );

      final payment = await service.fetch('trx.abc');
      expect(payment.status.isSuccess, isTrue);
    });

    test('list filters by status and channels', () async {
      late Uri capturedUri;
      final service = NotchPayPaymentService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(jsonEncode({'transactions': []}), 200);
          }),
        ),
      );

      await service
          .list(status: NotchPayPaymentStatus.complete, channels: ['cm.mtn']);

      expect(capturedUri.queryParameters['status'], 'complete');
      expect(capturedUri.queryParameters['channels[0]'], 'cm.mtn');
    });

    test('cancel issues a DELETE request', () async {
      late http.Request captured;
      final service = NotchPayPaymentService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(jsonEncode({}), 200);
          }),
        ),
      );

      await service.cancel('trx.abc');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/payments/trx.abc');
    });
  });
}
