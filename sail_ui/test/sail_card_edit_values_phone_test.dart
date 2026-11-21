import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _editValues() {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: SailCardEditValues(
              title: 'Add Note',
              subtitle: 'Set a note',
              fields: [EditField(name: 'Note', currentValue: '')],
              onSave: (_) => null,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  testWidgets('on a phone the label sits above a full-width field', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpWidget(_editValues());

    final label = tester.getRect(find.text('Note'));
    final field = tester.getRect(find.byType(SailTextField));
    expect(field.top, greaterThanOrEqualTo(label.bottom));
    expect(field.left, closeTo(label.left, 1));
  });

  testWidgets('on a desktop the label sits beside the field', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.pumpWidget(_editValues());

    final label = tester.getRect(find.text('Note'));
    final field = tester.getRect(find.byType(SailTextField));
    expect(field.left, greaterThan(label.right));
  });
}
