import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sidechain_core/providers/sync_provider.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  orch_pb.WatchSyncStatusResponse frame(int blocks) => orch_pb.WatchSyncStatusResponse(
    status: orch_pb.GetSyncStatusResponse(
      mainchain: orch_pb.ChainSync(blocks: blocks, headers: blocks),
      enforcer: orch_pb.ChainSync(blocks: blocks, headers: blocks),
    ),
  );

  test('a watch frame applies the snapshot and fires the new block', () {
    final sync = SyncProvider(startTimer: false);
    var notifies = 0;
    sync.addListener(() => notifies++);
    final blocks = <int>[];
    sync.onNewBlock(blocks.add);

    sync.applyWatchFrame(frame(101));
    expect(notifies, 1);
    expect(sync.mainchainSyncInfo!.progressCurrent, 101);
    expect(sync.isSynced, isTrue);

    sync.applyWatchFrame(orch_pb.WatchSyncStatusResponse(heartbeat: true));
    sync.applyWatchFrame(frame(101));
    expect(notifies, 1);

    sync.applyWatchFrame(frame(102));
    expect(notifies, 2);
    expect(blocks, [101, 102]);
  });
}
