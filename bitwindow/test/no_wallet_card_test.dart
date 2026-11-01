import 'dart:io';

import 'package:bitwindow/widgets/import_descriptor_dialog.dart';
import 'package:bitwindow/widgets/no_wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _FakeWriter extends WalletWriterProvider {
  _FakeWriter() : super(bitwindowAppDir: Directory.systemTemp);

  final List<String> calls = [];
  String? descriptor;
  int? m;
  int? n;

  @override
  Future<void> createElectrumWallet({
    required String name,
    required WalletGradient gradient,
    String? customMnemonic,
    String? passphrase,
    String? xpubOrDescriptor,
    String? scriptType,
    int account = 0,
    String? derivationPath,
    String? hardwareDeviceType,
    String? hardwareFingerprint,
  }) async {
    calls.add('electrum');
    descriptor = xpubOrDescriptor;
  }

  @override
  Future<void> createMultisigWallet({
    required String name,
    required WalletGradient gradient,
    required int m,
    required int n,
    required String scriptType,
    required List<wmpb.MultisigCosignerInput> cosigners,
  }) async {
    calls.add('multisig');
    this.m = m;
    this.n = n;
  }
}

class _FakeWalletRPC implements OrchestratorWalletRPC {
  wmpb.ValidateDescriptorResponse policy = wmpb.ValidateDescriptorResponse();
  Object? failure;

  @override
  Future<wmpb.ValidateDescriptorResponse> validateDescriptor(String descriptor) async {
    if (failure case final e?) {
      throw e;
    }
    return policy;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this.wallet);

  @override
  final _FakeWalletRPC wallet;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

wmpb.WatchWalletDataResponse _frame({required bool hasWallet}) => wmpb.WatchWalletDataResponse(
  state: hasWallet ? wmpb.WalletState.WALLET_STATE_UNLOCKED : wmpb.WalletState.WALLET_STATE_NO_WALLET,
  activeWalletId: hasWallet ? 'w1' : '',
  wallets: hasWallet ? [wmpb.WalletMetadata(id: 'w1', name: 'Main')] : const [],
);

Widget _host(Widget child) => SailTheme(
  data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
  child: MaterialApp(home: Scaffold(body: child)),
);

void main() {
  late WalletReaderProvider reader;
  late _FakeWriter writer;
  late _FakeWalletRPC rpc;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    reader = WalletReaderProvider(Directory.systemTemp);
    GetIt.I.registerSingleton<WalletReaderProvider>(reader);
    writer = _FakeWriter();
    GetIt.I.registerSingleton<WalletWriterProvider>(writer);
    rpc = _FakeWalletRPC();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(rpc));
  });

  tearDown(() async => GetIt.I.reset());

  Future<void> pumpLarge(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_host(child));
    await tester.pump();
  }

  testWidgets('the card shows until a wallet exists', (tester) async {
    reader.applyWatchFrame(_frame(hasWallet: false));
    await pumpLarge(tester, const NoWalletGate(child: Text('Send form')));

    expect(find.text('You need a wallet to send and receive'), findsOneWidget);
    expect(find.text('Generate wallet'), findsOneWidget);
    expect(find.text('Import descriptor'), findsOneWidget);
    expect(find.text('Paste seed phrase'), findsNothing);
    expect(find.text('Send form'), findsNothing);

    reader.applyWatchFrame(_frame(hasWallet: true));
    await tester.pump();

    expect(find.text('You need a wallet to send and receive'), findsNothing);
    expect(find.text('Send form'), findsOneWidget);
  });

  testWidgets('an unread wallet state shows the tab, not the card', (tester) async {
    await pumpLarge(tester, const NoWalletGate(child: Text('Send form')));

    expect(find.text('Send form'), findsOneWidget);
  });

  Future<void> importDescriptor(WidgetTester tester, String descriptor) async {
    await pumpLarge(tester, const ImportDescriptorDialog());
    await tester.enterText(find.byType(TextField), descriptor);
    await tester.pump();
    await tester.tap(find.widgetWithText(SailButton, 'Import').first);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('a single-sig descriptor makes an electrum wallet', (tester) async {
    rpc.policy = wmpb.ValidateDescriptorResponse(scriptType: 'wpkh', m: 1, n: 1);
    const descriptor = "wpkh([d34db33f/84'/0'/0']xpub6CUGRUo/0/*)";

    await importDescriptor(tester, descriptor);

    expect(writer.calls, ['electrum']);
    expect(writer.descriptor, descriptor);
  });

  testWidgets('a multisig descriptor makes a multisig wallet', (tester) async {
    rpc.policy = wmpb.ValidateDescriptorResponse(
      multisig: true,
      scriptType: 'wsh',
      m: 2,
      n: 3,
      keys: [
        for (final x in ['xpubA', 'xpubB', 'xpubC']) wmpb.ParsedCosigner(xpub: x),
      ],
    );

    await importDescriptor(tester, 'wsh(sortedmulti(2,xpubA,xpubB,xpubC))');

    expect(writer.calls, ['multisig']);
    expect((writer.m, writer.n), (2, 3));
  });

  testWidgets('a rejected descriptor shows the error and creates nothing', (tester) async {
    rpc.failure = Exception('descriptor has no keys');

    await importDescriptor(tester, 'wpkh()');

    expect(writer.calls, isEmpty);
    expect(find.textContaining('descriptor has no keys'), findsOneWidget);
  });
}
