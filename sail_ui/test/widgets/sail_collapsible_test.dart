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
  group('SailCollapsible', () {
    testWidgets('hides child when closed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SailCollapsible(
            open: false,
            child: SailText.primary12('body-content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final body = tester.getSize(find.byType(SailCollapsible));
      expect(body.height, 0);
    });

    testWidgets('shows child when open', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SailCollapsible(
            open: true,
            child: SailText.primary12('body-content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('body-content'), findsOneWidget);
      expect(tester.getSize(find.byType(SailCollapsible)).height, greaterThan(0));
    });

    testWidgets('trigger toggles via controller', (tester) async {
      final ctrl = SailCollapsibleController();
      await tester.pumpWidget(
        _wrap(
          SailCollapsible(
            controller: ctrl,
            trigger: SailText.primary12('header'),
            child: SailText.primary12('body'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(ctrl.isOpen, false);
      await tester.tap(find.text('header'));
      await tester.pumpAndSettle();
      expect(ctrl.isOpen, true);
    });

    testWidgets('onOpenChanged fires for controlled open prop', (tester) async {
      bool? captured;
      await tester.pumpWidget(
        _wrap(
          SailCollapsible(
            open: false,
            onOpenChanged: (v) => captured = v,
            trigger: SailText.primary12('hdr'),
            child: SailText.primary12('body'),
          ),
        ),
      );
      await tester.tap(find.text('hdr'));
      await tester.pumpAndSettle();
      expect(captured, true);
    });

    testWidgets('controller close() collapses', (tester) async {
      final ctrl = SailCollapsibleController(initiallyOpen: true);
      await tester.pumpWidget(
        _wrap(
          SailCollapsible(
            controller: ctrl,
            child: SailText.primary12('body'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      ctrl.close();
      await tester.pumpAndSettle();
      expect(ctrl.isOpen, false);
    });
  });
}
