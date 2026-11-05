import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/config/binaries.dart';
import 'package:sidechain_core/config/sidechains.dart';
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

  const zside = orch_pb.SidechainType.SIDECHAIN_TYPE_ZSIDE;

  SyncInfo at(int blocks, {orch_pb.MainchainSyncPhase? phase}) => SyncInfo(
    progressCurrent: blocks.toDouble(),
    progressGoal: blocks.toDouble(),
    lastBlockAt: null,
    mainchainSyncPhase: phase ?? orch_pb.MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_UNSPECIFIED,
  );

  test('a new sidechain block fires the listeners of that sidechain only', () {
    final sync = SyncProvider(startTimer: false);
    final zsideBlocks = <int>[];
    final thunderBlocks = <int>[];
    sync.onNewSidechainBlock(ZSide(), zsideBlocks.add);
    sync.onNewSidechainBlock(Thunder(), thunderBlocks.add);

    sync.maybeFireNewSidechainBlock(zside, at(5));
    sync.maybeFireNewSidechainBlock(zside, at(5));
    sync.maybeFireNewSidechainBlock(zside, at(4));
    sync.maybeFireNewSidechainBlock(zside, at(6));

    expect(zsideBlocks, [5, 6]);
    expect(thunderBlocks, isEmpty);
  });

  test('a removed listener does not fire', () {
    final sync = SyncProvider(startTimer: false);
    final blocks = <int>[];
    sync.onNewSidechainBlock(ZSide(), blocks.add);
    sync.offNewSidechainBlock(ZSide(), blocks.add);

    sync.maybeFireNewSidechainBlock(zside, at(5));

    expect(blocks, isEmpty);
  });

  test('a reset lets the first block of the new network fire', () {
    final sync = SyncProvider(startTimer: false);
    final blocks = <int>[];
    sync.onNewSidechainBlock(ZSide(), blocks.add);

    sync.maybeFireNewSidechainBlock(zside, at(800));
    sync.reset();
    sync.maybeFireNewSidechainBlock(zside, at(1));

    expect(blocks, [800, 1]);
  });

  test('a binary that is not a sidechain has no new blocks to listen to', () {
    final sync = SyncProvider(startTimer: false);
    expect(() => sync.onNewSidechainBlock(BitcoinCore(), (_) {}), throwsArgumentError);
  });

  test('a mainchain sync count is no sidechain block', () {
    final sync = SyncProvider(startTimer: false);
    final blocks = <int>[];
    sync.onNewSidechainBlock(ZSide(), blocks.add);
    final syncing = orch_pb.MainchainSyncPhase.values.firstWhere(
      (phase) => phase != orch_pb.MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_UNSPECIFIED,
    );

    sync.maybeFireNewSidechainBlock(zside, at(900000, phase: syncing));
    sync.maybeFireNewSidechainBlock(zside, at(5));

    expect(blocks, [5]);
  });
}
