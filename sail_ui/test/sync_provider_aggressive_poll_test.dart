import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

SyncInfo _info({
  double current = 0,
  double goal = 0,
  bool downloading = false,
}) => SyncInfo(
  progressCurrent: current,
  progressGoal: goal,
  lastBlockAt: null,
  downloadInfo: DownloadInfo(
    progress: current,
    total: goal,
    isDownloading: downloading,
  ),
);

void main() {
  group('SyncProvider.connectionWantsAggressivePoll', () {
    test('returns false when info is null', () {
      expect(SyncProvider.connectionWantsAggressivePoll(null, null), false);
    });

    test('returns false when the connection reports an error', () {
      // The orchestrator marks absent sidechains with error="not running".
      // Those used to drag the global cadence down to 100ms forever.
      expect(
        SyncProvider.connectionWantsAggressivePoll(_info(), 'not running'),
        false,
      );
      expect(
        SyncProvider.connectionWantsAggressivePoll(
          _info(current: 100, goal: 100),
          'rpc unavailable',
        ),
        false,
      );
    });

    test('returns true while a binary is being downloaded', () {
      final info = _info(current: 25, goal: 100, downloading: true);
      expect(SyncProvider.connectionWantsAggressivePoll(info, null), true);
      // Empty error string is treated as no error.
      expect(SyncProvider.connectionWantsAggressivePoll(info, ''), true);
    });

    test('returns true while a healthy connection is not yet synced', () {
      final info = _info(current: 50, goal: 100);
      expect(SyncProvider.connectionWantsAggressivePoll(info, null), true);
    });

    test('returns false once the healthy connection is fully synced', () {
      final info = _info(current: 100, goal: 100);
      expect(SyncProvider.connectionWantsAggressivePoll(info, null), false);
    });
  });
}
