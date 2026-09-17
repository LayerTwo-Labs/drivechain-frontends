import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  // Every one of these lands in the console on a cold start, once per poll.
  test('a daemon that boots counts as an expected error', () {
    final boot = [
      'SocketException: Connection attempt cancelled, host: 127.0.0.1, port: 30400',
      'DrivechainException: could not list sidechains: enforcer: unavailable: enforcer does not accept connections',
      'BitwindowException: could not list blocks: -28: Loading block index…',
      'BitwindowException: could not list blocks: -28: Verifying blocks…',
    ];

    for (final e in boot) {
      expect(isExpectedBootError(Exception(e)), isTrue, reason: e);
    }
  });

  test('a real fault still counts', () {
    expect(isExpectedBootError(Exception('no such column: slot')), isFalse);
  });
}
