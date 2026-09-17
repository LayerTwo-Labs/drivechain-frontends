import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  test('a sidechain that waits for the headers says so', () {
    expect(
      additionalDaemonWait(headerSyncPending: true, waitsForCore: false),
      'Waiting for Bitcoin Core header sync',
    );
  });

  test('a daemon that holds its scan says it waits for Core', () {
    expect(
      additionalDaemonWait(headerSyncPending: false, waitsForCore: true),
      'Waits for Bitcoin Core',
    );
  });

  test('the header sync comes first', () {
    expect(
      additionalDaemonWait(headerSyncPending: true, waitsForCore: true),
      'Waiting for Bitcoin Core header sync',
    );
  });

  test('a daemon that runs shows its bar', () {
    expect(additionalDaemonWait(headerSyncPending: false, waitsForCore: false), isNull);
  });
}
