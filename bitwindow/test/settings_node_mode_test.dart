import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/settings/settings_node_mode.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  _FakeConf(this.events);

  final List<String> events;
  bool directorySaved = false;
  bool directoryLoaded = false;

  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  bool hasPrivateBitcoinConf = false;

  bool get fullModeReady =>
      hasPrivateBitcoinConf ||
      (network != BitcoinNetwork.BITCOIN_NETWORK_MAINNET && network != BitcoinNetwork.BITCOIN_NETWORK_ECASH) ||
      directoryLoaded;

  @override
  bool get mustSelectDatadir => GetIt.I.get<NodeModeProvider>().isFull && !fullModeReady;

  @override
  bool hasDataDirFor(BitcoinNetwork network) => directoryLoaded;

  @override
  Future<void> loadConfig({bool isFirst = false, bool userInitiated = false}) async {
    events.add('load');
    directoryLoaded = directorySaved;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRouter implements StackRouter {
  _FakeRouter(this.conf);

  final _FakeConf conf;
  bool? result = true;
  bool saveDirectory = true;
  final List<PageRouteInfo> routes = [];

  @override
  Future<T?> push<T extends Object?>(PageRouteInfo route, {OnNavigationFailure? onFailure}) async {
    routes.add(route);
    conf.events.add('choose');
    if (result == true && saveDirectory) {
      conf.directorySaved = true;
    }
    return result as T?;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWallet implements OrchestratorWalletRPC {
  _FakeWallet(this.conf);

  final _FakeConf conf;
  final List<wmpb.NodeMode> selections = [];

  @override
  Future<void> setNodeMode(wmpb.NodeMode next) async {
    selections.add(next);
    conf.events.add('select');
    if (next == wmpb.NodeMode.NODE_MODE_FULL && !conf.fullModeReady) {
      throw StateError('Select a data directory before full mode');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this.wallet);

  @override
  final _FakeWallet wallet;
  final List<String> starts = [];

  @override
  Future<orch_pb.StartWithL1Response> startWithL1(
    String target, {
    List<String>? targetArgs,
    Map<String, String>? targetEnv,
    List<String>? coreArgs,
    List<String>? enforcerArgs,
    bool immediate = false,
    bool forceBackend = false,
  }) async {
    starts.add(target);
    wallet.conf.events.add('start');
    return orch_pb.StartWithL1Response();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> events;
  late _FakeConf conf;
  late _FakeRouter router;
  late _FakeOrchestrator orchestrator;
  late NodeModeProvider nodeMode;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    events = [];
    conf = _FakeConf(events);
    router = _FakeRouter(conf);
    orchestrator = _FakeOrchestrator(_FakeWallet(conf));
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    nodeMode = NodeModeProvider()..mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    GetIt.I.registerSingleton<NodeModeProvider>(nodeMode);
  });

  tearDown(() async => GetIt.I.reset());

  Future<void> selectFullMode(WidgetTester tester) async {
    await tester.pumpSailPage(
      StackRouterScope(controller: router, stateHash: 0, child: const SettingsNodeMode()),
    );
    await tester.tap(find.byType(SailToggle));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Switch'));
    await tester.pumpAndSettle();
  }

  for (final network in [BitcoinNetwork.BITCOIN_NETWORK_MAINNET, BitcoinNetwork.BITCOIN_NETWORK_ECASH]) {
    testWidgets('selects a data directory before full mode on ${network.name}', (tester) async {
      conf.network = network;

      await selectFullMode(tester);

      expect(router.routes, hasLength(1));
      expect(router.routes.single, isA<DataDirSetupRoute>());
      expect((router.routes.single.args as DataDirSetupRouteArgs).network, network);
      expect(events, ['load', 'choose', 'load', 'select', 'load', 'start']);
      expect(orchestrator.wallet.selections, [wmpb.NodeMode.NODE_MODE_FULL]);
      expect(nodeMode.isFull, isTrue);
      expect(orchestrator.starts, ['enforcer']);
    });
  }

  testWidgets('keeps light mode when the directory choice is cancelled', (tester) async {
    router.result = null;

    await selectFullMode(tester);

    expect(router.routes, hasLength(1));
    expect(events, ['load', 'choose', 'load']);
    expect(orchestrator.wallet.selections, isEmpty);
    expect(nodeMode.isLight, isTrue);
    expect(orchestrator.starts, isEmpty);
  });

  testWidgets('keeps light mode when the directory does not save', (tester) async {
    router.saveDirectory = false;

    await selectFullMode(tester);

    expect(router.routes, hasLength(1));
    expect(orchestrator.wallet.selections, isEmpty);
    expect(nodeMode.isLight, isTrue);
    expect(orchestrator.starts, isEmpty);
  });

  testWidgets('uses the saved data directory after the config reload', (tester) async {
    conf.directorySaved = true;

    await selectFullMode(tester);

    expect(router.routes, isEmpty);
    expect(orchestrator.wallet.selections, [wmpb.NodeMode.NODE_MODE_FULL]);
    expect(nodeMode.isFull, isTrue);
    expect(orchestrator.starts, ['enforcer']);
  });

  testWidgets('uses the private Bitcoin config without a directory choice', (tester) async {
    conf.hasPrivateBitcoinConf = true;

    await selectFullMode(tester);

    expect(router.routes, isEmpty);
    expect(nodeMode.isFull, isTrue);
    expect(orchestrator.starts, ['enforcer']);
  });

  testWidgets('uses the Signet default directory without a directory choice', (tester) async {
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

    await selectFullMode(tester);

    expect(router.routes, isEmpty);
    expect(nodeMode.isFull, isTrue);
    expect(orchestrator.starts, ['enforcer']);
  });
}
