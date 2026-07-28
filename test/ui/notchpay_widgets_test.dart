import 'package:flutter/material.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_notchpay/src/ui/widgets/notchpay_channel_grid.dart';
import 'package:flutter_notchpay/src/ui/widgets/notchpay_email_form.dart';
import 'package:flutter_notchpay/src/ui/widgets/notchpay_mobile_money_form.dart';
import 'package:flutter_notchpay/src/ui/widgets/notchpay_status_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotchPay UI Widgets Unit Tests', () {
    testWidgets('NotchPayMobileMoneyForm validates, formats and submits',
        (tester) async {
      String? submittedPhone;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotchPayTheme(
              data: const NotchPayThemeData(),
              child: NotchPayMobileMoneyForm(
                initialKind: NotchPayChannelKind.mtn,
                loading: false,
                countryCode: 'cm',
                onSubmit: (phone) => submittedPhone = phone,
              ),
            ),
          ),
        ),
      );

      // Verify hint & field present
      expect(find.byType(TextFormField), findsOneWidget);

      // Submit empty => validation error
      await tester.tap(find.text('Pay now'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your phone number'), findsOneWidget);

      // Enter valid number
      await tester.enterText(find.byType(TextFormField), '670123456');
      await tester.tap(find.text('Pay now'));
      await tester.pumpAndSettle();

      expect(submittedPhone, '+237670123456');
    });

    testWidgets('NotchPayMobileMoneyForm formats correctly for Ivory Coast (ci)',
        (tester) async {
      String? submittedPhone;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotchPayTheme(
              data: const NotchPayThemeData(),
              child: NotchPayMobileMoneyForm(
                initialKind: NotchPayChannelKind.wave,
                loading: false,
                countryCode: 'ci',
                onSubmit: (phone) => submittedPhone = phone,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '0707123456');
      await tester.tap(find.text('Pay now'));
      await tester.pumpAndSettle();

      expect(submittedPhone, '+225707123456');
    });

    testWidgets('NotchPayEmailForm validates email and submits', (tester) async {
      String? submittedEmail;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotchPayTheme(
              data: const NotchPayThemeData(),
              child: NotchPayEmailForm(
                initialKind: NotchPayChannelKind.card,
                loading: false,
                initialEmail: 'test@example.com',
                onSubmit: (email) => submittedEmail = email,
              ),
            ),
          ),
        ),
      );

      expect(find.text('test@example.com'), findsOneWidget);

      await tester.tap(find.text('Continue to payment'));
      await tester.pumpAndSettle();

      expect(submittedEmail, 'test@example.com');
    });

    testWidgets('NotchPayEmailForm rejects invalid email', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotchPayTheme(
              data: const NotchPayThemeData(),
              child: NotchPayEmailForm(
                initialKind: NotchPayChannelKind.card,
                loading: false,
                onSubmit: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      await tester.tap(find.text('Continue to payment'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('NotchPayResultView renders success state and handles done tap',
        (tester) async {
      var doneTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotchPayTheme(
              data: const NotchPayThemeData(),
              child: NotchPayResultView(
                success: true,
                title: 'Payment Successful',
                message: 'Your order is confirmed',
                onDone: () => doneTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Payment Successful'), findsOneWidget);
      expect(find.text('Your order is confirmed'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.tap(find.text('Done'));
      expect(doneTapped, isTrue);
    });

    testWidgets('NotchPayResultView renders failure state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotchPayTheme(
              data: const NotchPayThemeData(),
              child: NotchPayResultView(
                success: false,
                title: 'Payment Failed',
                message: 'Insufficient balance',
                onDone: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Payment Failed'), findsOneWidget);
      expect(find.text('Insufficient balance'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('NotchPayProcessingView renders message correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotchPayTheme(
              data: const NotchPayThemeData(),
              child: const NotchPayProcessingView(
                message: 'Dial *126# on your phone to confirm',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Dial *126# on your phone to confirm'), findsOneWidget);
      expect(find.byIcon(Icons.phone_iphone_rounded), findsOneWidget);

      // Animate 1 frame to verify ticker
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('NotchPayChannelGrid renders channel items and handles tap',
        (tester) async {
      NotchPayChannel? selected;
      const channels = [
        NotchPayChannel(
          code: 'cm.mtn',
          name: 'MTN Mobile Money',
          countries: ['CM'],
          currencies: ['XAF'],
        ),
        NotchPayChannel(
          code: 'card',
          name: 'Credit Card',
          countries: ['CM'],
          currencies: ['XAF'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotchPayTheme(
              data: const NotchPayThemeData(),
              child: NotchPayChannelGrid(
                channels: channels,
                onSelected: (ch) => selected = ch,
              ),
            ),
          ),
        ),
      );

      expect(find.text('MTN Mobile Money'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);

      await tester.tap(find.text('Credit Card'));
      expect(selected?.code, 'card');
    });

    test('NotchPayThemeData equality and hashCode work as expected', () {
      const t1 = NotchPayThemeData(primaryColor: Color(0xFF123456));
      const t2 = NotchPayThemeData(primaryColor: Color(0xFF123456));
      const t3 = NotchPayThemeData(primaryColor: Color(0xFF654321));

      expect(t1, equals(t2));
      expect(t1.hashCode, equals(t2.hashCode));
      expect(t1, isNot(equals(t3)));
    });
  });
}
