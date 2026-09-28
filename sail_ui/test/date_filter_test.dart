import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  final range = (start: DateTime(2026, 3, 10, 15), end: DateTime(2026, 3, 12, 9));

  group('isInDateRange', () {
    test('includes the first and the last day in full', () {
      expect(isInDateRange(DateTime(2026, 3, 10), range), isTrue);
      expect(isInDateRange(DateTime(2026, 3, 12, 23, 59, 59, 999), range), isTrue);
    });

    test('excludes the day before and the day after', () {
      expect(isInDateRange(DateTime(2026, 3, 9, 23, 59, 59), range), isFalse);
      expect(isInDateRange(DateTime(2026, 3, 13), range), isFalse);
    });

    test('a one-day range holds only that day', () {
      final day = (start: DateTime(2026, 12, 31), end: DateTime(2026, 12, 31));
      expect(isInDateRange(DateTime(2026, 12, 31, 12), day), isTrue);
      expect(isInDateRange(DateTime(2027, 1, 1), day), isFalse);
    });
  });

  group('DateFilter', () {
    Future<void> pump(
      WidgetTester tester, {
      required ({DateTime start, DateTime end})? range,
      required void Function(({DateTime start, DateTime end})? range) onChanged,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SailTheme(
            data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
            child: Scaffold(
              body: DateFilter(range: range, onChanged: onChanged),
            ),
          ),
        ),
      );
    }

    testWidgets('a tap on an active filter clears it', (tester) async {
      var cleared = false;
      await pump(tester, range: range, onChanged: (r) => cleared = r == null);

      await tester.tap(find.byType(DateFilter));
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
      expect(find.byType(DateRangePickerDialog), findsNothing);
    });

    testWidgets('a tap with no filter opens the range picker', (tester) async {
      await pump(tester, range: null, onChanged: (_) {});

      await tester.tap(find.byType(DateFilter));
      await tester.pumpAndSettle();

      expect(find.byType(DateRangePickerDialog), findsOneWidget);
    });
  });
}
