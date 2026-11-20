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

  group('phoneBucketLabel', () {
    final buckets = [
      for (final label in ['0.0001 - 0.0010', '0.001 - 0.010', '0.01 - 0.10', '0.1 - 1.0', '1.0 - 9.9', '10.0 - 42.0'])
        UTXOBucket(label: label),
    ];

    test('drops the leading zero and the trailing zeros', () {
      expect(
        [for (var i = 0; i < buckets.length; i++) phoneBucketLabel(buckets, i)],
        [
          '<.001',
          '.001–.01',
          '.01–.1',
          '.1–1',
          '1–9.9',
          '>10',
        ],
      );
    });

    test('a single bucket shows its full range', () {
      expect(phoneBucketLabel([UTXOBucket(label: '0.01 - 0.10')], 0), '.01–.1');
    });

    test('a label that is not a range stays', () {
      expect(phoneBucketLabel([UTXOBucket(label: 'Other')], 0), 'Other');
    });
  });

  for (final phone in [true, false]) {
    final name = phone ? 'phone' : 'desktop';

    testWidgets('the $name UTXO table shows ${phone ? 'Amount, Label and Output' : 'every column'}', (tester) async {
      SailStyleValues.phoneLayoutOverride = phone;
      final coin = UnspentOutput(output: 'aa11:0', address: 'bc1qxy2kgdygjrsqtzq', valueSats: Int64(100000));

      await tester.pumpSailPage(UTXOTable(entries: [coin], model: LatestUTXOsViewModel()));
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
