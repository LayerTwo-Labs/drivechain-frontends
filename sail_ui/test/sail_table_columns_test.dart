import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _table({required bool withAddress}) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: SizedBox(
          width: 800,
          height: 400,
          child: SailTable(
            getRowId: (index) => 'row$index',
            headerBuilder: (context) => [
              const SailTableHeaderCell(name: 'Transaction'),
              if (withAddress) const SailTableHeaderCell(name: 'Address'),
              const SailTableHeaderCell(name: 'Amount'),
            ],
            rowBuilder: (context, index, selected) => [
              const SailTableCell(value: 'd1'),
              if (withAddress) const SailTableCell(value: 'sc1'),
              const SailTableCell(value: '12300 sats'),
            ],
            rowCount: 1,
            drawGrid: false,
          ),
        ),
      ),
    ),
  );
}

Widget _sizedTable({required double slotWidth, required bool hugAmount}) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: SizedBox(
          width: 800,
          height: 400,
          child: SailTable(
            key: ValueKey('$slotWidth-$hugAmount'),
            getRowId: (index) => 'row$index',
            headerBuilder: (context) => const [
              SailTableHeaderCell(name: 'N'),
              SailTableHeaderCell(name: 'Name'),
              SailTableHeaderCell(name: 'Amount'),
            ],
            rowBuilder: (context, index, selected) => [
              SailTableCell(value: '255', width: slotWidth),
              const SailTableCell(value: 'Truthcoin'),
              SailTableCell(value: '115.0255,5423 ECX', hugContent: hugAmount),
            ],
            rowCount: 1,
            drawGrid: false,
          ),
        ),
      ),
    ),
  );
}

/// A 100-row table where only row 50 carries the wide amount, so the sample of
/// the first and last ten rows never sees it.
Widget _wideRowInTheMiddle({double textScale = 1.0}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: SailTable(
              getRowId: (index) => 'row$index',
              headerBuilder: (context) => const [
                SailTableHeaderCell(name: 'Name'),
                SailTableHeaderCell(name: 'Amount'),
              ],
              rowBuilder: (context, index, selected) => [
                const SailTableCell(value: 'Truthcoin'),
                SailTableCell(value: index == 50 ? _wideAmount : '1 ECX', hugContent: true),
              ],
              rowCount: 100,
              drawGrid: false,
            ),
          ),
        ),
      ),
    ),
  );
}

const _wideAmount = '115.0255,5423 ECX';

double _renderedWidth(String text, double scale) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: SailStyleValues.thirteen),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.linear(scale),
  )..layout();
  return painter.width;
}

Finder _cell(String value) => find.byWidgetPredicate((widget) => widget is SailTableCell && widget.value == value);

void main() {
  // A source that names no address drops that column. A refresh can add it
  // back, and the table reads every width by column index.
  testWidgets('a changed column count keeps the table alive', (tester) async {
    await tester.pumpWidget(_table(withAddress: false));
    await tester.pumpAndSettle();
    expect(find.text('Address'), findsNothing);

    await tester.pumpWidget(_table(withAddress: true));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Address'), findsOneWidget);

    await tester.pumpWidget(_table(withAddress: false));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Address'), findsNothing);
  });

  // The default minimum used to win over the width a cell asked for, so a
  // three-character column sat at 60 px with a gap after it.
  testWidgets('a width under the default minimum holds', (tester) async {
    await tester.pumpWidget(_sizedTable(slotWidth: 40, hugAmount: false));
    await tester.pumpAndSettle();

    expect(tester.getSize(_cell('255')).width, lessThan(defaultMinColumnWidth));
  });

  testWidgets('a hugging column takes none of the free width', (tester) async {
    await tester.pumpWidget(_sizedTable(slotWidth: 40, hugAmount: false));
    await tester.pumpAndSettle();
    final stretched = tester.getSize(_cell('115.0255,5423 ECX')).width;

    await tester.pumpWidget(_sizedTable(slotWidth: 40, hugAmount: true));
    await tester.pumpAndSettle();
    final hugged = tester.getSize(_cell('115.0255,5423 ECX')).width;

    expect(hugged, lessThan(stretched));
    expect(tester.getSize(_cell('Truthcoin')).width, greaterThan(stretched));
  });

  testWidgets('a hugging column fits a row outside the sample', (tester) async {
    await tester.pumpWidget(_wideRowInTheMiddle());
    await tester.pumpAndSettle();

    expect(tester.getSize(_cell('1 ECX').first).width, greaterThanOrEqualTo(_renderedWidth(_wideAmount, 1) + 24));
  });

  // The font-size slider changes the scale under a mounted table, so the
  // widths must not stay at the measurement of the previous scale.
  testWidgets('a hugging column follows a text scale the user changes', (tester) async {
    await tester.pumpWidget(_wideRowInTheMiddle());
    await tester.pumpAndSettle();

    await tester.pumpWidget(_wideRowInTheMiddle(textScale: 1.5));
    await tester.pumpAndSettle();

    expect(tester.getSize(_cell('1 ECX').first).width, greaterThanOrEqualTo(_renderedWidth(_wideAmount, 1.5) + 24));
  });
}
