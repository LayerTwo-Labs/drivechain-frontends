import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _ecash(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: SailTheme(
    data: SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.ibmMono, SailThemeStyle.ecash),
    child: Center(child: child),
  ),
);

Text _label(WidgetTester tester, String text) =>
    tester.widgetList<Text>(find.byType(Text)).firstWhere((t) => t.data!.toLowerCase() == text.toLowerCase());

void main() {
  testWidgets('a terminal theme writes a label in upper case and bold', (tester) async {
    await tester.pumpWidget(_ecash(SailButton(label: 'Create market', onPressed: () async {})));

    final label = _label(tester, 'Create market');
    expect(label.data, 'CREATE MARKET');
    expect(label.style?.fontWeight, SailStyleValues.boldWeight);
  });

  testWidgets('a plain label keeps its case and the regular weight', (tester) async {
    await tester.pumpWidget(_ecash(SailButton(label: 'Create market', plainLabel: true, onPressed: () async {})));

    final label = _label(tester, 'Create market');
    expect(label.data, 'Create market');
    expect(label.style?.fontWeight, FontWeight.w400);
  });
}
