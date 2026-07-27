import 'package:flutter_notchpay/flutter_notchpay.dart';
import 'package:flutter_notchpay_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the demo checkout form', (tester) async {
    NotchPay.init(publicKey: 'pk_test_widget_test');

    await tester.pumpWidget(const NotchPayExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Demo checkout'), findsOneWidget);
    expect(find.text('Pay with NotchPay'), findsOneWidget);
  });
}
