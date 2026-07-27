// End-to-end integration test exercising the full checkout flow: it drives
// the real NotchPay facade, the real checkout sheet widgets, and a fake
// NotchPay backend (via `MockClient`) together, the same way a real app
// would use this package.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('completes a Mobile Money payment end-to-end', (tester) async {
    var completeCalls = 0;
    var fetchCalls = 0;

    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/payments') {
        return http.Response(
          jsonEncode({
            'transaction': {
              'reference': 'trx.test',
              'amount': 1500,
              'currency': 'XAF',
              'status': 'pending',
            },
          }),
          200,
        );
      }
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
      if (request.method == 'POST' &&
          request.url.path == '/payments/trx.test') {
        completeCalls++;
        return http.Response(
          jsonEncode({
            'reference': 'trx.test',
            'amount': 1500,
            'currency': 'XAF',
            'status': 'processing',
          }),
          200,
        );
      }
      if (request.method == 'GET' && request.url.path == '/payments/trx.test') {
        fetchCalls++;
        return http.Response(
          jsonEncode({
            'reference': 'trx.test',
            'amount': 1500,
            'currency': 'XAF',
            'status': 'complete',
          }),
          200,
        );
      }
      return http.Response('{}', 404);
    });

    final notchPay = NotchPay(publicKey: 'pk_test', httpClient: client);
    NotchPayCheckoutResult? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await notchPay.checkout(
                  context,
                  request: const NotchPayCheckoutRequest(
                    amount: 1500,
                    currency: 'XAF',
                    customer: NotchPayCheckoutCustomer(phone: '+237655728267'),
                  ),
                );
              },
              child: const Text('Pay'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Pay'));
    await tester.pumpAndSettle();

    // Step 1: channel selection.
    expect(find.text('MTN Mobile Money'), findsOneWidget);
    await tester.tap(find.text('MTN Mobile Money'));
    await tester.pumpAndSettle();

    // Step 2: Mobile Money phone form.
    expect(find.text('Mobile money number'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '670123456');
    await tester.tap(find.text('Pay now'));
    // The processing screen runs an infinitely repeating ripple animation,
    // so `pumpAndSettle` (which waits for the widget tree to go idle) would
    // never return here. Advance frames explicitly instead.
    await tester.pump();
    await tester.pump();

    expect(completeCalls, 1);
    expect(find.text('Confirm on your phone'), findsOneWidget);

    // Step 3: the sheet polls for the final status every few seconds.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(fetchCalls, greaterThan(0));
    expect(find.text('Payment successful'), findsOneWidget);

    // The result screen is static (no repeating animation), so settling is
    // safe again from this point on.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.isSuccess, isTrue);
    expect(result!.payment?.reference, 'trx.test');

    notchPay.dispose();
  });

  testWidgets('reports a cancelled result when the sheet is dismissed',
      (tester) async {
    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/payments') {
        return http.Response(
          jsonEncode({
            'transaction': {
              'reference': 'trx.test',
              'amount': 500,
              'currency': 'XAF',
              'status': 'pending',
            },
          }),
          200,
        );
      }
      if (request.method == 'GET' && request.url.path == '/channels') {
        return http.Response(
            jsonEncode({'channels': <Map<String, dynamic>>[]}), 200);
      }
      return http.Response('{}', 404);
    });

    final notchPay = NotchPay(publicKey: 'pk_test', httpClient: client);
    NotchPayCheckoutResult? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await notchPay.checkout(
                  context,
                  request: const NotchPayCheckoutRequest(
                      amount: 500, currency: 'XAF'),
                );
              },
              child: const Text('Pay'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Pay'));
    await tester.pumpAndSettle();

    // Close the sheet via the close (X) button.
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.status, NotchPayCheckoutStatus.cancelled);

    notchPay.dispose();
  });

  testWidgets('shows a sandbox banner only when the public key is a test key',
      (tester) async {
    Future<http.Response> handler(http.Request request) async {
      if (request.method == 'POST' && request.url.path == '/payments') {
        return http.Response(
          jsonEncode({
            'transaction': {
              'reference': 'trx.test',
              'amount': 500,
              'currency': 'XAF',
              'status': 'pending',
            },
          }),
          200,
        );
      }
      if (request.method == 'GET' && request.url.path == '/channels') {
        return http.Response(
          jsonEncode({'channels': <Map<String, dynamic>>[]}),
          200,
        );
      }
      return http.Response('{}', 404);
    }

    Future<void> openSheet(WidgetTester tester, NotchPay notchPay) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  notchPay.checkout(
                    context,
                    request: const NotchPayCheckoutRequest(
                        amount: 500, currency: 'XAF'),
                  );
                },
                child: const Text('Pay'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Pay'));
      await tester.pumpAndSettle();
    }

    final sandboxNotchPay =
        NotchPay(publicKey: 'pk_test_123', httpClient: MockClient(handler));
    await openSheet(tester, sandboxNotchPay);
    expect(find.textContaining('Sandbox mode'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    sandboxNotchPay.dispose();

    final liveNotchPay =
        NotchPay(publicKey: 'pk_live_123', httpClient: MockClient(handler));
    await openSheet(tester, liveNotchPay);
    expect(find.textContaining('Sandbox mode'), findsNothing);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    liveNotchPay.dispose();
  });
}
