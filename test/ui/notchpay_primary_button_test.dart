import 'package:flutter/material.dart';
import 'package:flutter_notchpay/src/ui/theme/notchpay_theme.dart';
import 'package:flutter_notchpay/src/ui/widgets/notchpay_primary_button.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: NotchPayTheme(
      data: NotchPayThemeData.light,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('shows the label and reacts to taps when enabled',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(NotchPayPrimaryButton(
          label: 'Pay now', onPressed: () => tapped = true)),
    );

    expect(find.text('Pay now'), findsOneWidget);
    await tester.tap(find.byType(NotchPayPrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('shows a spinner instead of the label while loading',
      (tester) async {
    await tester.pumpWidget(
      _wrap(NotchPayPrimaryButton(
          label: 'Pay now', loading: true, onPressed: () {})),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Pay now'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('is disabled when onPressed is null', (tester) async {
    await tester.pumpWidget(
        _wrap(const NotchPayPrimaryButton(label: 'Pay now', onPressed: null)));

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
