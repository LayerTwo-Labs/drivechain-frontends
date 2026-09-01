import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  // The hosted index trails the node it indexes, so a node that passed the
  // tip the index reports holds everything anyone knows of.
  test('a node past the reported tip counts as synced', () {
    final info = SyncInfo(progressCurrent: 5, progressGoal: 4, lastBlockAt: null);
    expect(info.isSynced, isTrue);
  });

  test('a node at the reported tip counts as synced', () {
    final info = SyncInfo(progressCurrent: 4, progressGoal: 4, lastBlockAt: null);
    expect(info.isSynced, isTrue);
  });

  test('a node behind the reported tip does not', () {
    final info = SyncInfo(progressCurrent: 3, progressGoal: 4, lastBlockAt: null);
    expect(info.isSynced, isFalse);
  });

  test('an unknown tip does not count as synced', () {
    final info = SyncInfo(progressCurrent: 3, progressGoal: 0, lastBlockAt: null);
    expect(info.isSynced, isFalse);
  });
}
