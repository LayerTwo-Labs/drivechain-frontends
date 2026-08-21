import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  // The drynet4 node of 2026-08-20: it holds 979995 and refuses the branch
  // that starts at 979996.
  test('the message names where the refused branch starts', () {
    final message = offNetworkMessage(
      SyncInfo(
        progressCurrent: 979995,
        progressGoal: 979995,
        lastBlockAt: null,
        peerBestHeight: 980185,
        rejectedBranch: true,
        refusedBranchStart: 979996,
      ),
    );

    expect(message, contains('branch from block 979996'));
    expect(message, contains('190 blocks behind'));
    expect(message, isNot(contains('Core')));
  });

  // An older node reports no branch start, so the message drops the number.
  test('the message works without a branch start', () {
    final message = offNetworkMessage(
      SyncInfo(
        progressCurrent: 979995,
        progressGoal: 979995,
        lastBlockAt: null,
        peerBestHeight: 980185,
        rejectedBranch: true,
      ),
    );

    expect(message, contains('190 blocks behind'));
  });

  // A node that follows its peers says nothing at all.
  test('a node on the network chain shows no message', () {
    expect(
      offNetworkMessage(
        SyncInfo(progressCurrent: 100, progressGoal: 100, lastBlockAt: null, peerBestHeight: 100),
      ),
      isNull,
    );
    expect(offNetworkMessage(null), isNull);
  });
}
