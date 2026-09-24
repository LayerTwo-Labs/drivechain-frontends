import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _app(Widget child) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(body: SizedBox(width: 400, child: child)),
    ),
  );
}

void main() {
  testWidgets('shows the message in the error color', (tester) async {
    await tester.pumpWidget(_app(const SailInlineError('Could not send')));

    final text = tester.widget<Text>(find.text('Could not send'));
    final theme = SailTheme.of(tester.element(find.byType(SailInlineError)));
    expect(text.style?.color, theme.colors.error);
  });

  testWidgets('a long message wraps instead of cutting off', (tester) async {
    final message = List.filled(40, 'word').join(' ');
    await tester.pumpWidget(_app(SailInlineError(message)));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SailInlineError)).height, greaterThan(30));
  });

  testWidgets('maxLines keeps a message to one line', (tester) async {
    final message = List.filled(40, 'word').join(' ');
    await tester.pumpWidget(_app(SailInlineError(message, maxLines: 1)));

    expect(tester.getSize(find.byType(SailInlineError)).height, lessThan(30));
  });

  group('SailCardEditValues', () {
    Widget editCard(FutureOr<String?> Function(List<EditField>) onSave) => _app(
      SailCardEditValues(
        title: 'Accelerate',
        subtitle: '',
        fields: [EditField(name: 'Rate', currentValue: '')],
        onSave: onSave,
      ),
    );

    testWidgets('shows the error that save returns under the fields', (tester) async {
      await tester.pumpWidget(editCard((_) async => 'Enter a positive fee rate'));

      await tester.tap(find.widgetWithText(SailButton, 'Save changes').first);
      await tester.pump();

      expect(
        find.descendant(of: find.byType(SailInlineError), matching: find.text('Enter a positive fee rate')),
        findsOneWidget,
      );
    });

    testWidgets('an edit clears the error', (tester) async {
      await tester.pumpWidget(editCard((_) async => 'Enter a positive fee rate'));
      await tester.tap(find.widgetWithText(SailButton, 'Save changes').first);
      await tester.pump();

      await tester.enterText(find.byType(TextField), '5');
      await tester.pump();

      expect(find.byType(SailInlineError), findsNothing);
    });

    testWidgets('a save with no error shows nothing', (tester) async {
      await tester.pumpWidget(editCard((_) async => null));

      await tester.tap(find.widgetWithText(SailButton, 'Save changes').first);
      await tester.pump();

      expect(find.byType(SailInlineError), findsNothing);
    });
  });
}
