import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/root_page.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/peers_provider.dart';
import 'package:bitwindow/providers/ecash_migration_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/providers/price_provider.dart';

import 'mocks/store_mock.dart';
import 'test_utils.dart';

class _Connection extends ChangeNotifier implements RPCConnection {
  _Connection(this.binary);

  @override
  Binary binary;

  @override
  bool connected = true;

  @override
  bool initializingBinary = false;

  @override
  bool stoppingBinary = false;

  @override
  String? connectionError;

  @override
  String? startupError;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Core extends _Connection implements BitcoindConnection {
  _Core() : super(BitcoinCore());
}

class _Enforcer extends _Connection implements EnforcerRPC {
  _Enforcer() : super(Enforcer());
}

class _Bitwindow extends _Connection implements BitwindowRPC {
  _Bitwindow() : super(BitWindow());
}

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  String ecashNetworkId = '';

  @override
  bool get networkSupportsSidechains => true;

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

class _Wallet extends ChangeNotifier implements WalletReaderProvider {
  @override
  bool get hasNoWallet => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Balance extends ChangeNotifier implements BalanceProvider {
  @override
  final newestTransactions = ValueNotifier<List<wmpb.TransactionEntry>?>(null);

  @override
  double balance = 1.5;

  @override
  double pendingBalance = 0;

  @override
  double maturingBalance = 0;

  @override
  double sidechainBalance = 0;

  @override
  double sidechainPendingBalance = 0;

  @override
  bool get initialized => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Price extends ChangeNotifier implements PriceProvider {
  @override
  double toUsd(double amount) => amount * 100000;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Update extends ChangeNotifier implements UpdateProvider {
  @override
  bool get updateAvailable => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions extends ChangeNotifier implements TransactionProvider {
  @override
  String address = '';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Peers extends ChangeNotifier implements PeersProvider {
  @override
  List<Peer> peers = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Blockchain extends ChangeNotifier implements BlockchainProvider {
  @override
  SyncProvider get syncProvider => GetIt.I.get<SyncProvider>();

  @override
  BitcoindConnection get mainchain => GetIt.I.get<BitcoindConnection>();

  @override
  List<Block> blocks = [];

  @override
  int peerCount = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _tabs = ['Overview', 'Wallet', 'Sidechains', 'Mining', 'Learn', 'Console', 'Chat'];

void main() {
  late SyncProvider sync;

  setUpAll(() async {
    await loadBundledFonts();
  });

  setUp(() async {
    final log = Logger(level: Level.off);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: MockStore(), log: log));
    GetIt.I.registerSingleton<SettingsProvider>(await SettingsProvider.create());
    GetIt.I.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: Directory.systemTemp, binaries: [BitcoinCore(), Enforcer(), BitWindow()]),
    );
    GetIt.I.registerSingleton<LogProvider>(LogProvider());
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    GetIt.I.registerSingleton<EnforcerConfProvider>(_EnforcerConf());
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = wmpb.NodeMode.NODE_MODE_FULL);
    GetIt.I.registerSingleton<WalletReaderProvider>(_Wallet());
    GetIt.I.registerSingleton<BitcoindConnection>(_Core());
    GetIt.I.registerSingleton<EnforcerRPC>(_Enforcer());
    final bitwindow = _Bitwindow();
    GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);
    GetIt.I.registerSingleton<BalanceProvider>(_Balance());
    GetIt.I.registerSingleton<PriceProvider>(_Price());
    GetIt.I.registerSingleton<UpdateProvider>(_Update());
    GetIt.I.registerSingleton<TransactionProvider>(_Transactions());
    GetIt.I.registerSingleton<NotificationProvider>(NotificationProvider());
    GetIt.I.registerSingleton<ECashMigrationProvider>(ECashMigrationProvider());
    sync = SyncProvider(
      startTimer: false,
      additionalConnection: SyncConnection(rpc: bitwindow, name: 'BitWindow'),
    );
    sync.mainchainSyncInfo = SyncInfo(progressCurrent: 412000, progressGoal: 997070, lastBlockAt: null);
    sync.enforcerSyncInfo = SyncInfo(progressCurrent: 41000, progressGoal: 997070, lastBlockAt: null);
    sync.bitwindowdSyncInfo = SyncInfo(progressCurrent: 41000, progressGoal: 997070, lastBlockAt: null);
    GetIt.I.registerSingleton<SyncProvider>(sync);
    GetIt.I.registerSingleton<BlockchainProvider>(_Blockchain());
    GetIt.I.registerSingleton<PeersProvider>(_Peers());
  });

  tearDown(() async {
    sync.dispose();
    await GetIt.I.reset();
  });

  Finder sailTooltip(String message) => find.byWidgetPredicate((w) => w is SailTooltip && w.message == message);

  Future<void> pumpBars(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final wallet = WalletMetadata(
      id: 'w1',
      name: 'wallet1',
      gradient: WalletGradient.fromWalletId('w1'),
      createdAt: DateTime(2026),
      lastUsed: DateTime(2026),
    );
    final router = RootStackRouter.build(
      routes: [
        NamedRouteDef(
          name: 'HomeRoute',
          initial: true,
          builder: (context, data) => AutoTabsRouter(
            routes: [
              for (final tab in [..._tabs, 'Settings']) NamedRoute('${tab}Route'),
            ],
            builder: (context, child) => Scaffold(
              appBar: TopNav(
                leadingWidget: WalletDropdown(
                  currentWallet: wallet,
                  availableWallets: [wallet],
                  onWalletSelected: (_) {},
                  onCreateWallet: () {},
                ),
                routes: [
                  for (final tab in _tabs) TopNavRoute(label: tab),
                  TopNavRoute(icon: SailSVGAsset.settings),
                ],
                endWidget: SailRow(
                  children: [
                    SailDropdownButton<String>(
                      value: 'signet',
                      items: [SailDropdownItem<String>(value: 'signet', label: 'L2L Signet')],
                      onChanged: (_) {},
                    ),
                    SailButton(
                      onPressed: () async {},
                      variant: ButtonVariant.icon,
                      icon: SailSVGAsset.telegram,
                      small: true,
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(child: child),
                  const StatusBar(),
                ],
              ),
            ),
          ),
          children: [
            for (final tab in [..._tabs, 'Settings'])
              NamedRouteDef(name: '${tab}Route', builder: (_, _) => const SizedBox()),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: MaterialApp.router(routerConfig: router.config()),
      ),
    );
    await tester.pump();
  }

  testWidgets('the top nav and the status bar fit a 1024 px window with a wallet that syncs', (tester) async {
    await pumpBars(tester, 1024);

    expect(tester.takeException(), isNull);
    expect(find.byType(ChainLoader), findsNWidgets(3));
    expect(find.text('Last block: Unknown'), findsNothing);
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('Reset'), findsNothing);
    expect(sailTooltip('Reset / Troubleshoot'), findsOneWidget);
    expect(sailTooltip('Last block: Unknown'), findsOneWidget);
    expect(find.byType(NotificationBell), findsOneWidget);
    expect(tester.getTopRight(find.byType(NotificationBell)).dx, lessThanOrEqualTo(1024));
    expect(tester.getTopRight(find.byType(ResetButton)).dx, lessThanOrEqualTo(1024));
    expect(find.byTooltip('Syncing mainchain blocks'), findsOneWidget);
  });

  testWidgets('a 1280 px window shows the full last block label', (tester) async {
    await pumpBars(tester, 1280);

    expect(tester.takeException(), isNull);
    expect(find.text('Last block: Unknown'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('the block age ticks and the status bar does not rebuild', (tester) async {
    sync.mainchainSyncInfo = SyncInfo(
      progressCurrent: 412000,
      progressGoal: 997070,
      lastBlockAt: Timestamp.fromDateTime(DateTime.now().subtract(const Duration(seconds: 5))),
    );
    await pumpBars(tester, 1280);
    expect(find.text('Last block: 5 seconds ago'), findsOneWidget);
    final bar = tester.widget<BottomNav>(find.byType(BottomNav));

    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1100)));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Last block: 6 seconds ago'), findsOneWidget);
    expect(tester.widget<BottomNav>(find.byType(BottomNav)), same(bar));
  });

  testWidgets('a Core disconnect greys the block age', (tester) async {
    await pumpBars(tester, 1280);
    bool skeleton() => tester
        .widget<SailSkeletonizer>(find.ancestor(of: find.byType(LastBlockAge), matching: find.byType(SailSkeletonizer)))
        .enabled;
    expect(skeleton(), isFalse);

    final core = GetIt.I.get<BitcoindConnection>() as _Core;
    core.connected = false;
    core.notifyListeners();
    await tester.pump();

    expect(skeleton(), isTrue);
  });
}
