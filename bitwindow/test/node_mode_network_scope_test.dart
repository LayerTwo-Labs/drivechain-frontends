import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

class _FakeWalletRPC implements OrchestratorWalletRPC {
  wmpb.NodeMode mode = wmpb.NodeMode.NODE_MODE_FULL;
  bool lightModeAvailable = true;
  bool throwOnRead = false;
  int reads = 0;

  @override
  Future<wmpb.GetNodeModeResponse> getNodeMode() async {
    reads++;
    if (throwOnRead) {
      throw Exception('orchestrator is restarting');
    }
    return wmpb.GetNodeModeResponse(mode: mode, lightModeAvailable: lightModeAvailable);
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

void main() {
  late _FakeOrchestrator orchestrator;
  late NodeModeProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    NetworkScopedRegistry.clearRegistrations();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    orchestrator = _FakeOrchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    GetIt.I.registerLazySingleton<NodeModeProvider>(() => NodeModeProvider());
    NetworkScopedRegistry.enrolLazy<NodeModeProvider>();
    provider = GetIt.I.get<NodeModeProvider>();
  });

  tearDown(() async {
    NetworkScopedRegistry.clearRegistrations();
    await GetIt.I.reset();
  });

  // Regtest and testnet serve no remote chain, so the backend narrows light
  // mode to full there. A provider that keeps the old answer hides the daemons
  // the server just started.
  test('a network change re-reads the node mode', () async {
    provider.mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    provider.lightModeAvailable = true;
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_FULL;
    orchestrator.wallet.lightModeAvailable = false;

    await NetworkScopedRegistry.clearAll();

    expect(orchestrator.wallet.reads, 1, reason: 'the swap must ask the server again');
    expect(provider.mode, wmpb.NodeMode.NODE_MODE_FULL);
    expect(provider.lightModeAvailable, isFalse);
  });

  // A network swap restarts the orchestrator, so this read is the one most
  // likely to fail. Clearing the mode here would drop a full node to the
  // light-mode UI and skip the L1 boot.
  test('a failed read keeps the mode the user picked', () async {
    provider.mode = wmpb.NodeMode.NODE_MODE_FULL;
    orchestrator.wallet.throwOnRead = true;

    await NetworkScopedRegistry.clearAll();

    expect(orchestrator.wallet.reads, 1);
    expect(provider.mode, wmpb.NodeMode.NODE_MODE_FULL);
    expect(NodeModeProvider.runsLocalBackends, isTrue);
  });
}
