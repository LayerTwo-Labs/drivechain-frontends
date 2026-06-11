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

  // Dialogs (fund_group_modal etc.) hand the card bounded screen height. The
  // card must shrink-wrap to its content there, not fill the screen — so the
  // modals don't need to wrap it in IntrinsicHeight.
  testWidgets('SailCard shrink-wraps to content under bounded height', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SailCard(
            title: 'Fund',
            subtitle: 'sub',
            child: const SizedBox(height: 80, width: 400),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    // Content is 80px tall; with header + padding the card stays well under the
    // full ~600px screen. If it filled, this would be ~600.
    expect(tester.getSize(find.byType(SailCard).first).height, lessThan(300));
  });

  // hash_calculator_modal gives the help card an explicit width instead of
  // IntrinsicWidth (the card's internal title row is width:infinity, so it
  // can't hug content on its own).
  testWidgets('SailCard renders at an explicit width in a dialog', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SailCard(
          width: 500,
          title: 'Help',
          withCloseButton: true,
          child: const SizedBox(height: 80, width: 400),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SailCard).first).width, 500);
  });
}
