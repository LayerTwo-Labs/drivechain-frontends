import 'package:bitwindow/routing/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _FakeWalletRPC implements OrchestratorWalletRPC {
  _FakeWalletRPC({required this.mode, this.lightModeAvailable = true});

  wmpb.NodeMode mode;
  bool lightModeAvailable;
  final List<wmpb.NodeMode> recorded = [];

  @override
  Future<wmpb.GetNodeModeResponse> getNodeMode() async =>
      wmpb.GetNodeModeResponse(mode: mode, lightModeAvailable: lightModeAvailable);

  @override
  Future<void> setNodeMode(wmpb.NodeMode next) async {
    recorded.add(next);
    mode = next;
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

void main() {
  late NodeModeProvider nodeMode;

  _FakeWalletRPC register(_FakeWalletRPC wallet) {
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(wallet));
    return wallet;
  }

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    nodeMode = NodeModeProvider()..localBuildsAvailable = true;
    GetIt.I.registerSingleton<NodeModeProvider>(nodeMode);
  });

  tearDown(() async => GetIt.I.reset());

  test('the root route asks only for the wallet password', () {
    final root = AppRouter().routes.firstWhere((r) => r.path == '/');

    expect(root.guards.map((g) => g.runtimeType), [PasswordGuard]);
  });

  test('a cold boot records light mode and boots no local node', () async {
    final wallet = register(_FakeWalletRPC(mode: wmpb.NodeMode.NODE_MODE_UNSPECIFIED));

    final boot = await readBackendBoot(orchestratorReady: true, hasWallet: () async => false);

    expect(wallet.recorded, [wmpb.NodeMode.NODE_MODE_LIGHT]);
    expect(nodeMode.isLight, isTrue);
    expect(boot.startsLocalBackends, isFalse);
    expect(NodeModeProvider.runsLocalBackends, isFalse);
  });

  test('an existing full mode install stays full', () async {
    final wallet = register(_FakeWalletRPC(mode: wmpb.NodeMode.NODE_MODE_FULL));

    final boot = await readBackendBoot(orchestratorReady: true, hasWallet: () async => true);

    expect(wallet.recorded, isEmpty);
    expect(boot, BackendBoot.localBackends);
  });

  test('a wallet with no recorded mode predates the modes, so it stays full', () async {
    final wallet = register(_FakeWalletRPC(mode: wmpb.NodeMode.NODE_MODE_UNSPECIFIED));

    final boot = await readBackendBoot(orchestratorReady: true, hasWallet: () async => true);

    expect(wallet.recorded, [wmpb.NodeMode.NODE_MODE_FULL]);
    expect(boot, BackendBoot.localBackends);
  });

  test('a network with no light mode boots full', () async {
    final wallet = register(
      _FakeWalletRPC(mode: wmpb.NodeMode.NODE_MODE_UNSPECIFIED, lightModeAvailable: false),
    );

    await readBackendBoot(orchestratorReady: true, hasWallet: () async => false);

    expect(wallet.recorded, [wmpb.NodeMode.NODE_MODE_FULL]);
  });

  test('a sidechain app boot records nothing', () async {
    final wallet = register(_FakeWalletRPC(mode: wmpb.NodeMode.NODE_MODE_UNSPECIFIED));

    final boot = await readBackendBoot(orchestratorReady: true);

    expect(wallet.recorded, isEmpty);
    expect(boot, BackendBoot.awaitChoice);
  });
}
