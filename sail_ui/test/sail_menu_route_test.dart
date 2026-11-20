import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  Future<List<String>> pickFromMenu(WidgetTester tester, {required bool closeOnSelect}) async {
    final picked = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSailMenu(
                  context: context,
                  preferredAnchorPoint: const Offset(20, 20),
                  menu: SailMenu(
                    items: [
                      SailMenuItem(
                        closeOnSelect: closeOnSelect,
                        onSelected: () => picked.add('details'),
                        child: const Text('Show Details'),
                      ),
                    ],
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Details'));
    await tester.pumpAndSettle();
    return picked;
  }

  testWidgets('on a phone a menu item closes its menu', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;

    expect(await pickFromMenu(tester, closeOnSelect: true), ['details']);
    expect(find.text('Show Details'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('on a phone an item that keeps its menu leaves it open', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;

    expect(await pickFromMenu(tester, closeOnSelect: false), ['details']);
    expect(find.text('Show Details'), findsOneWidget);
  });

  testWidgets('on the desktop the menu stays as before', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;

    expect(await pickFromMenu(tester, closeOnSelect: true), ['details']);
    expect(find.text('Show Details'), findsOneWidget);
  });
}
