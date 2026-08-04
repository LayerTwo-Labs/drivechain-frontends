import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  Future<void> pump(WidgetTester tester, Widget slider) async {
    await tester.pumpSailPage(
      Center(child: SizedBox(width: 414, child: slider)),
    );
    await tester.pumpAndSettle();
  }

  group('SailSlider', () {
    testWidgets('snaps a tap to the nearest division', (tester) async {
      final emitted = <double>[];
      await pump(
        tester,
        SailSlider(value: 4, min: 0, max: 8, divisions: 8, onChanged: emitted.add),
      );

      // Just right of the 5/8 stop; it must land exactly on 5, not in between.
      final box = tester.getRect(find.byType(SailSlider));
      await tester.tapAt(Offset(box.left + 10 + (394 * 5 / 8) + 3, box.center.dy));
      await tester.pumpAndSettle();

      expect(emitted, [5.0]);
    });

    testWidgets('showSteps hides the dots without disabling snapping', (tester) async {
      final emitted = <double>[];
      await pump(
        tester,
        SailSlider(
          value: 4,
          min: 0,
          max: 8,
          divisions: 8,
          showSteps: false,
          onChanged: emitted.add,
        ),
      );

      final box = tester.getRect(find.byType(SailSlider));
      await tester.tapAt(Offset(box.left + 10 + (394 * 5 / 8) + 3, box.center.dy));
      await tester.pumpAndSettle();

      expect(emitted, [5.0], reason: 'snapping is driven by divisions, not by showSteps');
    });

    testWidgets('the label renders below the track', (tester) async {
      await pump(
        tester,
        SailSlider(
          value: 2,
          min: 1,
          max: 15,
          divisions: 14,
          onChanged: (_) {},
          label: 'Require 2 signatures to move funds, out of 3 keys total',
        ),
      );

      expect(find.text('Require 2 signatures to move funds, out of 3 keys total'), findsOneWidget);
    });

    testWidgets('range keeps start below end when dragged past it', (tester) async {
      final emitted = <List<double>>[];
      await pump(
        tester,
        SailSlider.range(
          rangeStart: 2,
          rangeEnd: 3,
          min: 1,
          max: 15,
          divisions: 14,
          onRangeChanged: (s, e) => emitted.add([s, e]),
        ),
      );

      // Grab the start thumb and drag it well past the end thumb.
      final box = tester.getRect(find.byType(SailSlider));
      final trackLeft = box.left + 10;
      final step = 394 / 14;
      await tester.dragFrom(
        Offset(trackLeft + step * 1, box.center.dy),
        Offset(step * 8, 0),
      );
      await tester.pumpAndSettle();

      expect(emitted, isNotEmpty);
      for (final pair in emitted) {
        expect(pair[0] <= pair[1], isTrue, reason: 'start ${pair[0]} passed end ${pair[1]}');
      }
    });

    testWidgets('an m-of-m range can still be widened', (tester) async {
      final emitted = <List<double>>[];
      await pump(
        tester,
        SailSlider.range(
          rangeStart: 3,
          rangeEnd: 3,
          min: 1,
          max: 15,
          divisions: 14,
          onRangeChanged: (s, e) => emitted.add([s, e]),
        ),
      );

      // Both thumbs sit on 3; dragging right must move the end, not clamp.
      final box = tester.getRect(find.byType(SailSlider));
      final step = 394 / 14;
      await tester.dragFrom(
        Offset(box.left + 10 + step * 2, box.center.dy),
        Offset(step * 4, 0),
      );
      await tester.pumpAndSettle();

      expect(emitted, isNotEmpty);
      expect(emitted.last[1], greaterThan(3), reason: 'the end thumb must be grabbable at start == end');
      expect(emitted.last[0], 3);
    });

    testWidgets('a disabled slider emits nothing', (tester) async {
      final emitted = <double>[];
      await pump(
        tester,
        SailSlider(value: 4, min: 0, max: 8, divisions: 8, disabled: true, onChanged: emitted.add),
      );

      final box = tester.getRect(find.byType(SailSlider));
      await tester.tapAt(Offset(box.center.dx, box.center.dy));
      await tester.pumpAndSettle();

      expect(emitted, isEmpty);
    });
  });
}
