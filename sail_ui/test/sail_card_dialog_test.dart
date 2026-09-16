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

Widget _dialogHost(void Function(BuildContext) open) {
  return MaterialApp(
    builder: (context, child) => SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: child ?? const SizedBox(),
    ),
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () => open(context),
        child: const Text('open'),
      ),
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

  // Every app dialog hands the card a SailColumn, which defaults to
  // MainAxisSize.max. The dialog must still hug its content.
  testWidgets('widgetDialog hugs a max-height column', (tester) async {
    await tester.pumpWidget(
      _dialogHost(
        (context) => widgetDialog(
          context: context,
          title: 'Switch to light mode',
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: const [
              Text('BitWindow stops Bitcoin Core and the local enforcer.'),
              Text('No wallet and no key is deleted.'),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SailCard).first).height, lessThan(300));
  });

  testWidgets('SailDialog hugs a short body', (tester) async {
    await tester.pumpWidget(
      _dialogHost(
        (context) => showThemedDialog(
          context: context,
          builder: (context) => const SailDialog(
            title: 'Update Available',
            child: Text('A new version is available.'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SailCard).first).height, lessThan(300));
  });

  testWidgets('widgetDialog scrolls content taller than the screen', (tester) async {
    await tester.pumpWidget(
      _dialogHost(
        (context) => widgetDialog(
          context: context,
          title: 'Long',
          child: SailColumn(
            children: List.generate(60, (i) => SizedBox(height: 40, child: Text('row $i'))),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
    expect(tester.getSize(find.byType(SailCard).first).height, greaterThan(600));
  });
}
