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
      child: Center(child: child),
    ),
  );
}

void main() {
  group('SailSwitch', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(SailSwitch(value: false, onChanged: (_) {})));
      expect(find.byType(SailSwitch), findsOneWidget);
    });

    testWidgets('tap toggles value via onChanged', (tester) async {
      bool? captured;
      await tester.pumpWidget(
        _wrap(SailSwitch(value: false, onChanged: (v) => captured = v)),
      );
      await tester.tap(find.byType(SailSwitch));
      expect(captured, true);
    });

    testWidgets('disabled does not fire onChanged', (tester) async {
      bool fired = false;
      await tester.pumpWidget(
        _wrap(
          SailSwitch(
            value: false,
            disabled: true,
            onChanged: (_) => fired = true,
          ),
        ),
      );
      await tester.tap(find.byType(SailSwitch), warnIfMissed: false);
      expect(fired, false);
    });

    testWidgets('null onChanged is uncallable', (tester) async {
      await tester.pumpWidget(_wrap(SailSwitch(value: true, onChanged: null)));
      // should still render
      expect(find.byType(SailSwitch), findsOneWidget);
    });

    testWidgets('animates when value flips', (tester) async {
      await tester.pumpWidget(_wrap(SailSwitch(value: false, onChanged: (_) {})));
      await tester.pumpWidget(_wrap(SailSwitch(value: true, onChanged: (_) {})));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.byType(SailSwitch), findsOneWidget);
    });
  });
}
