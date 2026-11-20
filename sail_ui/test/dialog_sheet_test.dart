import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

const _screen = Size(400, 800);

Future<void> _open(WidgetTester tester, WidgetBuilder builder, {EdgeInsets padding = EdgeInsets.zero}) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(top: padding.top, bottom: padding.bottom);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: child ?? const SizedBox(),
      ),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showThemedDialog<void>(context: context, builder: builder),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Widget _dialog(BuildContext context) => SailDialog(
  title: 'Edit wallet',
  child: SailCard(title: 'Inner', child: const SizedBox(height: 40)),
);

BorderRadius _clip(WidgetTester tester, String title) {
  final clip = tester.widget<ClipRRect>(
    find.descendant(of: find.widgetWithText(SailCard, title).first, matching: find.byType(ClipRRect)).first,
  );
  return clip.borderRadius as BorderRadius;
}

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  group('on a phone', () {
    setUp(() => SailStyleValues.phoneLayoutOverride = true);

    testWidgets('a dialog shows as a sheet at the bottom edge at full width', (tester) async {
      await _open(tester, _dialog);

      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.widgetWithText(SailCard, 'Edit wallet').first);
      expect(card.bottom, _screen.height);
      expect(card.left, 0);
      expect(card.width, _screen.width);
    });

    testWidgets('the sheet card has round top corners only, and the inner card keeps its corners', (tester) async {
      await _open(tester, _dialog);

      final outer = _clip(tester, 'Edit wallet');
      expect(outer.topLeft, isNot(Radius.zero));
      expect(outer.bottomLeft, Radius.zero);
      expect(outer.bottomRight, Radius.zero);

      final inner = _clip(tester, 'Inner');
      expect(inner.bottomLeft, isNot(Radius.zero));
    });

    testWidgets('the sheet keeps its content above the home indicator', (tester) async {
      await _open(tester, _dialog, padding: const EdgeInsets.only(top: 40, bottom: 34));

      final card = tester.getRect(find.widgetWithText(SailCard, 'Edit wallet').first);
      final inner = tester.getRect(find.widgetWithText(SailCard, 'Inner').first);
      expect(card.bottom, _screen.height);
      expect(card.bottom - inner.bottom, greaterThanOrEqualTo(34 + 16));
    });

    testWidgets('a tap on the barrier closes the sheet', (tester) async {
      await _open(tester, _dialog);

      await tester.tapAt(const Offset(200, 20));
      await tester.pumpAndSettle();
      expect(find.text('Edit wallet'), findsNothing);
    });
  });

  testWidgets('on a desktop a dialog stays in the middle with round corners', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _open(tester, _dialog);

    final card = tester.getRect(find.widgetWithText(SailCard, 'Edit wallet').first);
    expect(card.bottom, lessThan(_screen.height - 20));
    expect(card.center.dy, closeTo(_screen.height / 2, 1));
    expect(_clip(tester, 'Edit wallet').bottomLeft, isNot(Radius.zero));
  });
}
