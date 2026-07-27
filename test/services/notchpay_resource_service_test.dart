import 'dart:convert';

import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NotchPayResourceService', () {
    test('channels filters by country and parses the list', () async {
      late Uri capturedUri;
      final service = NotchPayResourceService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            return http.Response(
              jsonEncode({
                'channels': [
                  {'code': 'cm.mtn', 'name': 'MTN Mobile Money'},
                  {'code': 'cm.orange', 'name': 'Orange Money'},
                ],
              }),
              200,
            );
          }),
        ),
      );

      final channels = await service.channels(country: 'cm');

      expect(capturedUri.queryParameters['country'], 'CM');
      expect(channels, hasLength(2));
      expect(channels.first.kind, NotchPayChannelKind.mtn);
    });

    test('currencies parses the list', () async {
      final service = NotchPayResourceService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({
                'currencies': [
                  {'code': 'XAF'},
                ],
              }),
              200,
            );
          }),
        ),
      );

      final currencies = await service.currencies();
      expect(currencies.single.code, 'XAF');
    });

    test('countries parses the list', () async {
      final service = NotchPayResourceService(
        NotchPayClient(
          publicKey: 'pk_test',
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({
                'countries': [
                  {'code': 'CM', 'currency': 'XAF'},
                ],
              }),
              200,
            );
          }),
        ),
      );

      final countries = await service.countries();
      expect(countries.single.code, 'CM');
      expect(countries.single.currency, 'XAF');
    });
  });
}
