import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  testWidgets('a squeezed dropdown keeps its label on one line', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 120,
                child: SailDropdownButton<String>(
                  items: const [SailDropdownItem(value: 'a', label: 'Japan Weekly (pending)')],
                  value: 'a',
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('Japan Weekly (pending)'));
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });
}
