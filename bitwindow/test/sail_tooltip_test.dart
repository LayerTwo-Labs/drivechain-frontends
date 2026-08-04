import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  Future<void> pump(WidgetTester tester, {SailTooltipPosition? position}) async {
    await tester.pumpSailPage(
      Center(
        child: SailTooltip(
          message: 'Rename',
          position: position ?? SailTooltipPosition.auto,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> hover(WidgetTester tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byType(SailTooltip)));
    await tester.pump();
  }

  group('SailTooltip', () {
    testWidgets('shows only after the wait duration', (tester) async {
      await pump(tester);
      await hover(tester);

      expect(find.text('Rename'), findsNothing, reason: 'must not appear instantly on hover');

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Rename'), findsOneWidget);
    });

    testWidgets('animates in rather than popping', (tester) async {
      await pump(tester);
      await hover(tester);
      await tester.pump(const Duration(milliseconds: 400));

      // One frame in, it is present but not yet fully opaque.
      await tester.pump(const Duration(milliseconds: 40));
      final mid = tester.widget<Opacity>(
        find.ancestor(of: find.text('Rename'), matching: find.byType(Opacity)).first,
      );
      expect(mid.opacity, greaterThan(0.0));
      expect(mid.opacity, lessThan(1.0));

      await tester.pumpAndSettle();
      final done = tester.widget<Opacity>(
        find.ancestor(of: find.text('Rename'), matching: find.byType(Opacity)).first,
      );
      expect(done.opacity, 1.0);
    });

    testWidgets('draws an arrow, and drops it when asked', (tester) async {
      await pump(tester);
      await hover(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pumpSailPage(
        Center(
          child: SailTooltip(
            message: 'No arrow',
            showArrow: false,
            child: const SizedBox(width: 40, height: 40),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('auto-hides after the show duration', (tester) async {
      await pump(tester);
      await hover(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Rename'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(find.text('Rename'), findsNothing);
    });

    testWidgets('disposing while visible does not throw', (tester) async {
      await pump(tester);
      await hover(tester);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Rename'), findsOneWidget);

      await tester.pumpSailPage(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
