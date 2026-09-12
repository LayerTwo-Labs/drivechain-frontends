import 'package:bitwindow/pages/wallet/wallet_utxos.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/google/protobuf/timestamp.pb.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

class _Transactions extends ChangeNotifier implements TransactionProvider {
  @override
  List<UnspentOutput> utxos = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _confirmedAt = DateTime.utc(2026, 9, 11, 4, 10);

UnspentOutput _coin({required String output, required int confirmations, Timestamp? receivedAt}) {
  return UnspentOutput(
    output: output,
    address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
    valueSats: Int64(100000),
    confirmations: confirmations,
    receivedAt: receivedAt,
  );
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<TransactionProvider>(_Transactions());
    GetIt.I.registerSingleton<CoinSelectionProvider>(CoinSelectionProvider());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  // A dash read as "no date on any coin", so the age of a coin was invisible.
  testWidgets('the date column shows a date for a confirmed coin and Pending for a mempool one', (tester) async {
    final entries = [
      _coin(
        output: 'aa11:0',
        confirmations: 6,
        receivedAt: Timestamp.fromDateTime(_confirmedAt),
      ),
      // A mempool coin can still carry a first-seen time, so the column must
      // read the confirmation count, not the timestamp.
      _coin(
        output: 'bb22:0',
        confirmations: 0,
        receivedAt: Timestamp.fromDateTime(DateTime.utc(2026, 9, 12, 4, 10)),
      ),
    ];

    await tester.pumpSailPage(
      UTXOTable(entries: entries, model: LatestUTXOsViewModel()),
    );
    await tester.pumpAndSettle();

    expect(find.text(formatDate(_confirmedAt.toLocal())), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
  });
}
