import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('humanizeTransactionLoadError', () {
    test('special-cases NoActiveWalletException', () {
      final msg = humanizeTransactionLoadError(const NoActiveWalletException());
      expect(msg, contains('Open a wallet first'));
    });

    test('matches not-found-style errors', () {
      expect(
        humanizeTransactionLoadError(Exception('transaction not found')),
        contains('not found in the active wallet'),
      );
      expect(
        humanizeTransactionLoadError(Exception('No such tx')),
        contains('not found in the active wallet'),
      );
    });

    test('matches connection-style errors', () {
      expect(
        humanizeTransactionLoadError(Exception('connection refused')),
        contains('Could not reach the orchestrator'),
      );
      expect(
        humanizeTransactionLoadError(Exception('UNAVAILABLE: backend down')),
        contains('Could not reach the orchestrator'),
      );
    });

    test('falls back to generic copy for unknown errors', () {
      final msg = humanizeTransactionLoadError(Exception('weird internal goo'));
      expect(msg, contains('Could not load this transaction'));
      // Must not leak the raw exception string into user-facing copy.
      expect(msg, isNot(contains('weird internal goo')));
    });
  });
}
