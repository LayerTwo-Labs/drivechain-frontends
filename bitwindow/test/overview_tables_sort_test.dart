import 'package:bitwindow/pages/overview_page.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final time = Timestamp.fromDateTime(DateTime.utc(2026, 11, 16, 16));

  RecentTransaction tx(String txid, int fee, int height) => RecentTransaction(
    txid: txid,
    feeSats: Int64(fee),
    virtualSize: 141,
    time: time,
    confirmedInBlock: height == 0 ? null : height,
  );

  Block block(int height) => Block(
    height: height,
    hash: 'hash$height',
    blockTime: Timestamp.fromDateTime(DateTime.utc(2026, 11, 16, 16, height)),
  );

  List<String> rowOrder(WidgetTester tester, List<String> labels) {
    final found = labels.where((label) => tester.any(find.text(label))).toList();
    found.sort((a, b) => tester.getTopLeft(find.text(a)).dy.compareTo(tester.getTopLeft(find.text(b)).dy));
    return found;
  }

  Widget sized(Widget child) => SizedBox(width: 1400, height: 400, child: child);

  testWidgets('latest transactions keep the chosen sort when new data arrives', (tester) async {
    final entries = ValueNotifier([tx('tx-a', 500, 3), tx('tx-b', 100, 0), tx('tx-c', 900, 7)]);
    await tester.pumpSailPage(
      sized(
        ValueListenableBuilder(
          valueListenable: entries,
          builder: (context, value, _) => LatestTransactionTable(entries: value),
        ),
      ),
    );
    await tester.pumpAndSettle();
    const txids = ['tx-a', 'tx-b', 'tx-c'];

    await tester.tap(find.text('Fee'));
    await tester.pumpAndSettle();
    expect(rowOrder(tester, txids), ['tx-b', 'tx-a', 'tx-c']);

    entries.value = [tx('tx-c', 900, 7), tx('tx-a', 500, 3), tx('tx-b', 100, 0)];
    await tester.pumpAndSettle();
    expect(rowOrder(tester, txids), ['tx-b', 'tx-a', 'tx-c']);

    await tester.tap(find.text('Height'));
    await tester.pumpAndSettle();
    expect(rowOrder(tester, txids), ['tx-b', 'tx-a', 'tx-c']);

    await tester.tap(find.text('Height'));
    await tester.pumpAndSettle();
    expect(rowOrder(tester, txids), ['tx-c', 'tx-a', 'tx-b']);
  });

  testWidgets('latest blocks keep the chosen sort when new data arrives', (tester) async {
    final blocks = ValueNotifier([block(3), block(1), block(2)]);
    await tester.pumpSailPage(
      sized(
        ValueListenableBuilder(
          valueListenable: blocks,
          builder: (context, value, _) => LatestBlocksTable(blocks: value),
        ),
      ),
    );
    await tester.pumpAndSettle();
    const hashes = ['hash1', 'hash2', 'hash3', 'hash4'];

    expect(rowOrder(tester, hashes), ['hash3', 'hash2', 'hash1']);

    await tester.tap(find.text('Height'));
    await tester.pumpAndSettle();
    expect(rowOrder(tester, hashes), ['hash1', 'hash2', 'hash3']);

    blocks.value = [block(4), block(3), block(2), block(1)];
    await tester.pumpAndSettle();
    expect(rowOrder(tester, hashes), ['hash1', 'hash2', 'hash3', 'hash4']);
  });
}
