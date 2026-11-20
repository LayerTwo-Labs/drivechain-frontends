import 'package:bitwindow/pages/wallet/wallet_utxos.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/providers/consolidation_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

class _Transactions extends ChangeNotifier implements TransactionProvider {
  @override
  List<UnspentOutput> utxos = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Wallet extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'w1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Consolidation extends ChangeNotifier implements ConsolidationProvider {
  @override
  Set<String> get reservedOutpoints => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _start = DateTime.utc(2026, 9, 1);

UnspentOutput _coin(int i, {DateTime? receivedAt}) => UnspentOutput(
  output: '${i.toRadixString(16).padLeft(64, '0')}:0',
  address: 'bcrt1qcoin$i',
  valueSats: Int64(100000 + i),
  confirmations: 3,
  receivedAt: Timestamp.fromDateTime(receivedAt ?? _start.add(Duration(hours: i))),
  derivationPath: "m/84'/1'/0'/0/$i",
);

Finder get _rows => find.byWidgetPredicate((w) => w.runtimeType.toString() == '_TableRow');

ScrollableState _page(WidgetTester tester) => tester
    .stateList<ScrollableState>(find.byType(Scrollable))
    .firstWhere((s) => s.widget.axisDirection == AxisDirection.down);

void main() {
  late _Transactions transactions;

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    transactions = _Transactions();
    GetIt.I.registerSingleton<TransactionProvider>(transactions);
    GetIt.I.registerSingleton<CoinSelectionProvider>(CoinSelectionProvider());
    GetIt.I.registerSingleton<WalletReaderProvider>(_Wallet());
    GetIt.I.registerSingleton<ConsolidationProvider>(_Consolidation());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('the UTXO tab builds only the rows near the viewport, and the page scrolls to the last one', (
    tester,
  ) async {
    transactions.utxos = [for (var i = 0; i < 2000; i++) _coin(i)];

    await tester.pumpSailPage(const Column(children: [Expanded(child: UTXOsTab())]));
    await tester.pumpAndSettle();
    expect(_rows.evaluate().length, lessThan(40));

    final position = _page(tester).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(_rows.evaluate().length, lessThan(40));
    expect(find.text("m/84'/1'/0'/0/1999"), findsOneWidget);
    expect(tester.getRect(find.text("m/84'/1'/0'/0/1999")).bottom, lessThanOrEqualTo(720));
    expect(tester.takeException(), isNull);
  });

  test('the view model gives the same entries list until the UTXOs or the date range change', () {
    transactions.utxos = [_coin(0), _coin(1)];
    final model = LatestUTXOsViewModel();
    addTearDown(model.dispose);

    final first = model.entries;
    expect(model.entries, same(first));

    transactions.utxos = [_coin(0), _coin(1), _coin(2, receivedAt: DateTime(2026, 9, 10, 12))];
    final second = model.entries;
    expect(second, hasLength(3));
    expect(model.entries, same(second));

    model.setDateRange((start: DateTime(2026, 9, 10), end: DateTime(2026, 9, 10)));
    expect(model.entries, hasLength(1));
    expect(model.entries, same(model.entries));
  });

  testWidgets('the date sort orders by microsecond, then by output', (tester) async {
    final entries = [
      _coin(1, receivedAt: _start.add(const Duration(milliseconds: 1))),
      _coin(2, receivedAt: _start),
      _coin(0, receivedAt: _start),
    ];

    await tester.pumpSailPage(UTXOTable(entries: entries, model: LatestUTXOsViewModel()));
    await tester.pumpAndSettle();

    double top(int i) => tester.getTopLeft(find.text("m/84'/1'/0'/0/$i")).dy;
    expect(top(0), lessThan(top(2)));
    expect(top(2), lessThan(top(1)));
  });
}
