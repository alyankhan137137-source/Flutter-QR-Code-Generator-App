import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_all_project/main.dart';

void main() {
  testWidgets('ProQrApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProQrApp());

    // Verify that Generator title is present.
    expect(find.text('QR Generator'), findsOneWidget);
  });
}
