import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  group('SailTabItem rename', () {
    Future<List<String>> pump(
      WidgetTester tester, {
      required bool selected,
      bool renameable = true,
    }) async {
      final renamed = <String>[];
      await tester.pumpSailPage(
        Center(
          child: SailTabItem(
            label: 'Key 1',
            isSelected: selected,
            onTap: () {},
            onLabelChanged: renameable ? renamed.add : null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return renamed;
    }

    testWidgets('a double-click on the selected tab renames it', (tester) async {
      final renamed = await pump(tester, selected: true);

      await tester.tap(find.text('Key 1'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('Key 1'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Bob cold');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(renamed, ['Bob cold']);
    });

    testWidgets('a right-click renames it too', (tester) async {
      final renamed = await pump(tester, selected: true);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Key 1')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Alice ledger');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(renamed, ['Alice ledger']);
    });

    testWidgets('shows no pencil, since the design has none', (tester) async {
      await pump(tester, selected: true);
      expect(find.byType(SailTappable), findsNothing);
    });

    testWidgets('an unselected tab shows no rename affordance', (tester) async {
      await pump(tester, selected: false);

      expect(find.byType(SailEditableText), findsNothing);
      expect(find.text('Key 1'), findsOneWidget);
    });

    testWidgets('a tab without onLabelChanged stays plain text', (tester) async {
      await pump(tester, selected: true, renameable: false);

      expect(find.byType(SailEditableText), findsNothing);
      expect(find.text('Key 1'), findsOneWidget);
    });
  });
}
