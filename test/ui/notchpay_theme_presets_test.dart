// Tests for the ready-made theme presets added in v0.2.0 and the optional
// checkout callbacks (onSuccess / onCancelled / onError).
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// ---------------------------------------------------------------------------
// Theme preset unit tests (pure Dart — no widget pump needed)
// ---------------------------------------------------------------------------

void main() {
  group('NotchPayThemeData presets', () {
    test('darkMode() sets a dark surface and NotchPay violet', () {
      final t = NotchPayThemeData.darkMode();
      expect(t.primaryColor, const Color(0xFF5B2A86));
      expect(t.surfaceColor, const Color(0xFF17181D));
      expect(t.onSurfaceColor, Colors.white);
    });

    test('emerald() sets a green primary on a white surface', () {
      final t = NotchPayThemeData.emerald();
      expect(t.primaryColor, const Color(0xFF059669));
      expect(t.surfaceColor, Colors.white);
      expect(t.successColor, const Color(0xFF047857));
    });

    test('purple() sets deep-purple primary on a near-black surface', () {
      final t = NotchPayThemeData.purple();
      expect(t.primaryColor, const Color(0xFF7C3AED));
      expect(t.surfaceColor, const Color(0xFF0F0A1E));
    });

    test('ocean() sets sky-blue primary on a dark-navy surface', () {
      final t = NotchPayThemeData.ocean();
      expect(t.primaryColor, const Color(0xFF0284C7));
      expect(t.surfaceColor, const Color(0xFF0C1A2E));
    });

    test('all presets keep default error color', () {
      const defaultError = Color(0xFFDC2626);
      expect(NotchPayThemeData.darkMode().errorColor, defaultError);
      expect(NotchPayThemeData.purple().errorColor, defaultError);
      expect(NotchPayThemeData.ocean().errorColor, defaultError);
    });

    test('preset can be further customised with copyWith', () {
      final t = NotchPayThemeData.emerald().copyWith(borderRadius: 32);
      expect(t.borderRadius, 32);
      expect(t.primaryColor, const Color(0xFF059669)); // unchanged
    });
  });

  // -------------------------------------------------------------------------
  // Checkout callback widget tests
  // -------------------------------------------------------------------------

  group('NotchPay.checkout() callbacks', () {
    /// Builds a MockClient that returns:
    ///   - channels: [cm.mtn]
    ///   - initialize: pending transaction
    ///   - complete: processing transaction
    ///   - fetch: [status] transaction
    MockClient makeClient({String fetchStatus = 'complete'}) {
      return MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/channels') {
          return http.Response(
            jsonEncode({
              'channels': [
                {
                  'code': 'cm.mtn',
                  'name': 'MTN Mobile Money',
                  'countries': ['CM'],
                  'currencies': ['XAF'],
                },
              ],
            }),
            200,
          );
        }
        if (request.method == 'POST' && request.url.path == '/payments') {
          return http.Response(
            jsonEncode({
              'transaction': {
                'reference': 'trx.cb',
                'amount': 500,
                'currency': 'XAF',
                'status': 'pending',
              },
            }),
            200,
          );
        }
        if (request.method == 'POST' &&
            request.url.path == '/payments/trx.cb') {
          return http.Response(
            jsonEncode({
              'reference': 'trx.cb',
              'amount': 500,
              'currency': 'XAF',
              'status': 'processing',
            }),
            200,
          );
        }
        if (request.method == 'GET' &&
            request.url.path == '/payments/trx.cb') {
          return http.Response(
            jsonEncode({
              'reference': 'trx.cb',
              'amount': 500,
              'currency': 'XAF',
              'status': fetchStatus,
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      });
    }

    testWidgets('onSuccess is called after a successful payment',
        (tester) async {
      NotchPayPayment? successPayment;
      final notchPay = NotchPay(
        publicKey: 'pk_test',
        httpClient: makeClient(fetchStatus: 'complete'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => notchPay.checkout(
                context,
                request: const NotchPayCheckoutRequest(
                  amount: 500,
                  currency: 'XAF',
                  customer: NotchPayCheckoutCustomer(phone: '+237670123456'),
                ),
                onSuccess: (p) => successPayment = p,
              ),
              child: const Text('Pay'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('MTN Mobile Money'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '670123456');
      await tester.tap(find.text('Pay now'));
      await tester.pump();
      await tester.pump();

      // Advance past polling interval so fetch returns 'complete'.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();

      expect(find.text('Payment successful'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(successPayment, isNotNull);
      expect(successPayment!.reference, 'trx.cb');

      notchPay.dispose();
    });

    testWidgets('onCancelled is called when the sheet is dismissed',
        (tester) async {
      var cancelledCalled = false;
      final notchPay = NotchPay(
        publicKey: 'pk_test',
        httpClient: makeClient(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => notchPay.checkout(
                context,
                request: const NotchPayCheckoutRequest(
                  amount: 500,
                  currency: 'XAF',
                ),
                onCancelled: () => cancelledCalled = true,
              ),
              child: const Text('Pay'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(cancelledCalled, isTrue);

      notchPay.dispose();
    });

    testWidgets('callbacks and Future result are consistent', (tester) async {
      NotchPayCheckoutResult? futureResult;
      var cancelledCalled = false;
      final notchPay = NotchPay(
        publicKey: 'pk_test',
        httpClient: makeClient(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                futureResult = await notchPay.checkout(
                  context,
                  request: const NotchPayCheckoutRequest(
                    amount: 500,
                    currency: 'XAF',
                  ),
                  onCancelled: () => cancelledCalled = true,
                );
              },
              child: const Text('Pay'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Both the callback and the returned Future agree on the outcome.
      expect(cancelledCalled, isTrue);
      expect(futureResult?.status, NotchPayCheckoutStatus.cancelled);

      notchPay.dispose();
    });
  });
}
