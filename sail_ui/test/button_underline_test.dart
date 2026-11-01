import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _themed(Widget child, {SailThemeStyle? style}) => Directionality(
  textDirection: TextDirection.ltr,
  child: SailTheme(
    data: style == null
        ? SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.inter)
        : SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.ibmMono, style),
    child: Center(child: child),
  ),
);

TextDecoration? _decoration(WidgetTester tester) =>
    tester.widgetList<Text>(find.byType(Text)).firstWhere((t) => t.data!.toLowerCase() == 'go').style?.decoration;

void main() {
  for (final style in [null, SailThemeStyle.ecash]) {
    final theme = style == null ? 'the default theme' : 'a terminal theme';

    for (final variant in [ButtonVariant.ghost, ButtonVariant.link]) {
      testWidgets('$variant underlines its label in $theme', (tester) async {
        await tester.pumpWidget(
          _themed(
            SailButton(label: 'Go', variant: variant, onPressed: () async {}),
            style: style,
          ),
        );

        expect(_decoration(tester), TextDecoration.underline);
      });
    }

    for (final variant in [
      ButtonVariant.primary,
      ButtonVariant.secondary,
      ButtonVariant.outline,
      ButtonVariant.destructive,
    ]) {
      testWidgets('$variant does not underline its label in $theme', (tester) async {
        await tester.pumpWidget(
          _themed(
            SailButton(label: 'Go', variant: variant, onPressed: () async {}),
            style: style,
          ),
        );

        expect(_decoration(tester), isNot(TextDecoration.underline));
      });
    }
  }
}
