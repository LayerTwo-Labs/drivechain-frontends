import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _themed(SailThemeData data, Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: SailTheme(
    data: data,
    child: Center(child: child),
  ),
);

SailThemeData _v2({bool light = false}) => light
    ? SailThemeData.lightTheme(SailColorScheme.orange, false, SailFontValues.inter, SailThemeStyle.bitwindowV2)
    : SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.inter, SailThemeStyle.bitwindowV2);

BoxDecoration _track(WidgetTester tester) =>
    tester.widgetList<Container>(find.byType(Container)).first.decoration! as BoxDecoration;

void main() {
  group('registry', () {
    test('new installs and unknown ids get the BitWindow v2 style', () {
      expect(defaultThemeStyleId, SailThemeStyle.bitwindowV2.id);
      expect(sailBundleForId(defaultThemeStyleId).style, SailThemeStyle.bitwindowV2);
      expect(sailBundleForId('removed-style').style, SailThemeStyle.bitwindowV2);
      expect(sailBundleForId(null).style, SailThemeStyle.bitwindowV2);
    });

    test('a saved style still loads', () {
      for (final style in SailThemeStyle.values) {
        expect(sailBundleForId(style.id).style, style);
      }
    });
  });

  group('palette', () {
    test('dark mode holds the BitWindow v2 dark tokens', () {
      final c = _v2().colors;
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

    test('light mode holds the BitWindow v2 light tokens', () {
      final c = _v2(light: true).colors;
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
      final orange = SailThemeData.darkTheme(
        SailColorScheme.orange,
        false,
        SailFontValues.inter,
        SailThemeStyle.bitwindowV2,
      );
      final blue = SailThemeData.darkTheme(
        SailColorScheme.blue,
        false,
        SailFontValues.inter,
        SailThemeStyle.bitwindowV2,
      );
      expect(blue.colors.primary, orange.colors.primary);
    });
  });

  group('chrome', () {
    test('radii are 8, 12 and 20 with no terminal style', () {
      final chrome = _v2().chrome;
      expect(chrome.radiusSmall, const BorderRadius.all(Radius.circular(8)));
      expect(chrome.radius, const BorderRadius.all(Radius.circular(12)));
      expect(chrome.radiusLarge, const BorderRadius.all(Radius.circular(20)));
      expect(chrome.terminalStyle, isFalse);
      expect(chrome.beveled, isFalse);
    });

    test('text uses Inter and mono text keeps mono', () {
      final chrome = _v2().chrome;
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
          _v2(),
          Column(children: [SailText.primary13('label'), SailText.primary13('hash', monospace: true)]),
        ),
      );

      expect(tester.widget<Text>(find.text('label')).style!.fontFamily, SailFonts.inter);
      expect(tester.widget<Text>(find.text('hash')).style!.fontFamily, SailFonts.mono);
    });

    testWidgets('a BitWindow v2 switch is 30x18 with no border', (tester) async {
      await tester.pumpWidget(_themed(_v2(), SailSwitch(value: false, onChanged: (_) {})));

      expect(tester.getSize(find.byType(Container).first), const Size(30, 18));
      final track = _track(tester);
      expect(track.border, isNull);
      expect(track.color, _v2().colors.border);
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

    testWidgets('a BitWindow v2 button is one flat layer', (tester) async {
      await tester.pumpWidget(_themed(_v2(), SailButton(label: 'Send', onPressed: () async {})));

      expect(find.descendant(of: find.byType(SailButton), matching: find.byType(Stack)), findsNothing);
    });

    testWidgets('a sail button keeps its lower layer', (tester) async {
      await tester.pumpWidget(_themed(sail(), SailButton(label: 'Send', onPressed: () async {})));

      expect(find.descendant(of: find.byType(SailButton), matching: find.byType(Stack)), findsWidgets);
    });

    testWidgets('an outline button draws its border in each non-terminal style', (tester) async {
      for (final data in [_v2(), sail()]) {
        await tester.pumpWidget(
          _themed(data, SailButton(label: 'Edit', variant: ButtonVariant.outline, onPressed: () async {})),
        );
        await tester.pumpAndSettle();

        final border = outlineBorder(tester)?.border as Border?;
        expect(border?.top.color, data.colors.outlineButtonBorder);
      }
    });

    testWidgets('a checked BitWindow v2 checkbox fills with the accent', (tester) async {
      await tester.pumpWidget(_themed(_v2(), SailCheckbox(value: true, onChanged: (_) {})));

      final box = tester.widget<Container>(find.byType(Container).first).decoration! as BoxDecoration;
      expect(box.color, _v2().colors.primary);
      expect(box.boxShadow, isNull);
      expect(tester.widget<Icon>(find.byType(Icon)).color, _v2().colors.primaryButtonText);
    });

    testWidgets('a BitWindow v2 card fills with the raised surface, a sail card with the page colour', (tester) async {
      for (final (data, fill) in [(_v2(), _v2().colors.backgroundSecondary), (sail(), sail().colors.background)]) {
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

  group('flat ghost and progress', () {
    TextDecoration? decoration(WidgetTester tester, String label) =>
        tester.widgetList<Text>(find.byType(Text)).firstWhere((t) => t.data == label).style?.decoration;

    testWidgets('a flat ghost button has no underline and a link keeps it', (tester) async {
      await tester.pumpWidget(
        _themed(
          _v2(),
          Column(
            children: [
              SailButton(label: 'View logs', variant: ButtonVariant.ghost, onPressed: () async {}),
              SailButton(label: 'Open', variant: ButtonVariant.link, onPressed: () async {}),
            ],
          ),
        ),
      );

      expect(decoration(tester, 'View logs'), isNull);
      expect(decoration(tester, 'Open'), TextDecoration.underline);
    });

    testWidgets('a flat progress bar draws a border track and a primary fill', (tester) async {
      await tester.pumpWidget(
        _themed(_v2(light: true), const SizedBox(width: 300, child: ProgressBar(current: 1, goal: 2))),
      );

      final colors = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => (c.decoration as BoxDecoration?)?.color)
          .whereType<Color>()
          .toList();
      expect(colors, containsAll([_v2(light: true).colors.border, _v2(light: true).colors.primary]));
    });

    testWidgets('an unknown goal shows the whole word', (tester) async {
      await tester.pumpWidget(
        _themed(_v2(), const SizedBox(width: 400, child: ProgressBar(current: 0, goal: 0))),
      );

      final label = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.text('unknown'), matching: find.byType(RichText)),
      );
      expect(label.didExceedMaxLines, isFalse);
      expect(label.size.width, greaterThanOrEqualTo(label.getMaxIntrinsicWidth(double.infinity)));
    });
  });
}
