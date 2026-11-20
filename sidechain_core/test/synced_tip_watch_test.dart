import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sidechain_core/providers/sync_provider.dart';

SyncInfo _at(double height, {int time = 0}) => SyncInfo(
  progressCurrent: height,
  progressGoal: height,
  lastBlockAt: time == 0 ? null : Timestamp(seconds: Int64(time)),
);

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    }
  });

  test('a synced tip fires one time per block', () {
    final sync = SyncProvider(startTimer: false)
      ..mainchainSyncInfo = _at(100)
      ..enforcerSyncInfo = _at(100);
    final watch = SyncedTipWatch();

    expect(watch.moved(sync, synced: true), isTrue);
    expect(watch.moved(sync, synced: true), isFalse);

    sync.mainchainSyncInfo = _at(101);
    expect(watch.moved(sync, synced: true), isTrue);
    sync.enforcerSyncInfo = _at(101);
    expect(watch.moved(sync, synced: true), isTrue);
    expect(watch.moved(sync, synced: true), isFalse);
  });

  test('a new block at the same height fires', () {
    final sync = SyncProvider(startTimer: false)
      ..mainchainSyncInfo = _at(100, time: 1000)
      ..enforcerSyncInfo = _at(100);
    final watch = SyncedTipWatch();

    expect(watch.moved(sync, synced: true), isTrue);
    sync.mainchainSyncInfo = _at(100, time: 1001);
    expect(watch.moved(sync, synced: true), isTrue);
    expect(watch.moved(sync, synced: true), isFalse);
  });

  test('a sync that ends fires again at the same tip', () {
    final sync = SyncProvider(startTimer: false)
      ..mainchainSyncInfo = _at(100)
      ..enforcerSyncInfo = _at(100);
    final watch = SyncedTipWatch();

    expect(watch.moved(sync, synced: true), isTrue);
    expect(watch.moved(sync, synced: false), isFalse);
    expect(watch.moved(sync, synced: true), isTrue);
  });
}
