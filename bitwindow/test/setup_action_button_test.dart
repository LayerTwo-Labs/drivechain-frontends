import 'package:bitwindow/widgets/setup_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  final theme = SailThemeData.darkTheme(
    SailColorScheme.orange,
    false,
    SailFontValues.inter,
    SailThemeStyle.bitwindowV2,
  );

  Future<BoxDecoration> pump(WidgetTester tester, {required bool primary}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: theme,
          child: SetupActionButton(label: 'Create wallet', primary: primary, onPressed: () async {}),
        ),
      ),
    );
    return tester
        .widgetList<Container>(find.descendant(of: find.byType(SetupActionButton), matching: find.byType(Container)))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .first;
  }

  Color? labelColor(WidgetTester tester) => tester
      .widgetList<RichText>(find.descendant(of: find.byType(SetupActionButton), matching: find.byType(RichText)))
      .first
      .text
      .style
      ?.color;

  testWidgets('the primary setup button takes the primary button colours', (tester) async {
    final box = await pump(tester, primary: true);

    expect(box.color, theme.colors.primaryButtonBackground);
    expect(box.gradient, isNull);
    expect(box.boxShadow, isNull);
    expect(labelColor(tester), theme.colors.primaryButtonText);
  });

  testWidgets('the other setup buttons take the secondary button colours', (tester) async {
    final box = await pump(tester, primary: false);

    expect(box.color, theme.colors.secondaryButtonBackground);
    expect(labelColor(tester), theme.colors.secondaryButtonText);
  });
}
