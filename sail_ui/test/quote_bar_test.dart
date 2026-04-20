import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(
        SailColorScheme.orange,
        true,
        SailFontValues.inter,
      ),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    ),
  );
}

const _testQuotes = <Map<String, String>>[
  {'quote': 'Stay humble. Stack sats.', 'author': 'Alice'},
  {'quote': 'Fix the money, fix the world.', 'author': 'Bob'},
  {'quote': 'A third quote for navigation.', 'author': 'Carol'},
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QuoteBar renders a quote with an author dash', (tester) async {
    await tester.pumpWidget(
      _wrap(const QuoteBar(quotes: _testQuotes)),
    );
    await tester.pump();

    // Author line is always prefixed with "— ".
    expect(find.textContaining('—'), findsWidgets);
  });

  testWidgets('QuoteBar changes quote after tapping the next arrow', (tester) async {
    await tester.pumpWidget(
      _wrap(const QuoteBar(quotes: _testQuotes)),
    );
    await tester.pump();

    String? currentAuthor() {
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        final data = text.data ?? '';
        if (data.startsWith('— ')) return data;
      }
      return null;
    }

    final before = currentAuthor();
    expect(before, isNotNull);

    await tester.tap(find.byKey(const ValueKey('quote_bar_next')));
    await tester.pump();

    final after = currentAuthor();
    expect(after, isNotNull);
    expect(after, isNot(equals(before)));
  });

  testWidgets('QuoteBar changes quote after tapping the prev arrow', (tester) async {
    await tester.pumpWidget(
      _wrap(const QuoteBar(quotes: _testQuotes)),
    );
    await tester.pump();

    String? currentAuthor() {
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        final data = text.data ?? '';
        if (data.startsWith('— ')) return data;
      }
      return null;
    }

    final before = currentAuthor();
    await tester.tap(find.byKey(const ValueKey('quote_bar_prev')));
    await tester.pump();
    final after = currentAuthor();
    expect(after, isNot(equals(before)));
  });
}
