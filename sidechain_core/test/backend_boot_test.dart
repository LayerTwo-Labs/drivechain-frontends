import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

class _FakeWalletRPC implements OrchestratorWalletRPC {
  wmpb.NodeMode mode = wmpb.NodeMode.NODE_MODE_UNSPECIFIED;
  bool remoteEnforcerAvailable = true;

  @override
  Future<wmpb.GetNodeModeResponse> getNodeMode() async => wmpb.GetNodeModeResponse(
    mode: mode,
    lightModeAvailable: true,
    remoteEnforcerAvailable: remoteEnforcerAvailable,
  );

  @override
  Future<void> setNodeMode(wmpb.NodeMode next) async {
    mode = next;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final _FakeWalletRPC wallet = _FakeWalletRPC();
  final starts = <String>[];
  Object? startError;

  @override
  Future<StartWithL1Response> startWithL1(
    String target, {
    List<String>? targetArgs,
    Map<String, String>? targetEnv,
    List<String>? coreArgs,
    List<String>? enforcerArgs,
    bool immediate = false,
    bool forceBackend = false,
  }) async {
    if (startError != null) {
      throw startError!;
    }
    starts.add(target);
    return StartWithL1Response();
  }

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

  // A boot that never reaches the orchestrator must not read as connected, or
  // the Drivechain card claims health that nothing proved.
  test('the orchestrator reads as unanswered until a poll lands', () {
    final backend = BackendStateProvider(orchestrator);
    expect(backend.orchestratorAnswered, isFalse);
    expect(backend.orchestratorReachable, isTrue);
  });

  test('full mode starts the local backends', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_FULL;
    final boot = await readBackendBoot(orchestratorReady: true);
    expect(boot, BackendBoot.localBackends);
    expect(boot.startsLocalBackends, isTrue);
  });

  test('light mode starts the remote enforcer connection', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    final boot = await readBackendBoot(orchestratorReady: true);
    expect(boot, BackendBoot.remoteEnforcer);
    expect(boot.startsLocalBackends, isFalse);
    expect(boot.startsBackends, isTrue);
  });

  // An install that never asked must boot nothing, or it starts a stack the
  // user may not want before the mode gate appears.
  test('an unpicked mode starts nothing', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_UNSPECIFIED;
    final boot = await readBackendBoot(orchestratorReady: true);
    expect(boot, BackendBoot.awaitChoice);
    expect(boot.startsLocalBackends, isFalse);
    expect(boot.startsBackends, isFalse);
  });

  // A boot that cannot reach the orchestrator leaves the mode unset, so it
  // waits rather than guessing.
  test('an unreachable orchestrator starts nothing', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_FULL;
    final boot = await readBackendBoot(orchestratorReady: false);
    expect(boot, BackendBoot.awaitChoice);
  });
  test('a switch to light mode starts the enforcer connection', () async {
    final mode = GetIt.I.get<NodeModeProvider>()
      ..mode = wmpb.NodeMode.NODE_MODE_FULL
      ..remoteEnforcerAvailable = true;

    await mode.select(wmpb.NodeMode.NODE_MODE_LIGHT);

    expect(orchestrator.wallet.mode, wmpb.NodeMode.NODE_MODE_LIGHT);
    expect(orchestrator.starts, ['enforcer']);
    expect(NodeModeProvider.runsLocalBackends, isFalse);
  });

  test('a failed enforcer start returns its error', () async {
    orchestrator.startError = StateError('The remote enforcer is unavailable.');
    final mode = GetIt.I.get<NodeModeProvider>()
      ..mode = wmpb.NodeMode.NODE_MODE_FULL
      ..remoteEnforcerAvailable = true;

    await expectLater(
      mode.select(wmpb.NodeMode.NODE_MODE_LIGHT),
      throwsStateError,
    );
  });
  test('a second choice retries a failed enforcer start', () async {
    orchestrator.startError = StateError('The remote enforcer is unavailable.');
    final mode = GetIt.I.get<NodeModeProvider>()
      ..mode = wmpb.NodeMode.NODE_MODE_FULL
      ..remoteEnforcerAvailable = true;
    await expectLater(mode.select(wmpb.NodeMode.NODE_MODE_LIGHT), throwsStateError);

    orchestrator.startError = null;
    await mode.select(wmpb.NodeMode.NODE_MODE_LIGHT);

    expect(orchestrator.starts, ['enforcer']);
  });
  test('Bitcoin light mode starts no enforcer without an endpoint', () async {
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    orchestrator.wallet.remoteEnforcerAvailable = false;

    final boot = await readBackendBoot(orchestratorReady: true);
    await GetIt.I.get<NodeModeProvider>().select(wmpb.NodeMode.NODE_MODE_LIGHT);

    expect(boot.startsBackends, isFalse);
    expect(boot.startsLocalBackends, isFalse);
    expect(orchestrator.starts, isEmpty);
  });

  test('a sidechain app keeps the enforcer gate without an endpoint', () async {
    Binary.isSidechainApp = true;
    addTearDown(() => Binary.isSidechainApp = false);
    orchestrator.wallet.mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    orchestrator.wallet.remoteEnforcerAvailable = false;
    orchestrator.startError = StateError('The remote enforcer is unavailable.');

    final boot = await readBackendBoot(orchestratorReady: true);

    expect(boot.startsBackends, isTrue);
    await expectLater(
      GetIt.I.get<NodeModeProvider>().select(wmpb.NodeMode.NODE_MODE_LIGHT),
      throwsStateError,
    );
  });
}
