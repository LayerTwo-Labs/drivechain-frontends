import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

import 'mocks/api_mock.dart';

class _DrivechainAPI extends MockDrivechainAPI {
  int listCalls = 0;

  @override
  Future<List<ListSidechainsResponse_Sidechain>> listSidechains() async {
    listCalls++;
    return [ListSidechainsResponse_Sidechain(slot: 9, title: 'Thunder')];
  }
}

class _RPC extends MockAPI {
  _RPC() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _DrivechainAPI fakeDrivechain = _DrivechainAPI();

  @override
  _DrivechainAPI get drivechain => fakeDrivechain;
}

class _ReadyConf implements BitcoinConfProvider {
  @override
  bool get drivechainFeaturesAvailable => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ActiveWallet implements WalletReaderProvider {
  @override
  String? get activeWalletId => 'W1';

  @override
  void addListener(void Function() listener) {}

  @override
  void removeListener(void Function() listener) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sync extends SyncProvider {
  _Sync() : super(startTimer: false);

  void poll() => notifyListeners();
}

SyncInfo _at(double height) => SyncInfo(progressCurrent: height, progressGoal: height, lastBlockAt: null);

void main() {
  late _RPC rpc;
  late _Sync sync;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    rpc = _RPC()..connected = true;
    sync = _Sync()
      ..mainchainSyncInfo = _at(100)
      ..enforcerSyncInfo = _at(100);
    GetIt.I.registerSingleton<BitwindowRPC>(rpc);
    GetIt.I.registerSingleton<SyncProvider>(sync);
    GetIt.I.registerSingleton<BitcoinConfProvider>(_ReadyConf());
    GetIt.I.registerSingleton<WalletReaderProvider>(_ActiveWallet());
  });

  tearDown(() => GetIt.I.reset());

  test('a sync poll at the same tip does not refetch', () async {
    SidechainProvider();
    await pumpEventQueue();

    sync.poll();
    await pumpEventQueue();
    sync.poll();
    await pumpEventQueue();

    expect(rpc.drivechain.listCalls, 2);
  });

  test('a fetch with the same sidechains does not notify', () async {
    final provider = SidechainProvider();
    await pumpEventQueue();
    var notified = 0;
    provider.addListener(() => notified++);

    await provider.fetch();

    expect(notified, 0);
  });

  test('a fetch during a fetch runs one more time after it', () async {
    final provider = SidechainProvider();
    await pumpEventQueue();

    await Future.wait([provider.fetch(), provider.fetch(), provider.fetch()]);

    expect(rpc.drivechain.listCalls, 3);
  });
}
