import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

// SailMenuBar is the Windows/Linux path of CrossPlatformMenuBar; whatever it
// fails to walk out of the PlatformMenu tree is unreachable on those platforms.
void main() {
  Widget host(List<PlatformMenuItem> menus) => SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: MaterialApp(
      home: Scaffold(
        body: SailMenuBar(menus: menus, child: const SizedBox()),
      ),
    ),
  );

  PlatformMenuItem leaf(String label, {bool enabled = true}) =>
      PlatformMenuItem(label: label, onSelected: enabled ? () {} : null);

  testWidgets('renders a top-level menu button per menu', (tester) async {
    await tester.pumpWidget(
      host([
        PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItemGroup(members: [leaf('New Window')]),
          ],
        ),
        PlatformMenu(
          label: 'View',
          menus: [
            PlatformMenuItemGroup(members: [leaf('Zoom In')]),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('File'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
  });

  testWidgets('a nested menu keeps its children reachable', (tester) async {
    await tester.pumpWidget(
      host([
        PlatformMenu(
          label: 'Use Bitcoin',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenu(
                  label: 'Blockchain Data Storage',
                  menus: [leaf('OP_RETURN Graffiti'), leaf('BitDrive')],
                ),
              ],
            ),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use Bitcoin'));
    await tester.pumpAndSettle();

    expect(find.text('Blockchain Data Storage'), findsOneWidget);
    expect(find.text('OP_RETURN Graffiti'), findsOneWidget, reason: 'nested items must not be dropped');
    expect(find.text('BitDrive'), findsOneWidget);
  });

  testWidgets('an item declared outside a group still renders', (tester) async {
    await tester.pumpWidget(
      host([
        PlatformMenu(label: 'Tools', menus: [leaf('Hash Calculator')]),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();

    expect(find.text('Hash Calculator'), findsOneWidget);
  });

  testWidgets('a disabled item renders without a callback', (tester) async {
    await tester.pumpWidget(
      host([
        PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItemGroup(members: [leaf('Enabled'), leaf('Disabled', enabled: false)]),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();

    expect(find.text('Enabled'), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);
  });
}
