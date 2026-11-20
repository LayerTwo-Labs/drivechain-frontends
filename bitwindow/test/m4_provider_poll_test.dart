import 'package:bitwindow/providers/m4_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/m4/v1/m4.pb.dart' as m4pb;

import 'mocks/api_mock.dart';

class _M4API extends MockM4API {
  int historyCalls = 0;

  @override
  Future<List<m4pb.M4HistoryEntry>> getM4History({int limit = 6}) async {
    historyCalls++;
    return [m4pb.M4HistoryEntry(blockHeight: 7)];
  }
}

class _API extends MockAPI {
  _API() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _M4API fakeM4 = _M4API();

  @override
  _M4API get m4 => fakeM4;
}

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  bool get drivechainFeaturesAvailable => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sync extends SyncProvider {
  _Sync() : super(startTimer: false);

  void poll() => notifyListeners();
}

SyncInfo _at(double height) => SyncInfo(progressCurrent: height, progressGoal: height, lastBlockAt: null);

void main() {
  late _API rpc;
  late _Sync sync;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    rpc = _API();
    sync = _Sync()
      ..mainchainSyncInfo = _at(100)
      ..enforcerSyncInfo = _at(100);
    GetIt.I.registerSingleton<BitwindowRPC>(rpc);
    GetIt.I.registerSingleton<SyncProvider>(sync);
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
  });

  tearDown(() => GetIt.I.reset());

  test('a sync poll at the same tip does not refetch', () async {
    final provider = M4Provider();
    addTearDown(provider.dispose);

    sync.poll();
    await pumpEventQueue();
    sync.poll();
    await pumpEventQueue();
    expect(rpc.m4.historyCalls, 1);

    sync.mainchainSyncInfo = _at(101);
    sync.poll();
    await pumpEventQueue();
    expect(rpc.m4.historyCalls, 2);
  });

  test('a fetch with the same data does not notify', () async {
    final provider = M4Provider();
    addTearDown(provider.dispose);
    await provider.fetchAll();
    var notified = 0;
    provider.addListener(() => notified++);

    await provider.fetchAll();

    expect(notified, 0);
  });

  test('a fetch during a fetch runs one more time after it', () async {
    final provider = M4Provider();
    addTearDown(provider.dispose);

    await Future.wait([provider.fetchAll(), provider.fetchAll(), provider.fetchAll()]);

    expect(rpc.m4.historyCalls, 2);
  });
}
