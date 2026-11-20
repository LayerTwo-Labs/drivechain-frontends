import 'package:bitwindow/pages/wallet/wallet_overview.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as walletpb;

import 'test_utils.dart';

class _Overview extends ChangeNotifier implements OverviewViewModel {
  @override
  final List<walletpb.WalletTransaction> entries;

  @override
  final bool loading;

  _Overview(this.entries, {this.loading = false});

  @override
  String? get transactionsError => null;

  @override
  ({DateTime start, DateTime end})? get dateRange => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _deposit = walletpb.WalletTransaction(
  txid: 'ab' * 32,
  confirmationTime: walletpb.Confirmation(height: 0),
  sentSatoshi: Int64(1000000),
  depositRequest: walletpb.DepositRequest(slot: 9),
);

Rect _header(WidgetTester tester, String name) =>
    tester.getRect(find.byWidgetPredicate((w) => w is SailTableHeaderCell && w.name == name));

Future<void> _pumpTable(WidgetTester tester, _Overview model, {bool settle = true}) async {
  await tester.pumpSailPage(
    Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 600,
        child: TransactionTable(searchWidget: const SizedBox.shrink(), model: model),
      ),
    ),
  );
  if (SailStyleValues.phoneLayoutOverride == true) {
    await tester.usePhoneSize();
  }
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone the date is 118 px, the amount 95 px and the status takes the rest', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpTable(tester, _Overview([_deposit]));

    final date = _header(tester, 'Date');
    final status = _header(tester, 'Status');
    final amount = _header(tester, 'Amount');
    expect(date.width, closeTo(phoneDateColumnWidth, 1));
    expect(amount.width, closeTo(phoneAmountColumnWidth, 1));
    expect(status.left, greaterThan(date.right));
    expect(amount.left, greaterThan(status.right - 1));
    expect(find.text(transactionStatus(_deposit)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a phone the loading table shows bars in a panel and what it waits for', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpTable(tester, _Overview(const [], loading: true));

    expect(find.byType(OverviewLoadingSkeleton), findsOneWidget);
    expect(find.text('Waiting for enforcer to boot and wallet to sync..'), findsOneWidget);
    for (var i = 0; i < OverviewLoadingSkeleton.barCount; i++) {
      final bar = find.byKey(ValueKey('overview_skeleton_bar_$i'));
      expect(tester.getSize(bar).height, OverviewLoadingSkeleton.barHeight);
    }
  });

  testWidgets('on a desktop the loading table keeps the skeletonizer', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    // The shimmer never stops, so the frames never settle.
    await _pumpTable(tester, _Overview(const [], loading: true), settle: false);

    expect(find.byType(OverviewLoadingSkeleton), findsNothing);
    expect(find.byType(SailSkeletonizer), findsWidgets);
  });
}
