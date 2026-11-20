import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/providers/sync_provider.dart';

SyncInfo _at(double height) => SyncInfo(progressCurrent: height, progressGoal: height, lastBlockAt: null);

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
