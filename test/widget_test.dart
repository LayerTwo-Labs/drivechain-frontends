// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sidesail/pages/tabs/home_page.dart';

import 'test_utils.dart';

void main() {
  testWidgets('RPC submit smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpSailPage(
      const HomePage(),
    );

    // Verify that there's a submit button.
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text('SideSail'), findsOneWidget);

    // TODO: something more meaningful. Would have to mock the RPC interfaces
  });
}
