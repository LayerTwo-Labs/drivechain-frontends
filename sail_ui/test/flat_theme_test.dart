import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _themed(SailThemeData data, Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: SailTheme(
    data: data,
    child: Center(child: child),
  ),
);

SailThemeData _flat({bool light = false}) => light
    ? SailThemeData.lightTheme(SailColorScheme.orange, false, SailFontValues.inter, SailThemeStyle.flat)
    : SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.inter, SailThemeStyle.flat);

BoxDecoration _track(WidgetTester tester) =>
    tester.widgetList<Container>(find.byType(Container)).first.decoration! as BoxDecoration;

void main() {
  group('registry', () {
    test('new installs and unknown ids get the flat style', () {
      expect(defaultThemeStyleId, SailThemeStyle.flat.id);
      expect(sailBundleForId(defaultThemeStyleId).style, SailThemeStyle.flat);
      expect(sailBundleForId('removed-style').style, SailThemeStyle.flat);
      expect(sailBundleForId(null).style, SailThemeStyle.flat);
    });

    test('a saved style still loads', () {
      for (final style in SailThemeStyle.values) {
        expect(sailBundleForId(style.id).style, style);
      }
    });
  });

  group('palette', () {
    test('dark mode holds the flat dark tokens', () {
      final c = _flat().colors;
      expect(c.background, const Color(0xff000000));
      expect(c.backgroundSecondary, const Color(0xff1A1A1A));
      expect(c.popoverBackground, const Color(0xff262626));
      expect(c.border, const Color(0xff3C3B3B));
      expect(c.formField, const Color(0xff3C3B3B));
      expect(c.chip, const Color(0xff171717));
      expect(c.text, const Color(0xffFFFFFF));
      expect(c.textSecondary, const Color(0xffA1A1AA));
      expect(c.textTertiary, const Color(0xff71717A));
      expect(c.primary, const Color(0xffF7931E));
      expect(c.warningLight, const Color(0xff311D06));
      expect(c.primaryButtonText, const Color(0xff000000));
      expect(c.destructiveButtonBackground, const Color(0xff3C3B3B));
      expect(c.destructiveButtonText, const Color(0xffFD7979));
      expect(c.activeNavText, const Color(0xffFFFFFF));
    });

    test('light mode holds the flat light tokens', () {
      final c = _flat(light: true).colors;
      expect(c.background, const Color(0xffF3F1EC));
      expect(c.backgroundSecondary, const Color(0xffFFFFFF));
      expect(c.border, const Color(0xffEBE9E1));
      expect(c.text, const Color(0xff000000));
      expect(c.textSecondary, const Color(0xff61605E));
      expect(c.warningLight, const Color(0xffFFEFDD));
      expect(c.primaryButtonText, const Color(0xffFFFFFF));
      expect(c.destructiveButtonText, const Color(0xffFF0000));
    });

    test('the accent does not change the palette', () {
      final orange = SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.inter, SailThemeStyle.flat);
      final blue = SailThemeData.darkTheme(SailColorScheme.blue, false, SailFontValues.inter, SailThemeStyle.flat);
      expect(blue.colors.primary, orange.colors.primary);
    });
  });

  group('chrome', () {
    test('radii are 8, 12 and 20 with no terminal style', () {
      final chrome = _flat().chrome;
      expect(chrome.radiusSmall, const BorderRadius.all(Radius.circular(8)));
      expect(chrome.radius, const BorderRadius.all(Radius.circular(12)));
      expect(chrome.radiusLarge, const BorderRadius.all(Radius.circular(20)));
      expect(chrome.terminalStyle, isFalse);
      expect(chrome.beveled, isFalse);
    });

    test('text uses Inter and mono text keeps mono', () {
      final chrome = _flat().chrome;
      expect(chrome.textFamily(), SailFonts.inter);
      expect(chrome.textFamily(monospace: true), SailFonts.mono);
    });

    test('the other styles keep their families', () {
      final sail = sailBundleFor(SailThemeStyle.sail).chrome;
      expect(sail.textFamily(), SailFonts.inter);
      expect(sail.textFamily(monospace: true), SailFonts.mono);

      final ecash = sailBundleFor(SailThemeStyle.ecash).chrome;
      expect(ecash.textFamily(), SailFonts.mono);
      expect(ecash.textFamily(monospace: true), SailFonts.mono);
    });
  });

  group('widgets', () {
    testWidgets('SailText resolves Inter, and mono text resolves mono', (tester) async {
      await tester.pumpWidget(
        _themed(
          _flat(),
          Column(children: [SailText.primary13('label'), SailText.primary13('hash', monospace: true)]),
        ),
      );

      expect(tester.widget<Text>(find.text('label')).style!.fontFamily, SailFonts.inter);
      expect(tester.widget<Text>(find.text('hash')).style!.fontFamily, SailFonts.mono);
    });

    testWidgets('a flat switch is 30x18 with no border', (tester) async {
      await tester.pumpWidget(_themed(_flat(), SailSwitch(value: false, onChanged: (_) {})));

      expect(tester.getSize(find.byType(Container).first), const Size(30, 18));
      final track = _track(tester);
      expect(track.border, isNull);
      expect(track.color, _flat().colors.border);
    });

    testWidgets('a sail switch keeps its 36x20 bordered track', (tester) async {
      final sail = SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.inter);
      await tester.pumpWidget(_themed(sail, SailSwitch(value: false, onChanged: (_) {})));

      expect(tester.getSize(find.byType(Container).first), const Size(36, 20));
      expect(_track(tester).border, isNotNull);
    });
  });

  group('flat controls', () {
    SailThemeData sail() => SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.inter);

    BoxDecoration? outlineBorder(WidgetTester tester) => tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.border != null)
        .firstOrNull;

    testWidgets('a flat button is one flat layer', (tester) async {
      await tester.pumpWidget(_themed(_flat(), SailButton(label: 'Send', onPressed: () async {})));

      expect(find.descendant(of: find.byType(SailButton), matching: find.byType(Stack)), findsNothing);
    });

    testWidgets('a sail button keeps its lower layer', (tester) async {
      await tester.pumpWidget(_themed(sail(), SailButton(label: 'Send', onPressed: () async {})));

      expect(find.descendant(of: find.byType(SailButton), matching: find.byType(Stack)), findsWidgets);
    });

    testWidgets('an outline button draws its border in each non-terminal style', (tester) async {
      for (final data in [_flat(), sail()]) {
        await tester.pumpWidget(
          _themed(data, SailButton(label: 'Edit', variant: ButtonVariant.outline, onPressed: () async {})),
        );
        await tester.pumpAndSettle();

        final border = outlineBorder(tester)?.border as Border?;
        expect(border?.top.color, data.colors.outlineButtonBorder);
      }
    });

    testWidgets('a checked flat checkbox fills with the accent', (tester) async {
      await tester.pumpWidget(_themed(_flat(), SailCheckbox(value: true, onChanged: (_) {})));

      final box = tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;
      expect(box.color, _flat().colors.primary);
      expect(box.boxShadow, isNull);
      expect(tester.widget<Icon>(find.byType(Icon)).color, _flat().colors.primaryButtonText);
    });

    testWidgets('a flat card fills with the raised surface, a sail card with the page colour', (tester) async {
      for (final (data, fill) in [(_flat(), _flat().colors.backgroundSecondary), (sail(), sail().colors.background)]) {
        await tester.pumpWidget(
          MaterialApp(
            home: _themed(data, const SailCard(title: 'Send', child: SizedBox(height: 10))),
          ),
        );

        final fills = tester
            .widgetList<DecoratedBox>(find.descendant(of: find.byType(SailCard), matching: find.byType(DecoratedBox)))
            .map((b) => (b.decoration as BoxDecoration).color);
        expect(fills, contains(fill));
      }
    });
  });
}
