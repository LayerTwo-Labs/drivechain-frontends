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
}
