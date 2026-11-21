import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

SidechainOverview _sidechain(int slot, String title, {String? chaintipTxid}) => SidechainOverview(
  ListSidechainsResponse_Sidechain(slot: slot, title: title, chaintipTxid: chaintipTxid ?? 'tx$slot'),
  [],
  [],
);

void main() {
  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
  });

  tearDown(() => GetIt.I.reset());

  Future<ValueNotifier<List<SidechainOverview?>>> pumpTable(
    WidgetTester tester,
    List<SidechainOverview?> blocks,
  ) async {
    final notifier = ValueNotifier<List<SidechainOverview?>>(blocks);
    await tester.binding.setSurfaceSize(const Size(1200, 600));
    await tester.pumpSailPage(
      SizedBox(
        width: 1000,
        height: 500,
        child: ValueListenableBuilder(
          valueListenable: notifier,
          builder: (context, value, _) => ActiveSidechainsTable(blocks: value),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return notifier;
  }

  List<String> shownTitles(WidgetTester tester) => tester
      .widgetList<SailTableCell>(find.byType(SailTableCell))
      .map((cell) => cell.value)
      .where((v) => v.startsWith('Chain'))
      .toList();

  testWidgets('shows a sidechain that activates while the table is open', (tester) async {
    final notifier = await pumpTable(tester, []);
    expect(find.text('No active sidechains'), findsOneWidget);

    notifier.value = [_sidechain(21, 'Chain A')];
    await tester.pumpAndSettle();

    expect(find.text('No active sidechains'), findsNothing);
    expect(shownTitles(tester), ['Chain A']);
  });

  testWidgets('keeps the sort order when the list changes', (tester) async {
    final notifier = await pumpTable(tester, [_sidechain(9, 'Chain B')]);

    await tester.tap(find.text('#'));
    await tester.pumpAndSettle();
    notifier.value = [_sidechain(9, 'Chain B'), _sidechain(21, 'Chain A'), _sidechain(2, 'Chain C')];
    await tester.pumpAndSettle();

    expect(shownTitles(tester), ['Chain A', 'Chain B', 'Chain C']);
  });

  testWidgets('a tap on each header sorts without an error', (tester) async {
    await pumpTable(tester, [_sidechain(9, 'Chain B'), _sidechain(2, 'Chain C')]);

    for (final header in ['#', 'Active', 'Name', 'CTIP TxID']) {
      await tester.tap(find.text(header));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: header);
    }
  });

  testWidgets('a tap selects one row when two sidechains have no chaintip', (tester) async {
    await pumpTable(tester, [
      _sidechain(21, 'Chain A', chaintipTxid: ''),
      _sidechain(22, 'Chain B', chaintipTxid: ''),
    ]);

    await tester.tap(find.text('Chain A'));
    await tester.pump(kDoubleTapTimeout);
    await tester.pumpAndSettle();

    final selected = tester
        .widgetList(find.byWidgetPredicate((w) => w.runtimeType.toString() == '_TableRow'))
        .where((row) => (row as dynamic).selected as bool)
        .length;
    expect(selected, 1);
  });

  testWidgets('a double tap opens the chaintip of that sidechain', (tester) async {
    await pumpTable(tester, [_sidechain(9, 'Chain B'), _sidechain(2, 'Chain C')]);

    await tester.tap(find.text('Chain B'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Chain B'));
    await tester.pump(const Duration(milliseconds: 500));

    final dialog = tester.widget<TransactionDetailsDialog>(find.byType(TransactionDetailsDialog));
    expect(dialog.txid, 'tx9');
  });
}
