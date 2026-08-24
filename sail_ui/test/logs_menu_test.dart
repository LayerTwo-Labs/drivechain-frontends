import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  test('the menu item names the file manager of this platform', () {
    final item = openLogsMenuItem();

    expect(item.label, openLogsLabel());
    expect(item.label, contains(fileManagerName()));
    expect(item.onSelected, isNotNull);
  });

  testWidgets('the menu bar shows the item', (tester) async {
    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: MaterialApp(
          home: Scaffold(
            body: SailMenuBar(
              menus: [
                PlatformMenu(
                  label: 'This Node',
                  menus: [
                    PlatformMenuItemGroup(members: [openLogsMenuItem()]),
                  ],
                ),
              ],
              child: const SizedBox(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('This Node'));
    await tester.pumpAndSettle();

    expect(find.text(openLogsLabel()), findsOneWidget);
  });
}
