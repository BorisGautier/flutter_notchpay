import 'dart:convert';

import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NotchPayClient', () {
    test('sends the public key as the Authorization header', () async {
      late http.Request captured;
      final client = NotchPayClient(
        publicKey: 'pk_test_123',
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );

      await client.get('/hello');

      expect(captured.headers['Authorization'], 'pk_test_123');
      expect(captured.headers['X-Grant'], isNull);
    });

    test('builds the request URL with query parameters', () async {
      late Uri capturedUri;
      final client = NotchPayClient(
        publicKey: 'pk_test_123',
        httpClient: MockClient((request) async {
          capturedUri = request.url;
          return http.Response(jsonEncode({}), 200);
        }),
      );

      await client.get('/channels', query: {'country': 'cm', 'ignored': null});

      expect(capturedUri.path, '/channels');
      expect(capturedUri.queryParameters, {'country': 'cm'});
    });

    test('serializes iterable query parameters as indexed keys', () async {
      late Uri capturedUri;
      final client = NotchPayClient(
        publicKey: 'pk_test_123',
        httpClient: MockClient((request) async {
          capturedUri = request.url;
          return http.Response(jsonEncode({}), 200);
        }),
      );

      await client.get('/payments', query: {
        'channels': ['cm.mtn', 'cm.orange'],
      });

      expect(capturedUri.queryParameters['channels[0]'], 'cm.mtn');
      expect(capturedUri.queryParameters['channels[1]'], 'cm.orange');
    });

    test('prunes null values from the JSON body', () async {
      late String capturedBody;
      final client = NotchPayClient(
        publicKey: 'pk_test_123',
        httpClient: MockClient((request) async {
          capturedBody = request.body;
          return http.Response(jsonEncode({}), 200);
        }),
      );

      await client.post('/customers', body: {'name': 'Ada', 'email': null});

      expect(jsonDecode(capturedBody), {'name': 'Ada'});
    });

    test('decodes a successful response body', () async {
      final client = NotchPayClient(
        publicKey: 'pk_test_123',
        httpClient: MockClient((request) async {
          return http.Response(
              jsonEncode({
                'transaction': {'reference': 'trx.abc'}
              }),
              200);
        }),
      );

      final result = await client.get('/payments/trx.abc');

      expect(result['transaction'], {'reference': 'trx.abc'});
    });

    test('throws NotchPayApiException for non-2xx responses', () async {
      final client = NotchPayClient(
        publicKey: 'pk_test_123',
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode(
                {'message': 'Invalid phone number', 'code': 'invalid_phone'}),
            422,
          );
        }),
      );

      expect(
        () => client.get('/payments/trx.abc'),
        throwsA(
          isA<NotchPayApiException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.message, 'message', 'Invalid phone number')
              .having((e) => e.code, 'code', 'invalid_phone')
              .having((e) => e.isValidationError, 'isValidationError', isTrue),
        ),
      );
    });

    test('throws NotchPayNetworkException when the request throws', () async {
      final client = NotchPayClient(
        publicKey: 'pk_test_123',
        httpClient: MockClient((request) async {
          throw const SocketExceptionStub();
        }),
      );

      expect(client.get('/payments'), throwsA(isA<NotchPayNetworkException>()));
    });

    test(
        'throws NotchPayConfigurationException when a grant is required '
        'but no private key was provided', () async {
      final client = NotchPayClient(
        publicKey: 'pk_test_123',
        httpClient:
            MockClient((request) async => http.Response(jsonEncode({}), 200)),
      );

      expect(
        () => client.get('/balance', requiresGrant: true),
        throwsA(isA<NotchPayConfigurationException>()),
      );
    });

    test('sends the private key as X-Grant when required and configured',
        () async {
      late http.Request captured;
      final client = NotchPayClient(
        publicKey: 'pk_test_123',
        privateKey: 'sk_test_456',
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(jsonEncode({}), 200);
        }),
      );

      await client.get('/balance', requiresGrant: true);

      expect(captured.headers['X-Grant'], 'sk_test_456');
      expect(captured.headers['Authorization'], 'pk_test_123');
    });
  });
}

/// A minimal stand-in for a low level I/O error, avoiding a dependency on
/// `dart:io` types that aren't available on every platform this package
/// targets.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();

  @override
  String toString() => 'SocketExceptionStub: no network';
}
