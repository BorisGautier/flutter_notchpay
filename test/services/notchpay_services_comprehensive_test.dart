import 'dart:convert';

import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NotchPay Identity & PaymentMethod Services', () {
    test('NotchPayIdentityService.fetch posts to /identity', () async {
      late http.Request captured;
      final service = NotchPayIdentityService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'account_number': '670123456',
                'name': 'John Doe',
                'valid': true,
              }),
              200,
            );
          }),
        ),
      );

      final identity = await service.fetch(
        accountNumber: '670123456',
        country: 'CM',
        type: 'mobile_money',
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/identity');
      expect(identity.accountNumber, '670123456');
      expect(identity.name, 'John Doe');
      expect(identity.valid, isTrue);
    });

    test('NotchPayIdentityService.validate posts to /identity/validate',
        () async {
      late http.Request captured;
      final service = NotchPayIdentityService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'account_number': '670123456',
                'name': 'John Doe',
                'valid': true,
              }),
              200,
            );
          }),
        ),
      );

      final identity = await service.validate(
        accountNumber: '670123456',
        country: 'CM',
        type: 'mobile_money',
        name: 'John Doe',
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/identity/validate');
      expect(identity.valid, isTrue);
    });

    test('NotchPayPaymentMethodService.list returns payment methods', () async {
      final service = NotchPayPaymentMethodService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({
                'payment_methods': [
                  {
                    'reference': 'ref_1',
                    'type': 'card',
                    'brand': 'visa',
                    'last4': '4242',
                  },
                ],
              }),
              200,
            );
          }),
        ),
      );

      final methods = await service.list();
      expect(methods, hasLength(1));
      expect(methods.first.brand, 'visa');
    });

    test('NotchPayPaymentMethodService.fetch returns single payment method',
        () async {
      late http.Request captured;
      final service = NotchPayPaymentMethodService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'payment_method': {
                  'reference': 'ref_1',
                  'type': 'card',
                  'brand': 'mastercard',
                  'last4': '5555',
                },
              }),
              200,
            );
          }),
        ),
      );

      final method = await service.fetch('ref_1');
      expect(captured.url.path, '/payment-methods/ref_1');
      expect(method.brand, 'mastercard');
    });
  });

  group('NotchPayCustomerService Additional Operations', () {
    test('fetch returns single customer by reference', () async {
      late http.Request captured;
      final service = NotchPayCustomerService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'customer': {
                  'reference': 'cus_123',
                  'name': 'Bob',
                  'email': 'bob@example.com',
                },
              }),
              200,
            );
          }),
        ),
      );

      final customer = await service.fetch('cus_123');
      expect(captured.method, 'GET');
      expect(captured.url.path, '/customers/cus_123');
      expect(customer.name, 'Bob');
    });

    test('update posts updated customer payload', () async {
      late http.Request captured;
      final service = NotchPayCustomerService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'customer': {
                  'reference': 'cus_123',
                  'name': 'Bob Updated',
                  'email': 'bob@example.com',
                },
              }),
              200,
            );
          }),
        ),
      );

      final customer = await service.update('cus_123', name: 'Bob Updated');
      expect(captured.method, 'POST');
      expect(captured.url.path, '/customers/cus_123');
      expect(customer.name, 'Bob Updated');
    });

    test('unblock issues PATCH request to unblock customer', () async {
      late http.Request captured;
      final service = NotchPayCustomerService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(jsonEncode({}), 200);
          }),
        ),
      );

      await service.unblock('cus_123');
      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/customers/cus_123/unblock');
    });
  });

  group('Private Key Services Full Operations', () {
    test('NotchPayBalanceService.fetch parses balance list with private key',
        () async {
      final service = NotchPayBalanceService(
        NotchPayClient(
          publicKey: 'pk_test',
          privateKey: 'sk_test',
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({
                'balances': [
                  {
                    'available': 40000.0,
                    'pending': 10000.0,
                    'currency': 'XAF',
                  },
                ],
              }),
              200,
            );
          }),
        ),
      );

      final balances = await service.fetch();
      expect(balances, hasLength(1));
      expect(balances.first.available, 40000.0);
      expect(balances.first.currency, 'XAF');
    });

    test('NotchPayRecipientService create, fetch, and delete', () async {
      late http.Request captured;
      final service = NotchPayRecipientService(
        NotchPayClient(
          publicKey: 'pk_test',
          privateKey: 'sk_test',
          httpClient: MockClient((request) async {
            captured = request;
            if (request.method == 'POST') {
              return http.Response(
                jsonEncode({
                  'recipient': {
                    'reference': 'rec_1',
                    'name': 'Jane',
                  },
                }),
                201,
              );
            }
            if (request.method == 'GET') {
              return http.Response(
                jsonEncode({
                  'recipient': {
                    'reference': 'rec_1',
                    'name': 'Jane',
                  },
                }),
                200,
              );
            }
            return http.Response(jsonEncode({}), 200);
          }),
        ),
      );

      final created = await service.create(
        const NotchPayRecipient(
          reference: 'rec_1',
          name: 'Jane',
          accountNumber: '670000000',
        ),
      );
      expect(created.name, 'Jane');

      final fetched = await service.fetch('rec_1');
      expect(fetched.name, 'Jane');

      await service.delete('rec_1');
      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/beneficiaries/rec_1');
    });

    test('NotchPayTransferService direct, list and fetch', () async {
      final service = NotchPayTransferService(
        NotchPayClient(
          publicKey: 'pk_test',
          privateKey: 'sk_test',
          httpClient: MockClient((request) async {
            if (request.method == 'POST' &&
                request.url.path == '/transfers/direct') {
              return http.Response(
                jsonEncode({
                  'transfer': {
                    'reference': 'trf_1',
                    'amount': 1000.0,
                    'currency': 'XAF',
                    'status': 'complete',
                  },
                }),
                200,
              );
            }
            if (request.method == 'GET' && request.url.path == '/transfers') {
              return http.Response(
                jsonEncode({
                  'transfers': [
                    {
                      'reference': 'trf_1',
                      'amount': 1000.0,
                      'currency': 'XAF',
                      'status': 'complete',
                    },
                  ],
                }),
                200,
              );
            }
            return http.Response(
              jsonEncode({
                'transfer': {
                  'reference': 'trf_1',
                  'amount': 1000.0,
                  'currency': 'XAF',
                  'status': 'complete',
                },
              }),
              200,
            );
          }),
        ),
      );

      final transfer = await service.direct(
        amount: 1000,
        currency: 'XAF',
        channel: 'cm.mobile',
        accountNumber: '670000000',
      );
      expect(transfer.amount, 1000.0);

      final list = await service.list();
      expect(list, hasLength(1));

      final fetched = await service.fetch('trf_1');
      expect(fetched.reference, 'trf_1');
    });

    test('NotchPayRefundService fetch and list', () async {
      final service = NotchPayRefundService(
        NotchPayClient(
          publicKey: 'pk_test',
          privateKey: 'sk_test',
          httpClient: MockClient((request) async {
            if (request.url.path == '/refunds') {
              return http.Response(
                jsonEncode({
                  'refunds': [
                    {
                      'reference': 'ref_1',
                      'amount': 500.0,
                      'currency': 'XAF',
                      'status': 'complete',
                    },
                  ],
                }),
                200,
              );
            }
            return http.Response(
              jsonEncode({
                'refund': {
                  'reference': 'ref_1',
                  'amount': 500.0,
                  'currency': 'XAF',
                  'status': 'complete',
                },
              }),
              200,
            );
          }),
        ),
      );

      final refunds = await service.list();
      expect(refunds, hasLength(1));

      final refund = await service.fetch('ref_1');
      expect(refund.amount, 500.0);
    });

    test('NotchPaySyncService list, fetch, initialize and authorize',
        () async {
      late http.Request captured;
      final service = NotchPaySyncService(
        NotchPayClient(
          publicKey: 'pk_test',
          privateKey: 'sk_test',
          httpClient: MockClient((request) async {
            captured = request;
            if (request.method == 'GET' && request.url.path == '/accounts') {
              return http.Response(
                jsonEncode({
                  'accounts': [
                    {
                      'reference': 'sync_1',
                      'callback': 'https://example.com',
                      'permissions': ['payments'],
                    },
                  ],
                }),
                200,
              );
            }
            return http.Response(
              jsonEncode({
                'account': {
                  'reference': 'sync_1',
                  'callback': 'https://example.com',
                  'permissions': ['payments'],
                },
              }),
              200,
            );
          }),
        ),
      );

      final list = await service.list();
      expect(list, hasLength(1));

      final fetched = await service.fetch('sync_1');
      expect(fetched.reference, 'sync_1');

      final initialized = await service.initialize(
        callback: 'https://example.com',
        permissions: ['payments'],
        profileName: 'Shop 1',
        profileEmail: 'shop1@example.com',
      );
      expect(initialized.reference, 'sync_1');

      await service.authorize('sync_1');
      expect(captured.url.path, '/accounts/sync_1');
      expect(captured.method, 'PATCH');
    });
  });
}
