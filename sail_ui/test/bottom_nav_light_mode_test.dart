import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as orchpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:stacked/stacked.dart';

class _Connection extends ChangeNotifier implements RPCConnection {
  _Connection(this.binary, {this.connected = true});

  @override
  Binary binary;

  @override
  bool connected;

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
  _Core() : super(BitcoinCore(), connected: false);
}

class _Enforcer extends _Connection implements EnforcerRPC {
  _Enforcer() : super(Enforcer());
}

class _Daemon extends _Connection {
  _Daemon() : super(Thunder());
}

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

class _Store implements KeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

class _Wallet implements WalletReaderProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Orchestrator implements OrchestratorRPC {
  _Orchestrator(this.response);

  final orchpb.GetSyncStatusResponse response;

  @override
  Future<orchpb.GetSyncStatusResponse> getSyncStatus() async => response;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Enforcer enforcer;
  late _Daemon daemon;
  late SyncProvider sync;
  late BottomNavViewModel model;

  setUp(() async {
    final log = Logger(level: Level.off);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: _Store(), log: log));
    GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: _Store(), log: log));
    GetIt.I.registerSingleton<SettingsProvider>(await SettingsProvider.create());
    GetIt.I.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: Directory.systemTemp, binaries: [BitcoinCore(), Enforcer(), Thunder()]),
    );
    GetIt.I.registerSingleton<LogProvider>(LogProvider());
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    GetIt.I.registerSingleton<EnforcerConfProvider>(_EnforcerConf());
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = wmpb.NodeMode.NODE_MODE_LIGHT);
    GetIt.I.registerSingleton<WalletReaderProvider>(_Wallet());
    GetIt.I.registerSingleton<BitcoindConnection>(_Core());
    enforcer = _Enforcer();
    GetIt.I.registerSingleton<EnforcerRPC>(enforcer);
    daemon = _Daemon();
    sync = SyncProvider(
      startTimer: false,
      additionalConnection: SyncConnection(rpc: daemon, name: 'Thunder'),
    )..sidechains = {};
    sync.enforcerSyncInfo = SyncInfo(progressCurrent: 42, progressGoal: 42, lastBlockAt: null);
    sync.sidechains[SidechainType.SIDECHAIN_TYPE_THUNDER] = SyncInfo(
      progressCurrent: 3,
      progressGoal: 3,
      lastBlockAt: null,
    );
    GetIt.I.registerSingleton<SyncProvider>(sync);
    model = BottomNavViewModel(
      additionalConnection: ConnectionMonitor(rpc: daemon, name: 'Thunder'),
      mainchainInfo: true,
      navigateToLogs: (_, _, _) {},
    );
  });

  tearDown(() async {
    model.dispose();
    sync.dispose();
    await GetIt.I.reset();
  });

  Future<void> showLoaders(WidgetTester tester, {bool synced = false}) async {
    GetIt.I.registerSingleton<OrchestratorRPC>(
      _Orchestrator(
        orchpb.GetSyncStatusResponse(
          mainchain: orchpb.ChainSync(error: 'connection refused'),
          enforcer: orchpb.ChainSync(blocks: synced ? 42 : 41, headers: 42),
          sidechains: [
            orchpb.SidechainStatus(
              type: SidechainType.SIDECHAIN_TYPE_THUNDER,
              sync: orchpb.ChainSync(blocks: synced ? 3 : 2, headers: 3),
            ),
          ],
        ),
      ),
    );
    await sync.fetch();
    expect(sync.mainchainError, 'connection refused');
    expect(sync.mainchainSyncInfo, isNotNull);
    expect(sync.mainchainSyncInfo!.progress, 0);
    expect(sync.mainchainSyncInfo!.isSynced, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: ViewModelBuilder<BottomNavViewModel>.nonReactive(
              viewModelBuilder: () => model,
              disposeViewModel: false,
              builder: (_, _, _) => const ChainLoaders(),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  }

  testWidgets('light mode hides the Core loader after sidechain sync', (tester) async {
    await showLoaders(tester, synced: true);

    expect(find.byType(ChainLoader), findsNothing);
    expect(find.text('3 blocks'), findsOneWidget);
  });

  for (final light in [true, false]) {
    testWidgets('${light ? 'light' : 'full'} mode shows only its active sync loaders', (tester) async {
      GetIt.I.get<NodeModeProvider>().mode = light ? wmpb.NodeMode.NODE_MODE_LIGHT : wmpb.NodeMode.NODE_MODE_FULL;
      await showLoaders(tester);

      expect(
        tester.widgetList<ChainLoader>(find.byType(ChainLoader)).map((loader) => loader.name),
        [if (!light) BitcoinCore().name, Enforcer().name, Thunder().name],
      );
    });
  }

  test('light mode connects without local Core', () {
    expect(model.needsBackends, isFalse);
    expect(model.needsEnforcer, isTrue);
    expect(model.needsAdditional, isTrue);
    expect(model.allConnected, isTrue);
    expect(model.connectionColor, SailColorScheme.green);
  });

  test('a stopped sidechain keeps light mode disconnected', () {
    daemon.connected = false;

    expect(model.allConnected, isFalse);
    expect(model.connectionColor, SailColorScheme.orange);
  });

  test('the remote enforcer connection controls the status', () {
    enforcer.connected = false;

    expect(model.allConnected, isFalse);
    enforcer.connectionError = 'The remote enforcer is unavailable.';
    expect(model.connectionColor, SailColorScheme.red);
  });

  test('light mode waits for the local sidechain sync', () {
    sync.sidechains[SidechainType.SIDECHAIN_TYPE_THUNDER] = SyncInfo(
      progressCurrent: 2,
      progressGoal: 3,
      lastBlockAt: null,
    );

    expect(model.allConnected, isTrue);
    expect(model.connectionColor, SailColorScheme.orange);
  });

  test('a sidechain in a mainchain phase names the phase in the status', () {
    expect(model.connectionStatus, 'All binaries connected');

    sync.sidechains[SidechainType.SIDECHAIN_TYPE_THUNDER] = SyncInfo(
      progressCurrent: 412000,
      progressGoal: 997070,
      lastBlockAt: null,
      mainchainSyncPhase: MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_WRITING,
    );
    expect(model.connectionStatus, 'Writing mainchain headers for Thunder');

    sync.sidechains[SidechainType.SIDECHAIN_TYPE_THUNDER] = SyncInfo(
      progressCurrent: 2,
      progressGoal: 3,
      lastBlockAt: null,
    );
    expect(model.connectionStatus, 'Syncing Thunder blocks');
  });

  test('the Bitcoin light wallet ignores an unavailable enforcer', () {
    daemon.binary = BitWindow();
    enforcer.connected = false;
    enforcer.connectionError = 'This network has no remote enforcer.';
    sync.enforcerSyncInfo = null;
    enforcer.initializingBinary = true;

    expect(model.needsBackends, isFalse);
    expect(model.needsEnforcer, isFalse);
    expect(model.initializingAny, isFalse);
    expect(model.connectionStatus, 'All binaries connected');
    expect(model.allConnected, isTrue);
    expect(model.connectionColor, SailColorScheme.green);
  });

  test('the Bitcoin light wallet uses a published remote enforcer', () {
    daemon.binary = BitWindow();
    GetIt.I.get<NodeModeProvider>().remoteEnforcerAvailable = true;
    enforcer.connected = false;

    expect(model.needsEnforcer, isTrue);
    expect(model.allConnected, isFalse);
    expect(model.connectionColor, SailColorScheme.orange);
  });

  for (final light in [true, false]) {
    testWidgets('${light ? 'light' : 'full'} mode shows the correct daemon controls and sync', (tester) async {
      GetIt.I.get<NodeModeProvider>().mode = light ? wmpb.NodeMode.NODE_MODE_LIGHT : wmpb.NodeMode.NODE_MODE_FULL;
      final nav = BottomNav(
        endWidgets: const [],
        additionalConnection: model.additionalConnection,
        mainchainInfo: true,
        navigateToLogs: (_, _, _) {},
      );
      tester.view.physicalSize = const Size(1600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.8)),
            child: child!,
          ),
          home: SailTheme(
            data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
            child: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => nav.displayConnectionStatusDialog(context, model.additionalConnection, false),
                  child: const Text('Status'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final cards = tester.widgetList<DaemonConnectionCard>(find.byType(DaemonConnectionCard));
      final validator = cards.singleWhere((card) => card.connection.binary is Enforcer);
      expect(validator.restartDaemon, light ? isNull : isNotNull);
      expect(validator.stopDaemon, light ? isNull : isNotNull);
      final sidechain = cards.singleWhere((card) => card.connection.binary is Thunder);
      expect(sidechain.syncInfo, light ? same(model.additionalSyncInfo) : isNull);
      expect(sidechain.infoMessage, light ? isNull : 'Waiting for Bitcoin Core header sync');
      expect(sidechain.restartDaemon, isNotNull);
      expect(sidechain.stopDaemon, isNotNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
