import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // fund_group_modal.dart wraps SailCard in IntrinsicHeight.
  testWidgets('SailCard inside IntrinsicHeight', (tester) async {
    await tester.pumpWidget(
      _wrap(
        IntrinsicHeight(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SailCard(
              title: 'Fund',
              subtitle: 'sub',
              child: const SizedBox(height: 80, width: 400),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  // hash_calculator_modal.dart wraps SailCard in IntrinsicWidth.
  testWidgets('SailCard inside IntrinsicWidth', (tester) async {
    await tester.pumpWidget(
      _wrap(
        IntrinsicWidth(
          child: SailCard(
            title: 'Help',
            withCloseButton: true,
            child: const SizedBox(height: 80, width: 400),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
