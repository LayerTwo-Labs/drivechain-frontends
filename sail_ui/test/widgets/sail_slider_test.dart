import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _wrap(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SailTheme(
      data: SailThemeData.lightTheme(
        SailColorScheme.orange,
        true,
        SailFontValues.inter,
      ),
      child: Center(
        child: SizedBox(width: 200, child: child),
      ),
    ),
  );
}

void main() {
  group('SailSlider', () {
    testWidgets('renders with default range', (tester) async {
      await tester.pumpWidget(
        _wrap(SailSlider(value: 0.5, onChanged: (_) {})),
      );
      expect(find.byType(SailSlider), findsOneWidget);
    });

    testWidgets('tap on right side emits high value', (tester) async {
      double? captured;
      await tester.pumpWidget(
        _wrap(SailSlider(value: 0.0, onChanged: (v) => captured = v)),
      );
      final box = tester.getRect(find.byType(SailSlider));
      await tester.tapAt(Offset(box.right - 4, box.center.dy));
      expect(captured, isNotNull);
      expect(captured! > 0.5, true);
    });

    testWidgets('respects min and max bounds', (tester) async {
      double? captured;
      await tester.pumpWidget(
        _wrap(
          SailSlider(
            value: 5,
            min: 0,
            max: 10,
            onChanged: (v) => captured = v,
          ),
        ),
      );
      final box = tester.getRect(find.byType(SailSlider));
      await tester.tapAt(Offset(box.left + 4, box.center.dy));
      expect(captured, isNotNull);
      expect(captured! < 5, true);
      expect(captured! >= 0, true);
    });

    testWidgets('disabled does not fire', (tester) async {
      bool fired = false;
      await tester.pumpWidget(
        _wrap(
          SailSlider(
            value: 0.5,
            disabled: true,
            onChanged: (_) => fired = true,
          ),
        ),
      );
      final box = tester.getRect(find.byType(SailSlider));
      await tester.tapAt(box.center);
      expect(fired, false);
    });

    testWidgets('divisions snap value', (tester) async {
      double? captured;
      await tester.pumpWidget(
        _wrap(
          SailSlider(
            value: 0,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (v) => captured = v,
          ),
        ),
      );
      final box = tester.getRect(find.byType(SailSlider));
      await tester.tapAt(Offset(box.left + box.width * 0.33, box.center.dy));
      expect(captured, isNotNull);
      expect(captured, captured!.roundToDouble());
    });
  });
}
