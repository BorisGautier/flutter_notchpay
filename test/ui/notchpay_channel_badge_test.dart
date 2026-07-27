import 'package:flutter/material.dart';
import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_notchpay/src/ui/widgets/notchpay_channel_badge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the MTN logo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotchPayChannelBadge(kind: NotchPayChannelKind.mtn),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('renders the Orange Money logo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotchPayChannelBadge(kind: NotchPayChannelKind.orange),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('renders a card icon for the card channel', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotchPayChannelBadge(kind: NotchPayChannelKind.card),
      ),
    );
    expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget);
  });
}
