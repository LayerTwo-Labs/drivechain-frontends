import 'dart:io';

import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/providers/psbt_draft_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/draft_panel.dart';
import 'package:bitwindow/widgets/grouped_address.dart';
import 'package:bitwindow/widgets/tx_flow_diagram.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as walletpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _FakeWalletRPC implements OrchestratorWalletRPC {
  String warningMessage = '';
  int locktime = 0;

  /// The decode reports both inputs signed once a PSBT holds this mark.
  String signedMark = 'cHNidP8B';
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
      signedInputs: input.contains(signedMark) ? 2 : 1,
      hasFee: true,
      hasTotalInput: true,
      changeOutputIndexes: {1},
      details: walletpb.GetTransactionDetailsResponse(
        warningMessage: warningMessage,
        locktime: locktime,
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
  Future<String> finalizePsbt({required String psbtBase64}) async => 'rawhex';

  @override
  Future<String> signPsbtWithDevice({required wmpb.HardwareDeviceSelector device, required String psbtBase64}) async =>
      '$psbtBase64+signed';

  @override
  Future<String> combinePsbt({required List<String> psbtsBase64}) async => psbtsBase64.last;

  @override
  Future<String> broadcastTransaction({required String walletId, required String txHex}) async => 'cc' * 32;

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

class _FakeConf implements BitcoinConfProvider {
  @override
  BitcoinNetwork get network => BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  String get ecashNetworkId => 'ecash-mainnet';

  @override
  String get ecashExplorerHost => 'explorer.example';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotifications implements NotificationProvider {
  @override
  void add({
    required String title,
    required String content,
    required DialogType dialogType,
    List<NotificationLink> links = const [],
    Future<void> Function()? onPressed,
    NotificationStyle style = NotificationStyle.toast,
    String action = '',
    Map<String, String> data = const {},
    String? id,
  }) {}

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

  void setOneKeyWallet({String hardwareDeviceType = ''}) {
    wallets = [
      WalletData(
        version: 1,
        master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
        l1: L1Wallet(mnemonic: ''),
        sidechains: [],
        id: 'wallet-1',
        name: 'Spending',
        gradient: WalletGradient.fromWalletId('wallet-1'),
        createdAt: DateTime(2026, 8, 1),
        walletType: BinaryType.BINARY_TYPE_BITCOIND,
        hardwareDeviceType: hardwareDeviceType,
      ),
    ];
    activeWalletId = 'wallet-1';
    notifyListeners();
  }
}

void main() {
  late _FakeOrchestrator orchestrator;
  late PsbtDraftProvider draftProvider;

  Future<String> setUpPanelDeps({bool oneKey = false, String hardwareDeviceType = ''}) async {
    await GetIt.I.reset();
    await registerTestDependencies();

    orchestrator = _FakeOrchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);

    final walletReader = _TestWalletReader();
    GetIt.I.registerSingleton<WalletReaderProvider>(walletReader);
    if (oneKey) {
      walletReader.setOneKeyWallet(hardwareDeviceType: hardwareDeviceType);
    } else {
      walletReader.setMultisigWallet();
    }

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

  const warning = 'This transaction burns Betanet coins for a claim of real ECX.';
  final messages = {'backend text': warning, 'no warning': '', 'long warning': List.filled(4, warning).join(' ')};
  for (final message in messages.entries) {
    testWidgets('the signature panel shows the RPC warning: ${message.key}', (tester) async {
      final draftId = await setUpPanelDeps();
      orchestrator.wallet.warningMessage = message.value;

      await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
      await tester.pumpAndSettle();

      final alerts = tester.widgetList<SailAlert>(find.byType(SailAlert));
      if (message.value.isEmpty) {
        expect(alerts.where((alert) => alert.variant == SailAlertVariant.warning), isEmpty);
      } else {
        final alert = alerts.singleWhere((alert) => alert.variant == SailAlertVariant.warning);
        expect(alert.description, message.value);
        expect(find.text(message.value), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the flow diagram stays hidden until the user asks', (tester) async {
    final draftId = await setUpPanelDeps();

    await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
    await tester.pumpAndSettle();

    final toggle = find.byWidgetPredicate((w) => w is SailButton && w.label == 'Show diagram');
    expect(find.byType(TxFlowDiagram), findsNothing);
    expect(toggle, findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(find.byType(TxFlowDiagram), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is SailButton && w.label == 'Hide diagram'), findsOneWidget);
  });

  testWidgets('the keys table renders one row per cosigner', (tester) async {
    final draftId = await setUpPanelDeps();

    await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
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

    await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
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

    await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
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

  final locktimes = {
    'the fork locktime protects the broadcast': (fork: 499999998, locktime: 499999998, unprotected: false),
    'another eCash locktime leaves the broadcast unprotected': (
      fork: 499999998,
      locktime: 499999999,
      unprotected: true,
    ),
    'an unknown fork locktime protects nothing': (fork: 0, locktime: 0, unprotected: true),
  };
  for (final entry in locktimes.entries) {
    testWidgets('a broadcast on a ${entry.value.fork} fork: ${entry.key}', (tester) async {
      final draftId = await setUpPanelDeps();
      final fork = ForkProvider()
        ..replayLockTime = entry.value.fork
        ..claims = [
          WalletClaim(
            walletId: 'wallet-1',
            walletName: 'Cold storage',
            claimableSats: 30000000,
            utxos: [walletpb.UnspentOutput(output: '${'aa' * 32}:0', valueSats: Int64(30000000))],
          ),
        ];
      GetIt.I.registerSingleton<ForkProvider>(fork);
      GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf());
      GetIt.I.registerSingleton<NotificationProvider>(_FakeNotifications());
      orchestrator.wallet.locktime = entry.value.locktime;
      orchestrator.wallet.status = wmpb.MultisigPsbtStatusResponse(
        threshold: 2,
        signatures: 2,
        finalizable: true,
        cosignerSigned: [true, true, false],
      );
      await draftProvider.fetch();

      await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
      await tester.pumpAndSettle();
      final broadcast = find.byWidgetPredicate((w) => w is SailButton && w.label == 'Broadcast');
      await tester.ensureVisible(broadcast);
      await tester.pumpAndSettle();
      expect(broadcastButton(tester).disabled, isFalse);
      await tester.tap(broadcast);
      await tester.pumpAndSettle();

      expect(fork.replayedTxids.contains('cc' * 32), entry.value.unprotected);
    });
  }

  group('a one-key wallet', () {
    Finder button(String label) => find.byWidgetPredicate((w) => w is SailButton && w.label == label);

    Future<String> pumpOneKeyPanel(WidgetTester tester, {String hardwareDeviceType = ''}) async {
      final draftId = await setUpPanelDeps(oneKey: true, hardwareDeviceType: hardwareDeviceType);
      if (hardwareDeviceType.isNotEmpty) {
        orchestrator.wallet.signedMark = '+signed';
      }
      GetIt.I.registerSingleton<ForkProvider>(ForkProvider());
      GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf());
      GetIt.I.registerSingleton<NotificationProvider>(_FakeNotifications());
      await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
      await tester.pumpAndSettle();
      return draftId;
    }

    testWidgets('shows no keys table, and locks the coins until the broadcast', (tester) async {
      await pumpOneKeyPanel(tester);

      expect(find.text('Key 1'), findsNothing);
      expect(find.textContaining('of 3 keys'), findsNothing);
      expect(find.textContaining('· locked'), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
      expect(find.byType(GroupedAddress), findsOneWidget);
      expect(tester.widget<SailButton>(button('Broadcast')).disabled, isFalse);
      expect(button('Copy PSBT'), findsOneWidget);
      expect(button('Discard'), findsOneWidget);
    });

    testWidgets('a broadcast puts the txid where the buttons were', (tester) async {
      final draftId = await pumpOneKeyPanel(tester);

      await tester.ensureVisible(button('Broadcast'));
      await tester.pumpAndSettle();
      await tester.tap(button('Broadcast'));
      await tester.pumpAndSettle();

      expect(draftProvider.drafts.single.txid, 'cc' * 32);
      expect(draftProvider.lockedOutpoints, isEmpty, reason: draftId);
      expect(find.text('cc' * 32), findsOneWidget);
      expect(button('View transaction'), findsOneWidget);
      expect(button('Broadcast'), findsNothing);
      expect(button('Discard'), findsNothing);
      expect(find.textContaining('· locked'), findsNothing);
    });

    testWidgets('Discard deletes the draft', (tester) async {
      await pumpOneKeyPanel(tester);

      await tester.ensureVisible(button('Discard'));
      await tester.pumpAndSettle();
      await tester.tap(button('Discard'));
      // The Discard button spins while its dialog is open, so the frames never settle.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(button('Delete transaction'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(draftProvider.drafts, isEmpty);
    });

    testWidgets('a hardware wallet signs its draft on the device, then broadcasts', (tester) async {
      await pumpOneKeyPanel(tester, hardwareDeviceType: 'trezor');

      expect(tester.widget<SailButton>(button('Broadcast')).disabled, isTrue);
      expect(button('Import a signature'), findsOneWidget);

      await tester.ensureVisible(button('Sign with trezor'));
      await tester.pumpAndSettle();
      await tester.tap(button('Sign with trezor'));
      await tester.pumpAndSettle();

      expect(draftProvider.drafts.single.psbtBase64, endsWith('+signed'));
      expect(tester.widget<SailButton>(button('Broadcast')).disabled, isFalse);
      expect(button('Sign with trezor'), findsNothing);
      expect(button('Import a signature'), findsNothing);
    });

    testWidgets('on a phone a broadcast shows green text, the link at the right and the txid below', (tester) async {
      SailStyleValues.phoneLayoutOverride = true;
      addTearDown(() => SailStyleValues.phoneLayoutOverride = null);
      await pumpOneKeyPanel(tester);

      await tester.ensureVisible(button('Broadcast'));
      await tester.pumpAndSettle();
      await tester.tap(button('Broadcast'));
      await tester.pumpAndSettle();

      expect(find.byType(FlowChip), findsNothing);
      final status = tester.getRect(find.text('Broadcast'));
      final link = tester.getRect(button('View transaction'));
      final txid = tester.getRect(find.text('cc' * 32));
      expect(link.left, greaterThanOrEqualTo(status.right));
      expect(link.center.dy, closeTo(status.center.dy, 2));
      expect(txid.top, greaterThan(link.bottom - 1));
    });
  });

  group('the phone layout', () {
    Finder button(String label) => find.byWidgetPredicate((w) => w is SailButton && w.label == label);

    setUp(() => SailStyleValues.phoneLayoutOverride = true);
    tearDown(() => SailStyleValues.phoneLayoutOverride = null);

    testWidgets('the keys table has 40 px rows and no ACTION column', (tester) async {
      final draftId = await setUpPanelDeps();

      await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
      await tester.pumpAndSettle();

      expect(find.text('ACTION'), findsNothing);
      expect(find.text('KEY'), findsOneWidget);
      expect(find.text('STATUS'), findsOneWidget);
      final first = tester.getCenter(find.text('Key 1')).dy;
      final second = tester.getCenter(find.text('Key 2')).dy;
      expect(second - first, closeTo(40, 1));
      expect(button('Sign'), findsOneWidget);
    });

    testWidgets('statuses and flow labels are plain colored text', (tester) async {
      final draftId = await setUpPanelDeps();

      await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
      await tester.pumpAndSettle();

      expect(find.byType(FlowChip), findsNothing);
      final theme = SailTheme.of(tester.element(find.text('Signed')));
      expect(tester.widget<Text>(find.text('Signed')).style?.color, theme.colors.success);
      expect(find.text('Awaiting signature'), findsNWidgets(2));
      expect(find.text('payment'), findsOneWidget);
      expect(find.text('1 of 2 collected'), findsOneWidget);
    });

    testWidgets('the actions stack under the keys card like a one-key send', (tester) async {
      final draftId = await setUpPanelDeps();

      await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
      await tester.pumpAndSettle();

      final keys = tester.getRect(find.text('Key 3'));
      final rects = [
        for (final l in ['Broadcast', 'Import a signature', 'Copy PSBT', 'Discard']) tester.getRect(button(l)),
      ];
      expect(rects.first.top, greaterThan(keys.bottom));
      for (var i = 1; i < rects.length; i++) {
        expect(rects[i].top, greaterThan(rects[i - 1].bottom - 1));
      }
      expect(rects[1].width, closeTo(rects[0].width, 1));
      expect(rects[3].width, closeTo(rects[0].width, 1));
      expect(rects[2].width, lessThan(rects[0].width));
    });
  });

  testWidgets('the desktop keys table keeps the ACTION column and the chips', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    addTearDown(() => SailStyleValues.phoneLayoutOverride = null);
    final draftId = await setUpPanelDeps();

    await tester.pumpSailPage(DraftPanel(walletId: 'wallet-1', draftId: draftId));
    await tester.pumpAndSettle();

    expect(find.text('ACTION'), findsOneWidget);
    expect(find.text('HELD BY'), findsOneWidget);
    expect(find.byType(FlowChip), findsWidgets);
  });
}
