import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  testWidgets('a typed value uses the theme text color on the dark theme', (tester) async {
    final theme = SailThemeData.darkTheme(SailColorScheme.orange, true, SailFontValues.inter);
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: theme,
          child: Scaffold(
            body: Form(
              child: SailTextFormField(
                label: 'Title',
                controller: TextEditingController(text: 'QAChain'),
                size: TextFieldSize.small,
              ),
            ),
          ),
        ),
      ),
    );

    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.style.color, theme.colors.text);
  });
}
