import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture real high-quality screenshots on real target',
      (tester) async {
    var fetchCount = 0;
    final client = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/payments') {
        return http.Response(
          jsonEncode({
            'transaction': {
              'reference': 'trx.screenshot_demo',
              'amount': 5000,
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
              {
                'code': 'cm.orange',
                'name': 'Orange Money',
                'countries': ['CM'],
                'currencies': ['XAF'],
              },
              {
                'code': 'card',
                'name': 'Credit or Debit Card',
                'countries': ['CM'],
                'currencies': ['XAF'],
              },
            ],
          }),
          200,
        );
      }
      if (request.method == 'POST' &&
          request.url.path == '/payments/trx.screenshot_demo') {
        return http.Response(
          jsonEncode({
            'reference': 'trx.screenshot_demo',
            'amount': 5000,
            'currency': 'XAF',
            'status': 'processing',
          }),
          200,
        );
      }
      if (request.method == 'GET' &&
          request.url.path == '/payments/trx.screenshot_demo') {
        fetchCount++;
        return http.Response(
          jsonEncode({
            'reference': 'trx.screenshot_demo',
            'amount': 5000,
            'currency': 'XAF',
            'status': fetchCount > 1 ? 'complete' : 'processing',
          }),
          200,
        );
      }
      return http.Response('{}', 404);
    });

    final notchPay = NotchPay(publicKey: 'pk_test_demo123', httpClient: client);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        home: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Center(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    notchPay.checkout(
                      context,
                      request: const NotchPayCheckoutRequest(
                        amount: 5000,
                        currency: 'XAF',
                        customer: NotchPayCheckoutCustomer(
                          name: 'Boris Gautier',
                          email: 'boris@gautier.me',
                          phone: '+237655728267',
                        ),
                      ),
                    );
                  },
                  child: const Text('Pay 5,000 XAF'),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Helper to save screenshot bytes to disk
    Future<void> saveScreenshot(String filename) async {
      await tester.pumpAndSettle();
      try {
        final bytes = await binding.takeScreenshot(filename);
        final screenshotsDir = Directory('doc/screenshots');
        if (!screenshotsDir.existsSync()) {
          screenshotsDir.createSync(recursive: true);
        }
        final file = File('doc/screenshots/$filename.png');
        await file.writeAsBytes(bytes);
      } catch (e) {
        // Screenshots require host driver binding or local disk write permission.
      }
    }

    // Step 1: Open Checkout Sheet -> Select Channel
    await tester.tap(find.text('Pay 5,000 XAF'));
    await tester.pumpAndSettle();
    await saveScreenshot('01_channel_selection');

    // Step 2: Select MTN Mobile Money -> Mobile Money Phone Input Form
    await tester.tap(find.text('MTN Mobile Money'));
    await tester.pumpAndSettle();
    await saveScreenshot('02_mobile_money_form');

    // Enter phone number
    await tester.enterText(find.byType(TextFormField), '670123456');
    await tester.pumpAndSettle();

    // Step 3: Click Pay Now -> Processing Screen
    await tester.tap(find.text('Pay now'));
    await tester.pump();
    await tester.pump();
    await saveScreenshot('03_processing');

    // Step 4: Wait for polling -> Success Screen
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await saveScreenshot('04_success');

    notchPay.dispose();
  });
}
