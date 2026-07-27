import 'dart:convert';

import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NotchPayCustomerService', () {
    test('create posts the customer payload', () async {
      late http.Request captured;
      final service = NotchPayCustomerService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response(
              jsonEncode({
                'customer': {'reference': 'cus.abc', 'name': 'Ada Lovelace'},
              }),
              201,
            );
          }),
        ),
      );

      final customer =
          await service.create(name: 'Ada Lovelace', email: 'ada@example.com');

      expect(captured.method, 'POST');
      expect(captured.url.path, '/customers');
      expect(customer.reference, 'cus.abc');
      expect(customer.name, 'Ada Lovelace');
    });

    test('list returns customers from the `customers` key', () async {
      final service = NotchPayCustomerService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({
                'customers': [
                  {'reference': 'cus.a', 'name': 'A'},
                  {'reference': 'cus.b', 'name': 'B'},
                ],
              }),
              200,
            );
          }),
        ),
      );

      final customers = await service.list(limit: 3, page: 7);
      expect(customers, hasLength(2));
      expect(customers.first.reference, 'cus.a');
    });

    test('block posts to the block endpoint', () async {
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

      await service.block('cus.abc');

      expect(captured.method, 'POST');
      expect(captured.url.path, '/customers/cus.abc/block');
    });

    test('delete issues a DELETE request', () async {
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

      await service.delete('cus.abc');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/customers/cus.abc');
    });
  });
}
