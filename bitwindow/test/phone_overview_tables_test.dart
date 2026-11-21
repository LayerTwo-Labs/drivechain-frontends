import 'package:bitwindow/pages/overview_page.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  final time = DateTime.utc(2026, 11, 1, 9, 42, 13);
  final timeText = time.toLocal().toString();

  RecentTransaction tx() => RecentTransaction(
    txid: 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
    feeSats: Int64(141),
    virtualSize: 222,
    time: Timestamp.fromDateTime(time),
    confirmedInBlock: 1022811,
  );

  double cellWidth(WidgetTester tester, String value) =>
      tester.getSize(find.ancestor(of: find.text(value), matching: find.byType(SailTableCell))).width;

  Future<void> pumpTable(WidgetTester tester, double width) async {
    await loadBundledFonts();
    await tester.pumpSailPage(
      SizedBox(
        width: width,
        height: 300,
        child: LatestTransactionTable(entries: [tx()]),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('on a phone the latest transactions fit the full time next to a narrow fee and height', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await pumpTable(tester, 390);

    expect(cellWidth(tester, '141'), closeTo(56, 1));
    expect(cellWidth(tester, '1022811'), closeTo(76, 1));
    final timeLine = tester.getSize(find.text(timeText));
    expect(timeLine.height, tester.getSize(find.text('141')).height);
    expect(timeLine.width, lessThanOrEqualTo(cellWidth(tester, timeText) - 24));
    expect(tester.takeException(), isNull);
  });

  testWidgets('on the desktop the latest transactions keep their stretched columns', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await pumpTable(tester, 1200);

    expect(cellWidth(tester, '141'), greaterThan(56));
    expect(cellWidth(tester, '1022811'), greaterThan(76));
  });

  final graffitiTime = DateTime(2026, 5, 22, 8, 8);

  OPReturn graffiti() => OPReturn(
    id: Int64(1),
    message: 'Chancellor on brink of second bailout for banks',
    txid: 'f0e1d2c3b4a5f0e1d2c3b4a5f0e1d2c3b4a5f0e1d2c3b4a5f0e1d2c3b4a5f0e1',
    height: 1022745,
    createTime: Timestamp.fromDateTime(graffitiTime),
  );

  Future<void> pumpGraffiti(WidgetTester tester, double width) async {
    await loadBundledFonts();
    await tester.pumpSailPage(
      SizedBox(
        width: width,
        height: 300,
        child: GraffitiTable(entries: [graffiti()], onSort: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('on a phone the graffiti table shows time, height and a message that fills the rest', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await pumpGraffiti(tester, 390);

    const shortTime = '2026-05-22 08:08';
    expect(cellWidth(tester, shortTime), closeTo(136, 1));
    expect(cellWidth(tester, '1022745'), closeTo(76, 1));
    expect(find.text('TXID'), findsNothing);
    final message = cellWidth(tester, 'Chancellor on brink of second bailout for banks');
    expect(message, closeTo(390 - 136 - 76, 2));
    expect(tester.getSize(find.text(shortTime)).height, tester.getSize(find.text('1022745')).height);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on the desktop the graffiti table keeps every column and the long time', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await pumpGraffiti(tester, 1200);

    expect(find.text('TXID'), findsOneWidget);
    expect(find.text(graffitiTime.format()), findsOneWidget);
  });
}
