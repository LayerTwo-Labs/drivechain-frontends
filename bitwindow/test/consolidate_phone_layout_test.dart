import 'package:bitwindow/pages/wallet/wallet_consolidate.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/providers/consolidation_provider.dart';
import 'package:bitwindow/providers/psbt_draft_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

final _wallet = WalletData(
  version: 1,
  master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
  l1: L1Wallet(mnemonic: ''),
  sidechains: const [],
  id: 'wallet',
  name: 'wallet',
  gradient: WalletGradient.fromWalletId('wallet'),
  createdAt: DateTime(2026),
  walletType: BinaryType.BINARY_TYPE_ENFORCER,
);

class _FakeTransactions extends ChangeNotifier implements TransactionProvider {
  @override
  List<UnspentOutput> utxos = [
    for (var i = 0; i < 3; i++)
      UnspentOutput(output: '${'$i' * 64}:0', valueSats: Int64(4000 + i), address: 'bcrt1q${'x' * 30}$i'),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCoinSelection extends ChangeNotifier implements CoinSelectionProvider {
  @override
  bool isFrozen(String outpoint) => false;

  @override
  String getLabel(String outpoint) => '';

  @override
  Set<String> get frozenOutpoints => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConsolidation extends ChangeNotifier implements ConsolidationProvider {
  @override
  List<ConsolidationRun> runs = [
    ConsolidationRun(
      index: 0,
      outpoints: const ['a:0'],
      coinCount: 12,
      vbytes: 900,
      outputSats: 50000,
      status: ConsolidationRunStatus.pending,
    )..txid = 'ab' * 32,
    ConsolidationRun(index: 1, outpoints: const ['b:0'], coinCount: 8, vbytes: 600, outputSats: 30000),
  ];

  @override
  bool running = true;

  @override
  int get sentCount => 1;

  @override
  int get confirmedCount => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet';

  @override
  WalletData? get activeWallet => _wallet;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDrafts extends ChangeNotifier implements PsbtDraftProvider {
  @override
  Set<String> get lockedOutpoints => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  await tester.pumpSailPage(const ConsolidateTab());
  if (phone) {
    await tester.binding.setSurfaceSize(const Size(390, 844));
  }
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactions());
    GetIt.I.registerSingleton<CoinSelectionProvider>(_FakeCoinSelection());
    GetIt.I.registerSingleton<ConsolidationProvider>(_FakeConsolidation());
    GetIt.I.registerSingleton<WalletReaderProvider>(_FakeWalletReader());
    GetIt.I.registerSingleton<PsbtDraftProvider>(_FakeDrafts());
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone the cards stack and the slider spans the card without step dots', (tester) async {
    await _pump(tester, phone: true);

    expect(tester.takeException(), isNull);
    final limit = tester.getRect(find.text('Coin size limit'));
    final coins = tester.getRect(find.text('Coins').first);
    final plan = tester.getRect(find.text('Plan'));
    expect(coins.top, greaterThan(limit.bottom));
    expect(plan.top, greaterThan(coins.bottom));

    final slider = find.byType(SailSlider);
    expect(tester.widget<SailSlider>(slider).showSteps, isFalse);
    expect(tester.widget<SailSlider>(slider).trackColor, isNotNull);
    final value = tester.getRect(find.text(GetIt.I<FormatterProvider>().formatSats(100000)));
    expect(value.top, greaterThan(tester.getRect(slider).bottom), reason: 'the limit shows under the slider');
    final hide = tester.getRect(find.widgetWithText(SailButton, 'Hide frozen (0)'));
    final clear = tester.getRect(find.widgetWithText(SailButton, 'Clear'));
    final coinsCard = tester.getRect(find.ancestor(of: find.text('Hide frozen (0)'), matching: find.byType(SailCard)));
    expect(hide.left, closeTo(coinsCard.left + 17, 1));
    expect(clear.right, closeTo(coinsCard.right - 17, 1));
    expect(find.byType(SailCheckbox), findsNWidgets(3), reason: 'one per coin, none in the card head');
    final runs = tester.getRect(find.text('Consolidation runs'));
    expect(runs.top, greaterThan(coins.bottom));
    expect(plan.top, greaterThan(runs.bottom));
    final card = tester.getRect(find.ancestor(of: slider, matching: find.byType(SailCard)).first);
    expect(tester.getSize(slider).width, closeTo(card.width - 32 - 2, 2));
  });

  testWidgets('on a phone each run is a two-line row with Show at the right', (tester) async {
    await _pump(tester, phone: true);

    final formatter = GetIt.I<FormatterProvider>();
    final amount = tester.getRect(find.text('1 of 2 · 12 coins'));
    final detail = tester.getRect(find.text('${formatter.formatSats(50000)} · In the mempool'));
    expect(detail.top, greaterThan(amount.bottom - 1));
    expect(detail.left, amount.left);
    expect(tester.getRect(find.widgetWithText(SailButton, 'Show')).left, greaterThan(amount.right));
    expect(find.widgetWithText(SailButton, 'Stop'), findsOneWidget);
  });

  testWidgets('the desktop keeps the plan at the side and the run columns', (tester) async {
    await _pump(tester, phone: false);

    final limit = tester.getRect(find.text('Coin size limit'));
    final plan = tester.getRect(find.text('Plan'));
    expect(plan.left, greaterThan(limit.right));
    expect(tester.widget<SailSlider>(find.byType(SailSlider)).showSteps, isTrue);
    expect(find.text('1 of 2'), findsOneWidget);
  });
}
