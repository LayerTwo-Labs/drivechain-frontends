import 'package:bitwindow/pages/wallet/wallet_utxos.dart';
import 'package:bitwindow/pages/wallet/widgets/utxo_distribution_chart.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

class _Transactions extends ChangeNotifier implements TransactionProvider {
  @override
  List<UnspentOutput> utxos = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Finder _header(String name) => find.byWidgetPredicate((w) => w is SailTableHeaderCell && w.name == name);

void main() {
  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<TransactionProvider>(_Transactions());
    GetIt.I.registerSingleton<CoinSelectionProvider>(CoinSelectionProvider());
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  group('phoneUtxoBuckets', () {
    UnspentOutput coin(String output, int sats) => UnspentOutput(output: output, valueSats: Int64(sats));

    test('sorts each coin into its decade and keeps the empty buckets', () {
      final buckets = phoneUtxoBuckets([
        coin('a:0', 99999),
        coin('b:0', 100000),
        coin('c:0', 50000000),
        coin('d:0', 60000000),
        coin('e:0', 1000000000),
      ]);

      expect([for (final b in buckets) b.label], phoneBucketLabels);
      expect([for (final b in buckets) b.count], [1, 1, 0, 2, 0, 1]);
      expect(buckets[3].outpoints, ['c:0', 'd:0']);
      expect(buckets[3].valueSats.toInt(), 110000000);
    });
  });

  testWidgets('the phone bars draw the count above each bar and the bucket label below', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    UTXOBucket? pressed;
    await tester.pumpSailPage(
      SizedBox(
        width: 342,
        child: UTXOPhoneBars(
          utxos: [
            UnspentOutput(output: 'a:0', valueSats: Int64(50000)),
            UnspentOutput(output: 'b:0', valueSats: Int64(20000000)),
            UnspentOutput(output: 'c:0', valueSats: Int64(30000000)),
          ],
          onBucketContextMenu: (bucket, _) => pressed = bucket,
        ),
      ),
    );
    await tester.usePhoneSize();

    for (final label in phoneBucketLabels) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(tester.getRect(find.text('2')).bottom, lessThan(tester.getRect(find.text('.1–1')).top));
    expect(tester.takeException(), isNull);

    await tester.longPress(find.byKey(const ValueKey('utxo_bar_3')));
    expect(pressed?.outpoints, ['b:0', 'c:0']);
  });

  for (final phone in [true, false]) {
    final name = phone ? 'phone' : 'desktop';

    testWidgets('the $name UTXO table shows ${phone ? 'Amount, Label and Output' : 'every column'}', (tester) async {
      SailStyleValues.phoneLayoutOverride = phone;
      final coin = UnspentOutput(output: 'aa11:0', address: 'bc1qxy2kgdygjrsqtzq', valueSats: Int64(100000));

      await tester.pumpSailPage(UTXOTable(entries: [coin], model: LatestUTXOsViewModel()));
      if (phone) {
        await tester.usePhoneSize();
      }
      await tester.pumpAndSettle();

      for (final shown in ['Amount', 'Label', 'Output']) {
        expect(_header(shown), findsOneWidget, reason: shown);
      }
      for (final other in ['Date', 'Deniability', 'Split', 'Address', 'Path']) {
        expect(_header(other), phone ? findsNothing : findsOneWidget, reason: other);
      }
    });

    testWidgets('the $name empty UTXO table keeps the same columns', (tester) async {
      SailStyleValues.phoneLayoutOverride = phone;

      await tester.pumpSailPage(UTXOTable(entries: const [], model: LatestUTXOsViewModel()));
      if (phone) {
        await tester.usePhoneSize();
      }
      await tester.pumpAndSettle();

      expect(find.text('No UTXOs in wallet'), findsOneWidget);
      expect(_header('Output'), findsOneWidget);
      expect(_header('Date'), phone ? findsNothing : findsOneWidget);
    });

    testWidgets('the $name UTXO help names the ${phone ? 'long press' : 'right click'}', (tester) async {
      SailStyleValues.phoneLayoutOverride = phone;

      await tester.pumpSailPage(const UTXODistributionHelp());

      expect(find.textContaining('Long-press any bar'), phone ? findsOneWidget : findsNothing);
      expect(find.textContaining('Right-click on any bar'), phone ? findsNothing : findsOneWidget);
    });
  }
}
