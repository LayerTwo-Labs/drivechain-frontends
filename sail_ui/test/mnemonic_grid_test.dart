import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  Widget host(Widget child) => SailTheme(
    data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
    child: MaterialApp(
      home: Scaffold(body: SizedBox(width: 800, child: child)),
    ),
  );

  testWidgets('numbers every word', (tester) async {
    await tester.pumpWidget(host(SailMnemonicGrid(words: List.generate(12, (i) => 'word$i'))));
    await tester.pumpAndSettle();

    for (var i = 1; i <= 12; i++) {
      expect(find.text('$i.'), findsOneWidget);
    }
    expect(find.text('word0'), findsOneWidget);
    expect(find.text('word11'), findsOneWidget);
  });

  testWidgets('reads down columns, so word 5 starts the second column of a 12-word grid', (tester) async {
    await tester.pumpWidget(host(SailMnemonicGrid(words: List.generate(12, (i) => 'w${i + 1}'))));
    await tester.pumpAndSettle();

    // Column-major over 4 rows: 1 and 5 head their columns, so they share a row.
    final first = tester.getTopLeft(find.text('w1'));
    final fifth = tester.getTopLeft(find.text('w5'));
    expect(fifth.dy, first.dy);
    expect(fifth.dx, greaterThan(first.dx));
  });

  testWidgets('shows bits only when supplied', (tester) async {
    final words = List.generate(12, (i) => 'w$i');
    await tester.pumpWidget(host(SailMnemonicGrid(words: words)));
    await tester.pumpAndSettle();
    expect(find.text('10000000100'), findsNothing);

    await tester.pumpWidget(
      host(SailMnemonicGrid(words: words, bits: List.filled(12, '10000000100'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('10000000100'), findsNWidgets(12));
  });

  testWidgets('handles 24 words and a ragged final row', (tester) async {
    await tester.pumpWidget(host(SailMnemonicGrid(words: List.generate(24, (i) => 'w$i'))));
    await tester.pumpAndSettle();
    expect(find.text('24.'), findsOneWidget);

    await tester.pumpWidget(host(SailMnemonicGrid(words: List.generate(11, (i) => 'r$i'))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('11.'), findsOneWidget);
  });

  testWidgets('controllers turn the cells into inputs', (tester) async {
    final controllers = List.generate(6, (_) => TextEditingController());
    addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
    final edited = <int, String>{};

    await tester.pumpWidget(
      host(SailMnemonicGrid(controllers: controllers, onChanged: (i, v) => edited[i] = v)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(6));
    await tester.enterText(find.byType(TextField).first, 'abandon');
    expect(edited[0], 'abandon');
  });

  testWidgets('words are ignored once controllers are given', (tester) async {
    final controllers = List.generate(2, (_) => TextEditingController());
    addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
    });

    await tester.pumpWidget(
      host(SailMnemonicGrid(words: const ['one', 'two'], controllers: controllers)),
    );
    await tester.pumpAndSettle();

    expect(find.text('one'), findsNothing);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('enter moves to the next word, and tab follows word order', (tester) async {
    const columns = 3;
    const rows = 4;
    // Cells are laid out row by row but numbered down the columns, so word i
    // sits at a different position in the tree.
    int slotOf(int word) => (word % rows) * columns + (word ~/ rows);

    final controllers = List.generate(12, (_) => TextEditingController());
    addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
    });
    var completed = false;

    await tester.pumpWidget(
      host(SailMnemonicGrid(controllers: controllers, onCompleted: () => completed = true)),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    bool focused(int word) => tester.widget<TextField>(fields.at(slotOf(word))).focusNode?.hasFocus ?? false;

    await tester.tap(fields.at(slotOf(0)));
    await tester.pumpAndSettle();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(focused(1), isTrue, reason: 'enter goes to word 2');

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(focused(2), isTrue, reason: 'tab follows 1, 2, 3 rather than the column layout');

    await tester.tap(fields.at(slotOf(11)));
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(completed, isTrue, reason: 'the last word reports completion');
  });

  testWidgets('renders nothing when empty', (tester) async {
    await tester.pumpWidget(host(const SailMnemonicGrid(words: [])));
    await tester.pumpAndSettle();
    expect(find.text('1.'), findsNothing);
  });
}
