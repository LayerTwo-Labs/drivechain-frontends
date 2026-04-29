// Covers the color precedence used by DaemonConnectionCard's status dot.
//
// The regression we're guarding against: before this change the dot would flash
// RED any time a binary was !connected, even during the brief window between
// "bitwindowd spawned bitcoind" and "orchestrator reports initializing=true".
// That looked like a broken startup to users when it was actually just boot.
//
// New precedence (see `resolveDaemonStatusColor`):
//   connectionError  -> red
//   connected        -> green   (short-circuits — stale startupError/init ignored)
//   startupError     -> amber   (warmup message, only while !connected)
//   initializing     -> amber
//   downloading      -> amber
//   has infoMessage  -> info
//   !connected only  -> amber   (was red before this change — the fix)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  final theme = SailThemeData.lightTheme(
    SailColorScheme.orange,
    true,
    SailFontValues.inter,
  );

  Color call({
    String? connectionError,
    String? startupError,
    bool initializingBinary = false,
    bool connected = false,
    bool isDownloading = false,
    bool hasInfoMessage = false,
  }) => resolveDaemonStatusColor(
    theme: theme,
    connectionError: connectionError,
    startupError: startupError,
    initializingBinary: initializingBinary,
    connected: connected,
    isDownloading: isDownloading,
    hasInfoMessage: hasInfoMessage,
  );

  group('resolveDaemonStatusColor', () {
    test('red only when an explicit connectionError is set', () {
      expect(call(connectionError: 'boom'), theme.colors.error);
      // A connectionError wins over everything else.
      expect(
        call(
          connectionError: 'boom',
          startupError: 'Loading block index…',
          initializingBinary: true,
          connected: true,
        ),
        theme.colors.error,
      );
    });

    test('amber (not red) when a binary is simply not yet connected', () {
      // The key regression: no error, no initialising flag, just booting.
      // This used to be red; it must now be amber.
      expect(call(connected: false), theme.colors.orangeLight);
      expect(call(connected: false), isNot(theme.colors.error));
    });

    test('amber when orchestrator reports startupError but no connectionError', () {
      expect(
        call(startupError: 'Loading block index…', connected: false),
        theme.colors.orangeLight,
      );
    });

    // BIP324 headers-presync: BitcoindHealthCheck on the orchestrator
    // synthesises a startup error containing the peer-reported height when
    // getblockchaininfo still reports 0/0. The UI must treat this exactly
    // like the -28 warmup phase: amber dot, !connected — not green/connected
    // with a frozen-looking 0/0 progress bar (the bug this guards against).
    test('amber for presync — synthetic startupError carrying header height', () {
      expect(
        call(
          startupError: 'Pre-synchronizing blockheaders, height: 226000',
          connected: false,
        ),
        theme.colors.orangeLight,
      );
    });

    test('amber while initializing', () {
      expect(
        call(initializingBinary: true, connected: false),
        theme.colors.orangeLight,
      );
    });

    test('amber while downloading a binary', () {
      expect(call(connected: true, isDownloading: true), theme.colors.orangeLight);
    });

    test('info color when only an infoMessage is set on a connected daemon', () {
      expect(call(connected: true, hasInfoMessage: true), theme.colors.info);
    });

    test('success when fully healthy', () {
      expect(call(connected: true), theme.colors.success);
    });

    test('connected wins over stale startupError / initializing', () {
      // Once the daemon is on the wire, lingering warmup signals are ignored.
      expect(
        call(connected: true, startupError: 'Loading block index…'),
        theme.colors.success,
      );
      expect(
        call(connected: true, initializingBinary: true),
        theme.colors.success,
      );
      expect(
        call(connected: true, startupError: 'x', initializingBinary: true),
        theme.colors.success,
      );
    });
  });

  // The regression this guards against: the enforcer dies at boot with a
  // fatal "ZMQ address for mempool sync is not reachable" connectionError,
  // but bottom_nav.dart was passing infoMessage="Waiting for L1 to sync
  // headers..." into the card. Old precedence (infoMessage first) hid the
  // real error. New precedence: real failure signals win.
  group('resolveDaemonStatusMessage', () {
    String call({
      String? connectionError,
      String? startupError,
      String? infoMessage,
      bool initializingBinary = false,
      String? initializingFallback,
    }) => resolveDaemonStatusMessage(
      connectionError: connectionError,
      startupError: startupError,
      infoMessage: infoMessage,
      initializingBinary: initializingBinary,
      initializingFallback: initializingFallback,
    );

    test('connectionError beats infoMessage', () {
      expect(
        call(
          connectionError: 'ZMQ address for mempool sync is not reachable',
          infoMessage: 'Waiting for L1 to sync headers...',
        ),
        'ZMQ address for mempool sync is not reachable',
      );
    });

    test('startupError beats infoMessage', () {
      expect(
        call(
          startupError: 'Loading block index…',
          infoMessage: 'Waiting for L1 to sync headers...',
        ),
        'Loading block index…',
      );
    });

    test('connectionError beats startupError', () {
      expect(
        call(connectionError: 'real fail', startupError: 'warming up'),
        'real fail',
      );
    });

    test('infoMessage shows when no error or warmup is set', () {
      expect(call(infoMessage: 'Waiting for L1 to sync headers...'), 'Waiting for L1 to sync headers...');
    });

    test('initializing fallback used when no other signal', () {
      expect(
        call(initializingBinary: true, initializingFallback: 'Loading wallet…'),
        'Loading wallet…',
      );
      expect(call(initializingBinary: true), 'Initializing...');
    });

    test('falls back to "Not connected" when no signal at all', () {
      expect(call(), 'Not connected');
    });
  });
}
