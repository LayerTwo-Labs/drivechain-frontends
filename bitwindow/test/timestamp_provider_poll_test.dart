import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';

class _MiscAPI extends MockMiscAPI {
  int listCalls = 0;

  @override
  Future<List<FileTimestamp>> listTimestamps() async {
    listCalls++;
    return [FileTimestamp(id: Int64(1), filename: 'proof.txt', status: 'confirmed')];
  }
}

class _BitwindowRPC extends ChangeNotifier implements BitwindowRPC {
  @override
  final _MiscAPI misc = _MiscAPI();

  @override
  bool get connected => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sync extends SyncProvider {
  _Sync() : super(startTimer: false);

  void poll() => notifyListeners();
}

SyncInfo _at(double height) => SyncInfo(progressCurrent: height, progressGoal: height, lastBlockAt: null);

void main() {
  late _BitwindowRPC rpc;
  late _Sync sync;

  setUp(() async {
    await GetIt.I.reset();
    rpc = _BitwindowRPC();
    sync = _Sync()
      ..mainchainSyncInfo = _at(100)
      ..enforcerSyncInfo = _at(100);
    GetIt.I.registerSingleton<BitwindowRPC>(rpc);
    GetIt.I.registerSingleton<SyncProvider>(sync);
  });

  tearDown(() => GetIt.I.reset());

  test('a sync poll at the same tip does not refetch', () async {
    final provider = TimestampProvider();
    addTearDown(provider.dispose);

    sync.poll();
    await pumpEventQueue();
    sync.poll();
    await pumpEventQueue();
    expect(rpc.misc.listCalls, 1);

    sync.enforcerSyncInfo = _at(101);
    sync.poll();
    await pumpEventQueue();
    expect(rpc.misc.listCalls, 2);
  });

  test('a fetch with the same timestamps does not notify', () async {
    final provider = TimestampProvider();
    addTearDown(provider.dispose);
    await provider.fetch();
    var notified = 0;
    provider.addListener(() => notified++);

    await provider.fetch();

    expect(notified, 0);
  });
}
