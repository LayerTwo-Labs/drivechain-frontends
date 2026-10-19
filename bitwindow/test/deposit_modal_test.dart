import 'dart:async';
import 'dart:io';

import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/mocks/mocks.dart';

import 'test_utils.dart';

class _SlowThunderRPC extends MockThunderRPC {
  final Completer<String> address = Completer<String>();
  Completer<String>? next;

  _SlowThunderRPC() {
    setConnected(true);
  }

  @override
  Future<String> getDepositAddress() => next?.future ?? address.future;
}

class _BalanceWallet implements OrchestratorWalletRPC {
  final Map<String, int> sats;

  _BalanceWallet(this.sats);

  @override
  Future<wmpb.GetBalanceResponse> getBalance(String walletId) async =>
      wmpb.GetBalanceResponse(confirmedSats: sats[walletId]!.toDouble());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet;

  _FakeOrchestrator(this.wallet);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WalletData _wallet(String id, {String name = 'Enforcer', bool watchOnly = false}) => WalletData(
  version: 1,
  master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
  l1: L1Wallet(mnemonic: ''),
  sidechains: const [],
  id: id,
  name: name,
  gradient: WalletGradient.fromWalletId(id),
  createdAt: DateTime(2026),
  walletType: BinaryType.BINARY_TYPE_ENFORCER,
  isWatchOnly: watchOnly,
);

Finder _depositButton() => find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Deposit');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WalletReaderProvider walletReader;
  late Map<String, int> balanceSats;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    balanceSats = {'enforcer-1': 50000000};
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(_BalanceWallet(balanceSats)));
    walletReader = WalletReaderProvider(Directory.systemTemp);
    walletReader.wallets = [_wallet('enforcer-1')];
    walletReader.activeWalletId = 'enforcer-1';
    GetIt.I.registerSingleton<WalletReaderProvider>(walletReader);
    // No sidechain binary, so the modal reaches no RPC and prefills nothing.
    // ignore: invalid_use_of_visible_for_testing_member
    GetIt.I.registerSingleton<BinaryProvider>(BinaryProvider.test(appDir: Directory.systemTemp, binaries: []));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpModal(WidgetTester tester) async {
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(const DepositModal(slot: 9, sidechainName: 'Thunder'));
    await tester.pump();
  }

  testWidgets('a stopped sidechain leaves the address field open for a paste', (tester) async {
    await pumpModal(tester);

    final field = tester.widget<SailTextField>(find.byType(SailTextField).first);
    expect(field.readOnly, isFalse);
    expect(field.controller.text, isEmpty);
    expect(tester.widget<SailButton>(_depositButton()).disabled, isTrue);
  });

  testWidgets('a paste during the address read survives the answer', (tester) async {
    final rpc = _SlowThunderRPC();
    GetIt.I.registerSingleton<ThunderRPC>(rpc);
    await GetIt.I.unregister<BinaryProvider>();
    // ignore: invalid_use_of_visible_for_testing_member
    GetIt.I.registerSingleton<BinaryProvider>(BinaryProvider.test(appDir: Directory.systemTemp, binaries: [Thunder()]));

    await pumpModal(tester);
    await tester.enterText(find.byType(SailTextField).first, 's9_pastedaddress_abc123');
    rpc.address.complete('s9_fetchedaddress_def456');
    await tester.pump();

    final field = tester.widget<SailTextField>(find.byType(SailTextField).first);
    expect(field.controller.text, 's9_pastedaddress_abc123');
  });

  testWidgets('a paste during a manual address read survives the answer', (tester) async {
    final rpc = _SlowThunderRPC();
    GetIt.I.registerSingleton<ThunderRPC>(rpc);
    await GetIt.I.unregister<BinaryProvider>();
    // ignore: invalid_use_of_visible_for_testing_member
    GetIt.I.registerSingleton<BinaryProvider>(BinaryProvider.test(appDir: Directory.systemTemp, binaries: [Thunder()]));

    await pumpModal(tester);
    rpc.address.complete('s9_firstaddress_111111');
    await tester.pump();
    expect(tester.widget<SailTextField>(find.byType(SailTextField).first).controller.text, 's9_firstaddress_111111');

    rpc.next = Completer<String>();
    await tester.tap(find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.iconRestart));
    await tester.pump();
    await tester.enterText(find.byType(SailTextField).first, 's9_pastedaddress_abc123');
    rpc.next!.complete('s9_secondaddress_222222');
    await tester.pump();

    final field = tester.widget<SailTextField>(find.byType(SailTextField).first);
    expect(field.controller.text, 's9_pastedaddress_abc123');
  });

  testWidgets('a pasted address with an amount arms the deposit button', (tester) async {
    await pumpModal(tester);

    await tester.enterText(find.byType(SailTextField).first, 's9_pastedaddress_abc123');
    await tester.enterText(find.widgetWithText(NumericField, 'Deposit Amount').first, '1.5');
    await tester.pump();

    expect(tester.widget<SailButton>(_depositButton()).disabled, isFalse);
  });

  testWidgets('a pasted error text never reaches the deposit call', (tester) async {
    await pumpModal(tester);

    await tester.enterText(
      find.byType(SailTextField).first,
      'Exception: Solana is not running. Paste a deposit address.',
    );
    await tester.enterText(find.widgetWithText(NumericField, 'Deposit Amount').first, '0.005');
    await tester.enterText(find.widgetWithText(NumericField, 'Fee').first, '0.0001');
    await tester.pump();
    await tester.ensureVisible(_depositButton());
    await tester.tap(_depositButton());
    await tester.pump();

    expect(find.byType(SailInlineError), findsOneWidget);
    expect(find.textContaining('Invalid deposit address'), findsOneWidget);
  });

  Finder maxButton() => find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'MAX');
  Finder amountField() => find.widgetWithText(NumericField, 'Deposit Amount').first;
  Finder feeField() => find.widgetWithText(NumericField, 'Fee').first;
  String amountText(WidgetTester tester) => tester.widget<NumericField>(amountField()).controller!.text;

  Future<void> useMax(WidgetTester tester) async {
    await tester.tap(maxButton());
    await tester.pump();
  }

  testWidgets('MAX fills the available balance minus the fee', (tester) async {
    await pumpModal(tester);

    expect(find.text('Available'), findsOneWidget);
    expect(find.text(GetIt.I<FormatterProvider>().formatSats(50000000)), findsOneWidget);

    await tester.enterText(feeField(), '0.0001');
    await useMax(tester);

    expect(amountText(tester), '0.49990000');
  });

  testWidgets('MAX waits for a fee', (tester) async {
    await pumpModal(tester);

    await tester.enterText(feeField(), '');
    await tester.pump();

    expect(tester.widget<SailButton>(maxButton()).disabled, isTrue);
  });

  testWidgets('MAX is off when the fee takes the whole balance', (tester) async {
    balanceSats['enforcer-1'] = 10000;
    await pumpModal(tester);

    await tester.enterText(feeField(), '0.0001');
    await tester.pump();

    expect(tester.widget<SailButton>(maxButton()).disabled, isTrue);
  });

  testWidgets('a MAX amount follows a fee change', (tester) async {
    await pumpModal(tester);

    await tester.enterText(feeField(), '0.0001');
    await useMax(tester);
    await tester.enterText(feeField(), '0.0002');
    await tester.pump();

    expect(amountText(tester), '0.49980000');
  });

  testWidgets('a typed amount stops the MAX follow', (tester) async {
    await pumpModal(tester);

    await tester.enterText(feeField(), '0.0001');
    await useMax(tester);
    await tester.enterText(amountField(), '0.1');
    await tester.enterText(feeField(), '0.0002');
    await tester.pump();

    expect(amountText(tester), '0.1');
  });

  testWidgets('a MAX amount follows a switch of the active wallet', (tester) async {
    walletReader.wallets = [_wallet('enforcer-1'), _wallet('core-1', name: 'Savings')];
    balanceSats['core-1'] = 20000000;
    await pumpModal(tester);

    await tester.enterText(feeField(), '0.0001');
    await useMax(tester);
    walletReader.activeWalletId = 'core-1';
    // ignore: invalid_use_of_protected_member
    walletReader.notifyListeners();
    await tester.pump();

    expect(amountText(tester), '0.19990000');
  });

  testWidgets('a funding wallet other than the active one shows its own balance', (tester) async {
    walletReader.wallets = [_wallet('enforcer-1'), _wallet('core-1', name: 'Savings')];
    balanceSats['core-1'] = 20000000;
    await pumpModal(tester);

    await tester.tap(find.byType(SailDropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Savings').last);
    await tester.pumpAndSettle();

    final formatter = GetIt.I<FormatterProvider>();
    expect(find.text(formatter.formatSats(20000000)), findsOneWidget);
    expect(find.text(formatter.formatSats(50000000)), findsNothing);
  });
}
