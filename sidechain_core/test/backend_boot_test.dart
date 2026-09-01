import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

class _FakeWalletRPC implements OrchestratorWalletRPC {
  wmpb.NodeMode mode = wmpb.NodeMode.NODE_MODE_UNSPECIFIED;

  @override
  Future<wmpb.GetNodeModeResponse> getNodeMode() async =>
      wmpb.GetNodeModeResponse(mode: mode, lightModeAvailable: true);

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

  setUp(() async {
    await GetIt.I.reset();
    NetworkScopedRegistry.clearRegistrations();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    orchestrator = _FakeOrchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    registerNodeMode();
  });

  tearDown(() async {
    NetworkScopedRegistry.clearRegistrations();
    await GetIt.I.reset();
  });

  test('registerNodeMode is safe to call twice', () {
    final first = GetIt.I.get<NodeModeProvider>();
    registerNodeMode();
    expect(GetIt.I.get<NodeModeProvider>(), same(first));
  });

  // Registration alone is not sufficient. An app that registers the provider
  // and never reads it behaves as light mode for the whole session, whatever
  // the user picked.
  test('a registered but unread provider runs no local backends', () {
    expect(NodeModeProvider.runsLocalBackends, isFalse);
  });

  test('a full-mode read turns the local backends on', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_FULL;
    await readBackendBoot(orchestratorReady: true);
    expect(NodeModeProvider.runsLocalBackends, isTrue);
  });

  // bitwindow asks before it boots, so an unpicked mode runs no backends. A
  // sidechain app shows no gate, and the orchestrator boots the stack for an
  // unset mode, so the frontend must agree rather than read as light.
  test('an unpicked mode keeps a sidechain app on its backends', () {
    Binary.isSidechainApp = true;
    addTearDown(() => Binary.isSidechainApp = false);

    expect(NodeModeProvider.runsLocalBackends, isTrue);
  });

  test('an unpicked mode boots nothing in bitwindow', () {
    expect(Binary.isSidechainApp, isFalse);
    expect(NodeModeProvider.runsLocalBackends, isFalse);
  });

  test('full mode starts the local backends', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_FULL;
    final boot = await readBackendBoot(orchestratorReady: true);
    expect(boot, BackendBoot.localBackends);
    expect(boot.startsLocalBackends, isTrue);
  });

  test('light mode reads a remote chain and starts nothing', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    final boot = await readBackendBoot(orchestratorReady: true);
    expect(boot, BackendBoot.remoteChain);
    expect(boot.startsLocalBackends, isFalse);
  });

  // An install that never asked must boot nothing, or it starts a stack the
  // user may not want before the mode gate appears.
  test('an unpicked mode starts nothing', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_UNSPECIFIED;
    final boot = await readBackendBoot(orchestratorReady: true);
    expect(boot, BackendBoot.awaitChoice);
    expect(boot.startsLocalBackends, isFalse);
  });

  // A boot that cannot reach the orchestrator leaves the mode unset, so it
  // waits rather than guessing.
  test('an unreachable orchestrator starts nothing', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_FULL;
    final boot = await readBackendBoot(orchestratorReady: false);
    expect(boot, BackendBoot.awaitChoice);
  });
}
