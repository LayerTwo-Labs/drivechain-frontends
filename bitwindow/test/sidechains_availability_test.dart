import 'dart:io';

import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:stacked/stacked.dart';

import 'test_utils.dart';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  String? get detectedDataDir => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EnforcerConf extends ChangeNotifier implements EnforcerConfProvider {
  @override
  EnforcerConfig? currentConfig;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sidechains extends ChangeNotifier implements SidechainProvider {
  @override
  List<SidechainOverview?> sidechains = List.filled(256, null);

  @override
  String? error;

  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Wallet extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? get activeWalletId => null;

  @override
  String? resolveFundingWalletId(String? walletId) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NodeMode extends NodeModeProvider {
  void setMode(wmpb.NodeMode next) {
    mode = next;
    notifyListeners();
  }
}

void main() {
  late _NodeMode nodeMode;
  late _Conf conf;
  late SyncProvider sync;
  late SidechainsViewModel model;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    nodeMode = _NodeMode()..mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    conf = _Conf();
    sync = SyncProvider(startTimer: false);
    GetIt.I.registerSingleton<NodeModeProvider>(nodeMode);
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
    GetIt.I.registerSingleton<EnforcerConfProvider>(_EnforcerConf());
    GetIt.I.registerSingleton<SyncProvider>(sync);
    GetIt.I.registerSingleton<SidechainProvider>(_Sidechains());
    GetIt.I.registerSingleton<WalletReaderProvider>(_Wallet());
    GetIt.I.registerSingleton<TransactionProvider>(_Transactions());
    GetIt.I.registerSingleton<LogProvider>(LogProvider());
    GetIt.I.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: Directory.systemTemp, binaries: [BitcoinCore(), Enforcer()]),
    );
  });

  tearDown(() async {
    sync.dispose();
    await GetIt.I.reset();
  });

  Future<void> pumpOverview(WidgetTester tester) async {
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(
      ViewModelBuilder<SidechainsViewModel>.reactive(
        viewModelBuilder: () => model = SidechainsViewModel(),
        builder: (context, model, child) => const SidechainsTab(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Signet light mode shows no sidechain connection controls without an endpoint', (tester) async {
    await pumpOverview(tester);

    expect(model.networkSupportsSidechains, isTrue);
    expect(model.l1Gate, L1Gate.unavailable);
    expect(find.text('Sidechains are unavailable in light mode'), findsOneWidget);
    expect(find.text('Your Bitcoin wallet still uses Electrum.'), findsOneWidget);
    expect(find.byType(DaemonConnectionCard), findsNothing);
    expect(find.byType(SailButton), findsNothing);
    expect(find.byType(SidechainsList), findsNothing);
    expect(find.byType(DepositWithdrawView), findsNothing);
    expect(nodeMode.isLight, isTrue);
  });

  testWidgets('alphanet light mode shows the remote enforcer state with no start control', (tester) async {
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;
    nodeMode.remoteEnforcerAvailable = true;

    await pumpOverview(tester);

    expect(model.l1Gate, L1Gate.stopped);
    expect(find.text('The enforcer connection is not ready'), findsOneWidget);
    expect(find.byType(DaemonConnectionCard), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SailButton &&
            ((widget.label?.startsWith('Start') ?? false) || (widget.label?.startsWith('Connect') ?? false)),
      ),
      findsNothing,
    );
  });

  testWidgets('Signet full mode keeps the local daemon controls without a remote endpoint', (tester) async {
    nodeMode.mode = wmpb.NodeMode.NODE_MODE_FULL;

    await pumpOverview(tester);

    expect(model.l1Gate, L1Gate.stopped);
    expect(find.byType(DaemonConnectionCard), findsNWidgets(2));
    expect(
      find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Start Bitcoin Core + Enforcer'),
      findsOneWidget,
    );
  });

  testWidgets('a change to light mode removes the controls without an endpoint', (tester) async {
    nodeMode.mode = wmpb.NodeMode.NODE_MODE_FULL;
    await pumpOverview(tester);
    expect(find.byType(DaemonConnectionCard), findsNWidgets(2));

    nodeMode.setMode(wmpb.NodeMode.NODE_MODE_LIGHT);
    await tester.pumpAndSettle();

    expect(find.text('Sidechains are unavailable in light mode'), findsOneWidget);
    expect(find.byType(DaemonConnectionCard), findsNothing);
    expect(find.byType(SailButton), findsNothing);
  });
}
