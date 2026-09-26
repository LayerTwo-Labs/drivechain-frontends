import 'dart:async';
import 'dart:io';

import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
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

WalletData _wallet(String id) => WalletData(
  version: 1,
  master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
  l1: L1Wallet(mnemonic: ''),
  sidechains: const [],
  id: id,
  name: 'Enforcer',
  gradient: WalletGradient.fromWalletId(id),
  createdAt: DateTime(2026),
  walletType: BinaryType.BINARY_TYPE_ENFORCER,
);

Finder _depositButton() => find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Deposit');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    final walletReader = WalletReaderProvider(Directory.systemTemp);
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

  testWidgets('a running FreeBank leaves the address field open for a paste and says why', (tester) async {
    GetIt.I.registerSingleton<FreeBankRPC>(FreeBankLive()..connected = true);
    await GetIt.I.unregister<BinaryProvider>();
    GetIt.I.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: Directory.systemTemp, binaries: [FreeBank()]),
    );

    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(const DepositModal(slot: 130, sidechainName: 'FreeBank'));
    await tester.pump();

    final field = tester.widget<SailTextField>(find.byType(SailTextField).first);
    expect(field.readOnly, isFalse);
    expect(field.controller.text, isEmpty);
    expect(
      find.text('Unsupported operation: fetching a FreeBank address. Paste one from your FreeBank wallet.'),
      findsOneWidget,
    );
  });

  testWidgets('a pasted address with an amount arms the deposit button', (tester) async {
    await pumpModal(tester);

    await tester.enterText(find.byType(SailTextField).first, 's9_pastedaddress_abc123');
    await tester.enterText(find.widgetWithText(NumericField, 'Deposit Amount').first, '1.5');
    await tester.pump();

    expect(tester.widget<SailButton>(_depositButton()).disabled, isFalse);
  });
}
