import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

// Overview's HomepageBuilder puts every SailCard in a SingleChildScrollView,
// so cards must survive unbounded height constraints.
Widget _wrap(Widget child) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(
        SailColorScheme.orange,
        true,
        SailFontValues.inter,
      ),
      child: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SailCard lays out under unbounded height', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SailCard(
          title: 'Latest Transactions',
          subtitle: 'sub',
          child: const SizedBox(height: 300, width: 400),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Latest Transactions'), findsOneWidget);
  });
}
