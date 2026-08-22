import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  Future<orch_pb.GetSyncStatusResponse> getSyncStatus() async => orch_pb.GetSyncStatusResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBitwindow implements BitwindowRPC {
  int syncInfoCalls = 0;

  @override
  BitwindowAPI get bitwindowd => _FakeBitwindowd(this);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBitwindowd implements BitwindowAPI {
  _FakeBitwindowd(this.parent);

  final _FakeBitwindow parent;

  @override
  Future<GetSyncInfoResponse> getSyncInfo() async {
    parent.syncInfoCalls++;
    return GetSyncInfoResponse(tipBlockHeight: Int64(1), headerHeight: Int64(10));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeBitwindow bitwindow;

  Future<SyncProvider> boot(wmpb.NodeMode mode) async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
    bitwindow = _FakeBitwindow();
    GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = mode);
    return SyncProvider(startTimer: false);
  }

  tearDown(() async {
    await GetIt.I.reset();
  });

  // The bitwindowd card reads Bitcoin Core through bitwindowd, and light mode
  // runs neither. Each poll wrote an error to both logs.
  test('the bitwindowd poll stops in light mode', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_LIGHT);

    await provider.fetch();

    expect(bitwindow.syncInfoCalls, 0);
  });

  // A switch to light mode leaves the last snapshot behind. An unsynced one
  // holds the poll at 100 ms for the rest of the session.
  test('a skipped poll drops the old bitwindowd snapshot', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_LIGHT);
    provider.bitwindowdSyncInfo = SyncInfo(progressCurrent: 1, progressGoal: 10, lastBlockAt: null);
    provider.bitwindowdError = 'stale';

    expect(SyncProvider.connectionWantsAggressivePoll(provider.bitwindowdSyncInfo, null), isTrue);

    await provider.fetch();

    expect(provider.bitwindowdSyncInfo, isNull);
    expect(provider.bitwindowdError, isNull);
  });

  test('the bitwindowd poll runs in full mode', () async {
    final provider = await boot(wmpb.NodeMode.NODE_MODE_FULL);

    await provider.fetch();

    expect(bitwindow.syncInfoCalls, 1);
    expect(provider.bitwindowdSyncInfo, isNotNull);
  });
}
