import 'dart:io';

import 'package:bitwindow/pages/message_signer.dart';
import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/pages/wallet/cash_check_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'mocks/api_mock.dart';
import 'test_utils.dart';

class _FailingWalletAPI extends MockWalletAPI {
  @override
  Future<String> createSidechainDeposit(String walletId, int slot, String destination, double amount, double fee) =>
      Future.error(Exception('insufficient funds'));
}

class _FailingAPI extends MockAPI {
  final WalletAPI _wallet = _FailingWalletAPI();

  @override
  WalletAPI get wallet => _wallet;

  _FailingAPI() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);
}

class _FailingOrchestratorWallet implements OrchestratorWalletRPC {
  @override
  Future<wmpb.GetNewAddressResponse> getNewAddress(String walletId, {Object? addressType}) =>
      Future.error(Exception('backend down'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet = _FailingOrchestratorWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions extends ChangeNotifier implements TransactionProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSidechains extends ChangeNotifier implements SidechainProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

Finder _inline(String text) => find.descendant(of: find.byType(SailInlineError), matching: find.textContaining(text));

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
    // ignore: invalid_use_of_visible_for_testing_member
    GetIt.I.registerSingleton<BinaryProvider>(BinaryProvider.test(appDir: Directory.systemTemp, binaries: []));
    GetIt.I.registerSingleton<BitwindowRPC>(_FailingAPI());
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactions());
    GetIt.I.registerSingleton<SidechainProvider>(_FakeSidechains());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(child);
    await tester.pump();
  }

  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.byWidgetPredicate((w) => w is SailButton && w.label == label);
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();
    await tester.pump();
  }

  group('deposit', () {
    testWidgets('a failed deposit shows its error under the button, not in a toast', (tester) async {
      await pump(tester, const DepositModal(slot: 9, sidechainName: 'Thunder'));
      await tester.enterText(find.byType(SailTextField).first, 's9_pastedaddress_abc123');
      await tester.enterText(find.widgetWithText(NumericField, 'Deposit Amount').first, '1.5');
      await tester.pump();

      await tapButton(tester, 'Deposit');

      expect(_inline('insufficient funds'), findsOneWidget);
      expect(find.textContaining('insufficient funds'), findsOneWidget);
    });

    testWidgets('an edit clears the deposit error', (tester) async {
      await pump(tester, const DepositModal(slot: 9, sidechainName: 'Thunder'));
      await tester.enterText(find.byType(SailTextField).first, 's9_pastedaddress_abc123');
      await tester.enterText(find.widgetWithText(NumericField, 'Deposit Amount').first, '1.5');
      await tester.pump();
      await tapButton(tester, 'Deposit');
      expect(find.byType(SailInlineError), findsOneWidget);

      await tester.enterText(find.widgetWithText(NumericField, 'Deposit Amount').first, '2');
      await tester.pump();

      expect(find.byType(SailInlineError), findsNothing);
    });
  });

  group('cash check', () {
    testWidgets('an empty key shows the error next to the form', (tester) async {
      await pump(tester, const CashCheckPage());

      await tapButton(tester, 'Cash Check');

      expect(_inline('Please enter a private key'), findsOneWidget);
      expect(find.textContaining('Please enter a private key'), findsOneWidget);
    });

    testWidgets('typing a key clears the error', (tester) async {
      await pump(tester, const CashCheckPage());
      await tapButton(tester, 'Cash Check');
      expect(find.byType(SailInlineError), findsOneWidget);

      await tester.enterText(find.byType(SailTextField), 'cVt4o7BGAig1UXywgGSmARhxMdzP5qvQsxKkSsc1XEkw3tDTQFpy');
      await tester.pump();

      expect(find.byType(SailInlineError), findsNothing);
    });

    testWidgets('a failed sweep shows the error next to the form', (tester) async {
      await pump(tester, const CashCheckPage());
      await tester.enterText(find.byType(SailTextField), 'cVt4o7BGAig1UXywgGSmARhxMdzP5qvQsxKkSsc1XEkw3tDTQFpy');
      await tester.pump();

      await tapButton(tester, 'Cash Check');

      expect(_inline('Failed to cash check'), findsOneWidget);
      expect(find.textContaining('Failed to cash check'), findsOneWidget);
    });
  });

  testWidgets('a failed signature shows the error under the sign button', (tester) async {
    GetIt.I.get<WalletReaderProvider>().activeWalletId = null;
    await pump(tester, const SignMessageTab());

    await tapButton(tester, 'Sign Message');

    expect(_inline('No active wallet'), findsOneWidget);
    expect(find.textContaining('No active wallet'), findsOneWidget);
  });
}
