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
      bool selectable = false,
    }) async {
      final renamed = <String>[];
      final Widget tab = SailTabItem(
        label: 'Key 1',
        isSelected: selected,
        onTap: () {},
        onLabelChanged: renameable ? renamed.add : null,
      );
      await tester.pumpSailPage(
        Center(child: selectable ? SelectionArea(child: tab) : tab),
      );
      await tester.pumpAndSettle();
      return renamed;
    }

    // _startEditing focuses the field. Nothing else in the idle state does.
    bool editing(WidgetTester tester) {
      return tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus ?? false;
    }

    Future<void> doubleClick(WidgetTester tester) async {
      await tester.tap(find.text('Key 1'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('Key 1'));
      await tester.pumpAndSettle();
    }

    // A real user clicks with a mouse, and the pointer drifts a pixel or two.
    // SelectionArea watches for exactly that, so this is the click that broke.
    Future<void> mouseDoubleClick(WidgetTester tester) async {
      final at = tester.getCenter(find.text('Key 1'));
      for (var click = 0; click < 2; click++) {
        final gesture = await tester.startGesture(at, kind: PointerDeviceKind.mouse);
        // A frame passes with the button still down, and the drift lands after
        // it. That is the order a real mouse produces.
        await tester.pump();
        await gesture.moveBy(const Offset(3, 0));
        await tester.pump();
        await gesture.up();
        if (click == 0) {
          await tester.pump(kDoubleTapMinTime);
        }
      }
      await tester.pumpAndSettle();
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

    // enterText focuses the field on its own, so a test that only checks
    // onSubmitted passes with the gesture broken. This one reads edit mode.
    testWidgets('a double-click starts edit mode', (tester) async {
      await pump(tester, selected: true);
      expect(editing(tester), isFalse, reason: 'the tab starts idle');

      await doubleClick(tester);

      expect(editing(tester), isTrue);
    });

    // Every rename site in the app sits inside a SelectionArea. Its pan
    // recognizer wins the gesture arena, which is what broke the rename.
    testWidgets('a double-click starts edit mode inside a SelectionArea', (tester) async {
      final renamed = await pump(tester, selected: true, selectable: true);

      await doubleClick(tester);
      expect(editing(tester), isTrue);

      await tester.enterText(find.byType(TextField), 'Bob cold');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(renamed, ['Bob cold']);
    });

    testWidgets('a mouse double-click starts edit mode inside a SelectionArea', (tester) async {
      await pump(tester, selected: true, selectable: true);

      await mouseDoubleClick(tester);

      expect(editing(tester), isTrue);
    });

    // A drag over the label selects text. A click that lands near the start of
    // that drag is a second click, not the second half of a double-click.
    testWidgets('a drag then a click does not rename', (tester) async {
      await pump(tester, selected: true, selectable: true);

      final at = tester.getCenter(find.text('Key 1'));
      final drag = await tester.startGesture(at, kind: PointerDeviceKind.mouse);
      await tester.pump();
      await drag.moveBy(const Offset(40, 0));
      await tester.pump();
      await drag.up();
      await tester.pump(kDoubleTapMinTime);

      final click = await tester.startGesture(at, kind: PointerDeviceKind.mouse);
      await click.up();
      await tester.pumpAndSettle();

      expect(editing(tester), isFalse);
    });

    // A canceled press never reaches the user, so it cannot count as a click.
    testWidgets('a canceled second press does not rename', (tester) async {
      await pump(tester, selected: true, selectable: true);

      final at = tester.getCenter(find.text('Key 1'));
      final first = await tester.startGesture(at, kind: PointerDeviceKind.mouse);
      await first.up();
      await tester.pump(kDoubleTapMinTime);

      final second = await tester.startGesture(at, kind: PointerDeviceKind.mouse);
      await second.cancel();
      await tester.pumpAndSettle();

      expect(editing(tester), isFalse);
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
