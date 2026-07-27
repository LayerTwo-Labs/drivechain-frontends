// Covers the status-dot color the CPU Mining card derives from MiningProvider,
// which reuses DaemonConnectionCard's precedence with no binary behind it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  final theme = SailThemeData.lightTheme(
    SailColorScheme.orange,
    true,
    SailFontValues.inter,
  );

  Color colorFor({required bool isMining, String? error}) => resolveDaemonStatusColor(
    theme: theme,
    connectionError: error,
    startupError: null,
    initializingBinary: false,
    connected: isMining,
    isDownloading: false,
    hasInfoMessage: false,
  );

  test('mining is green', () {
    expect(colorFor(isMining: true), theme.colors.success);
  });

  test('stopped is amber, never red', () {
    final color = colorFor(isMining: false);
    expect(color, theme.colors.orangeLight);
    expect(color, isNot(theme.colors.error));
  });

  test('error is red even while mining', () {
    expect(colorFor(isMining: true, error: 'bitcoin core unreachable'), theme.colors.error);
  });

  group('hash rate formatting', () {
    String format(double rate) {
      final provider = MiningProvider();
      provider.hashRate = rate;
      return provider.formattedHashRate;
    }

    test('scales through each unit', () {
      expect(format(0), '0.0 H/s');
      expect(format(999), '999.0 H/s');
      expect(format(1000), '1.0 KH/s');
      expect(format(5353953.86), '5.4 MH/s');
      expect(format(1.05e12), '1.1 TH/s');
    });

    test('clamps at the largest unit', () {
      expect(format(1e18), '1000.0 PH/s');
    });
  });
}
