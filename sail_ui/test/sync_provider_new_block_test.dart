import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

// SyncProvider's onNewBlock broadcast (#1766). Tests drive the dedupe-and-fire
// logic via maybeFireNewBlock so they don't need to stand up a fake
// orchestrator transport — the public path through _fetch composes
// _toSyncInfo+maybeFireNewBlock+notifyListeners, but the new-block contract
// lives entirely in maybeFireNewBlock and that's what these tests pin.

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    }
  });

  SyncProvider build() => SyncProvider(startTimer: false);

  test('fires once with the new height on a strict increment', () {
    final p = build();
    final fired = <int>[];
    p.onNewBlock(fired.add);

    p.maybeFireNewBlock(100);

    expect(fired, [100]);
  });

  test('does not fire when the height is unchanged', () {
    final p = build();
    final fired = <int>[];
    p.onNewBlock(fired.add);

    p.maybeFireNewBlock(100);
    p.maybeFireNewBlock(100);

    expect(fired, [100], reason: 'duplicate same-height polls must not refire');
  });

  test('does not fire when the height regresses', () {
    // Edge: a network re-org or the orchestrator returning a stale snapshot
    // briefly. We don't want to spam refreshes on regress.
    final p = build();
    final fired = <int>[];
    p.onNewBlock(fired.add);

    p.maybeFireNewBlock(100);
    p.maybeFireNewBlock(99);

    expect(fired, [100]);
  });

  test('fires once per increment across a sequence', () {
    final p = build();
    final fired = <int>[];
    p.onNewBlock(fired.add);

    p.maybeFireNewBlock(100);
    p.maybeFireNewBlock(101);
    p.maybeFireNewBlock(102);

    expect(fired, [100, 101, 102]);
  });

  test('reset() clears the dedupe baseline so the next block fires again', () {
    // Network swap goes through reset() — without this clear, a swap from
    // mainnet (height 800k) to regtest (height 0) would never refire until
    // regtest passed 800k. See sync_provider.dart's reset().
    final p = build();
    final fired = <int>[];
    p.onNewBlock(fired.add);

    p.maybeFireNewBlock(800000);
    p.reset();
    p.maybeFireNewBlock(1);

    expect(fired, [800000, 1]);
  });

  test('offNewBlock unsubscribes the callback', () {
    final p = build();
    final fired = <int>[];
    void cb(int h) => fired.add(h);
    p.onNewBlock(cb);
    p.maybeFireNewBlock(100);

    p.offNewBlock(cb);
    p.maybeFireNewBlock(101);

    expect(fired, [100]);
  });

  test('a throwing listener does not block siblings or the dedupe baseline', () {
    final p = build();
    final fired = <int>[];
    p.onNewBlock((_) => throw StateError('bad listener'));
    p.onNewBlock(fired.add);

    p.maybeFireNewBlock(100);
    p.maybeFireNewBlock(101);

    expect(fired, [100, 101], reason: 'sibling listener must still fire after a throwing one');
  });
}
