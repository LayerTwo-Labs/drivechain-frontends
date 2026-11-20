import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

const _pageKey = ValueKey('page');

Widget _app(Widget page, {bool dark = false}) {
  return MaterialApp(
    home: SailTheme(
      data: dark
          ? SailThemeData.darkTheme(SailColorScheme.orange, false, SailFontValues.inter)
          : SailThemeData.lightTheme(SailColorScheme.orange, false, SailFontValues.inter),
      child: Scaffold(
        body: RepaintBoundary(
          key: _pageKey,
          child: SizedBox.expand(child: page),
        ),
      ),
    ),
  );
}

Widget _card(int rows, {bool shrinkWrap = false}) {
  return SailCard(
    title: 'Coins',
    bottomPadding: false,
    child: SailTable(
      shrinkWrap: shrinkWrap,
      drawGrid: true,
      getRowId: (i) => 'r$i',
      rowBackgroundColor: (i) => i % 4 == 0 ? const Color(0x2200AA00) : null,
      headerBuilder: (context) => const [
        SailTableHeaderCell(name: 'Name'),
        SailTableHeaderCell(name: 'Address'),
        SailTableHeaderCell(name: 'Amount', alignment: Alignment.centerRight),
      ],
      rowBuilder: (context, i, selected) => [
        SailTableCell(value: 'row $i'),
        SailTableCell(value: 'addr ${i * 7919}', monospace: true),
        SailTableCell(value: '${i * 1000} sats', alignment: Alignment.centerRight),
      ],
      rowCount: rows,
      emptyPlaceholder: 'No rows',
    ),
  );
}

Widget _lazyPage(int rows, {double minHeight = 300}) => CustomScrollView(
  slivers: [
    const SliverToBoxAdapter(child: SizedBox(height: 120)),
    SliverSailTable(minHeight: minHeight, child: _card(rows)),
  ],
);

// Every row fits in the box, so the table's own list never scrolls.
Widget _eagerPage(int rows, double height) => SingleChildScrollView(
  child: Column(
    children: [
      const SizedBox(height: 120),
      SizedBox(height: height, child: _card(rows)),
    ],
  ),
);

Finder get _rows => find.byWidgetPredicate((w) => w.runtimeType.toString() == '_TableRow');

ScrollableState _vertical(WidgetTester tester) => tester
    .stateList<ScrollableState>(find.byType(Scrollable))
    .firstWhere((s) => s.widget.axisDirection == AxisDirection.down);

Future<Uint8List> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_pageKey));
  return (await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }))!;
}

Future<List<Uint8List>> _shots(WidgetTester tester, List<double> offsets) async {
  final shots = <Uint8List>[];
  for (final offset in offsets) {
    _vertical(tester).position.jumpTo(offset);
    await tester.pumpAndSettle();
    shots.add(await _pixels(tester));
  }
  return shots;
}

void main() {
  for (final dark in [false, true]) {
    for (final rows in [0, 3, 20, 300]) {
      testWidgets('a table in a SliverSailTable draws the pixels of a table that builds every row: '
          '$rows rows, ${dark ? 'dark' : 'light'}', (tester) async {
        tester.view.physicalSize = const Size(900, 600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_app(_lazyPage(rows), dark: dark));
        await tester.pumpAndSettle();
        final height = tester.getSize(find.byType(SailCard)).height;
        final max = _vertical(tester).position.maxScrollExtent;
        final offsets = [
          0.0,
          if (max > 0) ...[max / 3, max / 2 + 0.5, max],
        ];
        final lazy = await _shots(tester, offsets);

        await tester.pumpWidget(_app(_eagerPage(rows, height), dark: dark));
        await tester.pumpAndSettle();
        expect(_vertical(tester).position.maxScrollExtent, max);
        final eager = await _shots(tester, offsets);

        for (var i = 0; i < offsets.length; i++) {
          expect(lazy[i], eager[i], reason: 'offset ${offsets[i]}');
        }
      });
    }
  }

  testWidgets('a SliverSailTable builds only the rows near the viewport, and the page scrolls to the last row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(_lazyPage(2000)));
    await tester.pumpAndSettle();
    expect(_rows.evaluate().length, lessThan(30));
    expect(find.text('row 0'), findsOneWidget);

    final position = _vertical(tester).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(_rows.evaluate().length, lessThan(30));
    expect(tester.getRect(find.text('row 1999')).bottom, lessThanOrEqualTo(600));
    expect(find.text('row 0'), findsNothing);
    expect(find.byType(Scrollable), findsNWidgets(2), reason: 'the page scroll and the horizontal table scroll');
  });

  testWidgets('a SliverSailTable box is the min height, or the height that shows each row', (tester) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late StateSetter setRows;
    var rows = 3;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) {
            setRows = setState;
            return CustomScrollView(slivers: [SliverSailTable(minHeight: 400, child: _card(rows))]);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SailCard)).height, 400);

    setRows(() => rows = 50);
    await tester.pumpAndSettle();
    final tall = tester.getSize(find.byType(SailCard)).height;
    final rowsTop = tester.getTopLeft(find.text('row 0')).dy - 12;
    expect(tall, closeTo(rowsTop + 50 * 40, 20));
    final position = _vertical(tester).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('row 49')).bottom, lessThanOrEqualTo(600));

    setRows(() => rows = 3);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SailCard)).height, 400);
  });

  testWidgets('a row count change inside the box resizes the box', (tester) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late StateSetter setRows;
    var rows = 50;
    final table = StatefulBuilder(
      builder: (context, setState) {
        setRows = setState;
        return _card(rows);
      },
    );
    await tester.pumpWidget(
      _app(CustomScrollView(slivers: [SliverSailTable(minHeight: 400, child: table)])),
    );
    await tester.pumpAndSettle();
    final tall = tester.getSize(find.byType(SailCard)).height;
    expect(tall, greaterThan(50 * 40));

    setRows(() => rows = 40);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SailCard)).height, tall - 10 * 40);
  });

  testWidgets('a shrink-wrapped table in a bounded box builds only the rows that fit', (tester) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(height: 400, child: _card(300, shrinkWrap: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // The rows past the box overflow it, as before.
    expect(tester.takeException(), isFlutterError);
    expect(_rows.evaluate().length, lessThanOrEqualTo(10));
    expect(find.text('row 0'), findsOneWidget);
  });
}
