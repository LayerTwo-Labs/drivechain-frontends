import 'dart:io';

import 'package:bitnames/bitnames_module.dart';
import 'package:bitwindow/pages/sidechain_host_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/sidechains/hosted_chains.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:thunder/thunder_module.dart';
import 'package:truthcoin/truthcoin_module.dart';

import 'test_utils.dart';

class _Thunder extends MockThunderRPC {
  @override
  Future<(double, double)> balance() async => (1.25, 0.0);
}

class _Slots extends ChangeNotifier implements SidechainProvider {
  @override
  List<SidechainOverview?> sidechains = List.filled(256, null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sync extends MockSyncProvider {
  final Map<BinaryType, SyncInfo> chains = {};

  @override
  SyncInfo? sidechainSyncInfo(Binary chain) => chains[chain.type];

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

class _Binaries extends ChangeNotifier implements BinaryProvider {
  final Set<BinaryType> up = {};

  @override
  List<Binary> binaries = [];

  @override
  bool isConnected(Binary binary) => up.contains(binary.type);

  @override
  bool isInitializing(Binary binary) => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void _replace<T extends Object>(T instance) {
  if (GetIt.I.isRegistered<T>()) {
    GetIt.I.unregister<T>();
  }
  GetIt.I.registerSingleton<T>(instance);
}

void main() {
  late Directory appDir;
  late HostedChains hosted;
  late _Binaries binaries;
  late _Sync sync;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GetIt.I.reset();
    appDir = await Directory.systemTemp.createTemp('sidebar-state');
    await registerTestDependencies();
    _replace<ThunderRPC>(_Thunder());
    _replace<TruthcoinRPC>(MockTruthcoinRPC());
    _replace<BitnamesRPC>(MockBitnamesRPC());
    final slots = _Slots();
    for (final module in [ThunderModule(), TruthcoinModule(), BitnamesModule()]) {
      slots.sidechains[module.chain.slot] = SidechainOverview(ListSidechainsResponse_Sidechain(), [], []);
    }
    _replace<SidechainProvider>(slots);
    sync = _Sync();
    _replace<SyncProvider>(sync);
    binaries = _Binaries();
    _replace<BinaryProvider>(binaries);
    hosted = HostedChains(
      binaries: binaries,
      modules: [ThunderModule(), TruthcoinModule(), BitnamesModule()],
      applicationDir: appDir,
      log: GetIt.I.get<Logger>(),
      navigatorFor: (module) => HostChainNavigator(module.chain),
    );
    _replace<HostedChains>(hosted);
  });

  tearDown(() async {
    await hosted.closeAll();
    await GetIt.I.reset();
    await appDir.delete(recursive: true);
  });

  test('the sidebar reads the balance of a running chain from its session, with no view open', () async {
    binaries.up
      ..add(BinaryType.BINARY_TYPE_THUNDER)
      ..add(BinaryType.BINARY_TYPE_TRUTHCOIN);
    sync.chains[BinaryType.BINARY_TYPE_TRUTHCOIN] = SyncInfo(progressCurrent: 45, progressGoal: 100, lastBlockAt: null);
    binaries.notifyListeners();
    await hosted.settled();
    (GetIt.I.get<ThunderRPC>() as _Thunder).setConnected(true);
    await hosted.session(ThunderModule())!.balance.fetch();
    await pumpEventQueue();

    final model = SidechainSidebarViewModel();
    final entries = {for (final entry in model.entries()) entry.module.appName: entry};

    expect(entries['Thunder']!.running, isTrue);
    expect(entries['Thunder']!.trailing, contains('1.25'));
    expect(entries['Truthcoin']!.trailing, 'Syncing 45%');
    expect(entries['BitNames']!.running, isFalse);
    expect(entries['BitNames']!.trailing, isNot(contains('BTC')));
    expect(model.total, contains('1.25'));
    model.dispose();
  });
}
