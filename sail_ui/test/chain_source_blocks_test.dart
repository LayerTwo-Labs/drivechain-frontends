import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

SyncInfo _at(int height) => SyncInfo(
  progressCurrent: height.toDouble(),
  progressGoal: height.toDouble(),
  lastBlockAt: null,
);

void main() {
  // An electrum wallet runs no local node, so the chain source height is the
  // only block count the bottom nav can show.
  test('the nav shows the chain source height', () {
    expect(chainSourceBlocks(_at(963476)), '963 476 blocks');
  });

  // A chain source that answered nothing yet must draw no label at all — a
  // "0 blocks" reads as a chain at genesis.
  test('no height draws nothing', () {
    expect(chainSourceBlocks(_at(0)), isNull);
    expect(chainSourceBlocks(null), isNull);
  });
}
