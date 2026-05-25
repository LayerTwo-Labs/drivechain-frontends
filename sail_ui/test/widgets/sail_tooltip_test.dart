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
      child: Overlay(
        initialEntries: [
          OverlayEntry(builder: (_) => Center(child: child)),
        ],
      ),
    ),
  );
}

void main() {
  group('SailTooltip', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SailTooltip(
            message: 'hello',
            child: SailText.primary12('trigger'),
          ),
        ),
      );
      expect(find.text('trigger'), findsOneWidget);
      expect(find.text('hello'), findsNothing);
    });

    testWidgets('long-press shows tooltip', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SailTooltip(
            message: 'tip-text',
            showDuration: const Duration(seconds: 5),
            child: SizedBox(
              width: 50,
              height: 50,
              child: SailText.primary12('x'),
            ),
          ),
        ),
      );
      await tester.longPress(find.byType(SailTooltip));
      await tester.pump();
      expect(find.text('tip-text'), findsOneWidget);
    });

    testWidgets('disposing removes overlay entry safely', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SailTooltip(
            message: 'gone',
            child: SailText.primary12('a'),
          ),
        ),
      );
      await tester.pumpWidget(_wrap(SailText.primary12('replacement')));
      expect(find.text('gone'), findsNothing);
    });

    testWidgets('accepts custom position above', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SailTooltip(
            message: 'above',
            position: SailTooltipPosition.above,
            showDuration: const Duration(seconds: 5),
            child: SailText.primary12('y'),
          ),
        ),
      );
      await tester.longPress(find.byType(SailTooltip));
      await tester.pump();
      expect(find.text('above'), findsOneWidget);
    });
  });
}
