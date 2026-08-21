import 'dart:io';

import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/psbt_draft_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/multisig_sign_panel.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as walletpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _FakeWalletRPC implements OrchestratorWalletRPC {
  wmpb.MultisigPsbtStatusResponse status = wmpb.MultisigPsbtStatusResponse(
    threshold: 2,
    signatures: 1,
    finalizable: false,
    cosignerSigned: [true, false, false],
  );

  @override
  Future<wmpb.MultisigPsbtStatusResponse> multisigPsbtStatus({
    required String walletId,
    required String psbtBase64,
  }) async {
    return status;
  }

  @override
  Future<DecodedTransaction> decodeTransaction({
    required String input,
    String walletId = '',
  }) async {
    return DecodedTransaction(
      form: wmpb.DecodedForm.DECODED_FORM_PSBT,
      isPsbt: true,
      signedInputs: 1,
      hasFee: true,
      hasTotalInput: true,
      changeOutputIndexes: {1},
      details: walletpb.GetTransactionDetailsResponse(
        inputs: [
          walletpb.TransactionInput(index: 0, prevTxid: 'aa' * 32, prevVout: 0, valueSats: Int64(30000000)),
          walletpb.TransactionInput(index: 1, prevTxid: 'bb' * 32, prevVout: 1, valueSats: Int64(10000000)),
        ],
        outputs: [
          walletpb.TransactionOutput(index: 0, valueSats: Int64(20000000), address: 'tb1qpayment'),
          walletpb.TransactionOutput(index: 1, valueSats: Int64(19997800), address: 'tb1qchange'),
        ],
        totalInputSats: Int64(40000000),
        totalOutputSats: Int64(39997800),
        feeSats: Int64(2200),
      ),
    );
  }

  @override
  Future<wmpb.ListReceiveAddressesResponse> listReceiveAddresses(String walletId) async {
    return wmpb.ListReceiveAddressesResponse(
      addresses: [wmpb.ReceiveAddress(address: 'tb1qchange', isChange: true)],
    );
  }

  @override
  Future<wmpb.ListTransactionsResponse> listTransactions({required String walletId, int count = 100}) async {
    return wmpb.ListTransactionsResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final _FakeWalletRPC wallet = _FakeWalletRPC();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestWalletReader extends WalletReaderProvider {
  _TestWalletReader() : super(Directory.systemTemp);

  void setMultisigWallet() {
    final multisig = wmpb.MultisigInfo(
      m: 2,
      n: 3,
      scriptType: 'wsh',
      cosigners: [
        wmpb.MultisigCosignerInfo(xpub: 'xpub1', fingerprint: 'c3a91c21', held: true),
        wmpb.MultisigCosignerInfo(xpub: 'xpub2', fingerprint: '7f3a91c2', hardwareDeviceType: 'trezor'),
        wmpb.MultisigCosignerInfo(xpub: 'xpub3', fingerprint: '9e2b11aa'),
      ],
    );
    wallets = [
      WalletData(
        version: 1,
        master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
        l1: L1Wallet(mnemonic: ''),
        sidechains: [],
        id: 'wallet-1',
        name: 'Cold storage',
        gradient: WalletGradient.fromWalletId('wallet-1'),
        createdAt: DateTime(2026, 8, 1),
        walletType: BinaryType.BINARY_TYPE_BITCOIND,
        multisig: multisig,
      ),
    ];
    activeWalletId = 'wallet-1';
    notifyListeners();
  }
}

void main() {
  late _FakeOrchestrator orchestrator;
  late PsbtDraftProvider draftProvider;

  Future<String> setUpPanelDeps() async {
    await GetIt.I.reset();
    await registerTestDependencies();

    orchestrator = _FakeOrchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);

    final walletReader = _TestWalletReader();
    GetIt.I.registerSingleton<WalletReaderProvider>(walletReader);
    walletReader.setMultisigWallet();

    GetIt.I.registerSingleton<AddressBookProvider>(AddressBookProvider());
    GetIt.I.registerSingleton<TransactionProvider>(TransactionProvider());

    draftProvider = PsbtDraftProvider();
    GetIt.I.registerSingleton<PsbtDraftProvider>(draftProvider);
    await draftProvider.fetch();
    final draft = await draftProvider.create('cHNidP8B', walletId: 'wallet-1');
    return draft.id;
  }

  SailButton broadcastButton(WidgetTester tester) {
    return tester.widget<SailButton>(
      find.byWidgetPredicate((w) => w is SailButton && w.label == 'Broadcast'),
    );
  }

  testWidgets('the keys table renders one row per cosigner', (tester) async {
    final draftId = await setUpPanelDeps();

    await tester.pumpSailPage(MultisigSignPanel(walletId: 'wallet-1', draftId: draftId));
    await tester.pumpAndSettle();

    expect(find.text('Key 1'), findsOneWidget);
    expect(find.text('Key 2'), findsOneWidget);
    expect(find.text('Key 3'), findsOneWidget);
    expect(find.text('This computer'), findsOneWidget);
    expect(find.text('Trezor'), findsOneWidget);
    expect(find.text('Somewhere else'), findsOneWidget);

    // The PSBT derivation records mark output 1 as change.
    expect(find.textContaining('change · back to'), findsOneWidget);
    expect(find.text('payment'), findsOneWidget);
  });

  testWidgets('only an eligible cosigner shows Sign', (tester) async {
    final draftId = await setUpPanelDeps();

    await tester.pumpSailPage(MultisigSignPanel(walletId: 'wallet-1', draftId: draftId));
    await tester.pumpAndSettle();

    // Cosigner 1 signed, cosigner 2 is a device that has not signed, and
    // cosigner 3 is watch-only. Only cosigner 2 may sign.
    expect(
      find.byWidgetPredicate((w) => w is SailButton && w.label == 'Sign'),
      findsOneWidget,
    );
    expect(find.text('Signed'), findsOneWidget);
  });

  testWidgets('Broadcast stays disabled until finalizable', (tester) async {
    final draftId = await setUpPanelDeps();

    await tester.pumpSailPage(MultisigSignPanel(walletId: 'wallet-1', draftId: draftId));
    await tester.pumpAndSettle();

    expect(broadcastButton(tester).disabled, isTrue);

    orchestrator.wallet.status = wmpb.MultisigPsbtStatusResponse(
      threshold: 2,
      signatures: 2,
      finalizable: true,
      cosignerSigned: [true, true, false],
    );
    await draftProvider.fetch();
    await tester.pumpAndSettle();

    expect(broadcastButton(tester).disabled, isFalse);
  });
}
