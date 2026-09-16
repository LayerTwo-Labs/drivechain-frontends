import 'dart:async';

import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/explorer/load_transaction_dialog.dart';
import 'package:bitwindow/pages/wallet/wallet_overview.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as walletpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

const _warning = 'This transaction burns Alphanet coins for a claim of real ECX.';
final _messages = {'backend text': _warning, 'no warning': '', 'long warning': List.filled(4, _warning).join(' ')};

class _WalletRPC implements OrchestratorWalletRPC {
  String warningMessage = '';
  List<wmpb.TransactionEntry> transactions = [];

  walletpb.GetTransactionDetailsResponse get details => walletpb.GetTransactionDetailsResponse(
    txid: 'ab' * 32,
    warningMessage: warningMessage,
  );

  @override
  Future<walletpb.GetTransactionDetailsResponse> getTransactionDetails({
    required String walletId,
    required String txid,
  }) async => details;

  @override
  Future<DecodedTransaction> decodeTransaction({required String input, String walletId = ''}) async =>
      DecodedTransaction(
        form: wmpb.DecodedForm.DECODED_FORM_PSBT,
        isPsbt: true,
        signedInputs: 0,
        hasFee: false,
        hasTotalInput: false,
        changeOutputIndexes: {},
        details: details,
      );

  @override
  Future<wmpb.ListTransactionsResponse> listTransactions({required String walletId, int count = 100}) async =>
      wmpb.ListTransactionsResponse(transactions: transactions);

  @override
  Future<wmpb.ListUnspentResponse> listUnspent(String walletId) async => wmpb.ListUnspentResponse();

  @override
  Future<wmpb.ListReceiveAddressesResponse> listReceiveAddresses(String walletId) async =>
      wmpb.ListReceiveAddressesResponse();

  @override
  Future<wmpb.GetBalanceResponse> getBalance(String walletId) async => wmpb.GetBalanceResponse();

  @override
  Future<wmpb.GetNewAddressResponse> getNewAddress(String walletId, {wmpb.AddressType? addressType}) async =>
      wmpb.GetNewAddressResponse(address: 'wallet-address');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Orchestrator implements OrchestratorRPC {
  @override
  final _WalletRPC wallet = _WalletRPC();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet-1';

  @override
  WalletData? get activeWallet => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Balance extends ChangeNotifier implements BalanceProvider {
  @override
  void setBalance(RPCConnection rpc, double confirmed, double pending) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Blockchain extends ChangeNotifier implements BlockchainProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Overview extends ChangeNotifier implements OverviewViewModel {
  @override
  final List<walletpb.WalletTransaction> entries;

  _Overview(this.entries);

  @override
  bool get loading => false;

  @override
  ({DateTime start, DateTime end})? get dateRange => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Orchestrator orchestrator;

  setUp(() async {
    await GetIt.I.reset();
    orchestrator = _Orchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    GetIt.I.registerSingleton<BalanceProvider>(_Balance());
    GetIt.I.registerSingleton<BlockchainProvider>(_Blockchain());
    await registerTestDependencies();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  void checkAlert(WidgetTester tester, String message) {
    final alerts = tester.widgetList<SailAlert>(find.byType(SailAlert));
    if (message.trim().isEmpty) {
      expect(alerts.where((alert) => alert.variant == SailAlertVariant.warning), isEmpty);
    } else {
      final alert = alerts.singleWhere((alert) => alert.variant == SailAlertVariant.warning);
      expect(alert.description, message);
      expect(find.text(message), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  }

  for (final message in {..._messages, 'blank warning': ' \n '}.entries) {
    testWidgets('the decoded transaction shows the RPC warning: ${message.key}', (tester) async {
      orchestrator.wallet.warningMessage = message.value;
      await tester.pumpSailPage(
        const Center(child: SizedBox(width: 900, height: 650, child: LoadTransactionDialog())),
      );
      await tester.enterText(find.byType(EditableText), 'psbt');
      await tester.tap(find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Decode'));
      await tester.pumpAndSettle();

      checkAlert(tester, message.value);
      await tester.tap(find.text('Inputs (0)'));
      await tester.pumpAndSettle();
      checkAlert(tester, message.value);
    });

    testWidgets('the transaction details show the RPC warning: ${message.key}', (tester) async {
      orchestrator.wallet.warningMessage = message.value;
      await tester.pumpSailPage(
        Center(
          child: SizedBox(width: 900, height: 650, child: TransactionDetailsDialog(txid: 'ab' * 32)),
        ),
      );
      await tester.pumpAndSettle();

      checkAlert(tester, message.value);
      await tester.tap(find.text('Inputs (0)'));
      await tester.pumpAndSettle();
      checkAlert(tester, message.value);
    });

    testWidgets('the history marker keeps the RPC text and status: ${message.key}', (tester) async {
      final entry = walletpb.WalletTransaction(
        txid: 'ab' * 32,
        warningMessage: message.value,
        confirmationTime: walletpb.Confirmation(height: 6),
        receivedSatoshi: Int64(10000),
      );
      await tester.pumpSailPage(TransactionTable(searchWidget: const SizedBox.shrink(), model: _Overview([entry])));
      await tester.pumpAndSettle();

      expect(find.text('Confirmed'), findsOneWidget);
      expect(tester.widgetList<SailTableHeaderCell>(find.byType(SailTableHeaderCell)), hasLength(7));
      final warnings = tester
          .widgetList<SailTooltip>(find.byType(SailTooltip))
          .where((tooltip) => tooltip.message == message.value);
      expect(warnings, message.value.trim().isEmpty ? isEmpty : hasLength(1));
      if (message.value.trim().isNotEmpty) {
        final marker = find.byWidgetPredicate((widget) => widget is SailTooltip && widget.message == message.value);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer();
        await mouse.moveTo(tester.getCenter(marker));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text(message.value), findsOneWidget);
        final textBounds = tester.getRect(find.text(message.value));
        expect(textBounds.left, greaterThanOrEqualTo(0));
        expect(textBounds.right, lessThanOrEqualTo(1200));
        await mouse.removePointer();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  test('the transaction provider keeps the RPC warning in history', () async {
    orchestrator.wallet.transactions = [
      for (final message in _messages.entries)
        wmpb.TransactionEntry(txid: message.key, warningMessage: message.value, amountSats: Int64(1000)),
    ];
    final provider = TransactionProvider();
    addTearDown(provider.dispose);
    final loaded = Completer<void>();
    provider.addListener(() {
      if ((provider.initialized || provider.error != null) && !loaded.isCompleted) {
        loaded.complete();
      }
    });
    await loaded.future;

    expect(provider.error, isNull);
    expect(
      {for (final transaction in provider.walletTransactions) transaction.txid: transaction.warningMessage},
      _messages,
    );
    expect(provider.walletTransactions.every((transaction) => transaction.note.isEmpty), isTrue);
  });
}
