import 'package:flutter_test/flutter_test.dart';
import 'package:smartspend_frontend/main.dart';

void main() {
  testWidgets('SmartSpend app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartSpendApp());
    expect(find.text('SmartSpend'), findsOneWidget);
  });
}
