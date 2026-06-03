import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

/// Regression for "clicking the Settings icon next to Bitcoin Core crashes
/// BitWindow". Bitcoin Core is variant-aware: its download block carries no
/// top-level `files`, only per-variant ones. The old ChainSettingsModal did
/// `downloadConfig.files[network]![os]`, so the null assertion threw the moment
/// the modal opened for Core. The fix resolves the file from the active variant
/// instead; this mirrors that resolution so it can't regress.
String? resolveDownloadFile(DownloadConfig cfg, BitcoinNetwork network, OS os, String activeId) {
  var file = cfg.files[network]?[os];
  if (file == null && cfg.variants.isNotEmpty) {
    file = (cfg.variants[activeId] ?? cfg.variants.values.first)[os];
  }
  return file;
}

void main() {
  // Mirrors the bitcoincore `download` block in chains_config.json: no `files`,
  // a `variants` map keyed by variant id, each with its own per-OS files.
  final coreConfig = DownloadConfigJson.fromJson({
    'binary': 'bitcoind',
    'variants': {
      'core': {
        'files': {'linux': 'core-linux.tar.gz', 'macos': 'core-mac.tar.gz', 'windows': 'core-win.zip'},
      },
      'knots': {
        'files': {'linux': 'knots-linux.tar.gz', 'macos': 'knots-mac.tar.gz', 'windows': 'knots-win.zip'},
      },
    },
  });

  group('variant-aware DownloadConfig (Bitcoin Core)', () {
    test('parses with empty top-level files and populated variants', () {
      // files[network] is null for Core — exactly what the old `!` crashed on.
      expect(coreConfig.files, isEmpty);
      expect(coreConfig.variants.keys, containsAll(<String>['core', 'knots']));
      expect(coreConfig.variants['knots']![OS.macos], 'knots-mac.tar.gz');
    });

    test('resolution returns the active variant file instead of crashing', () {
      final file = resolveDownloadFile(
        coreConfig,
        BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
        OS.macos,
        'knots',
      );
      expect(file, 'knots-mac.tar.gz');
    });

    test('resolution falls back to the first variant for an unknown active id', () {
      final file = resolveDownloadFile(
        coreConfig,
        BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
        OS.linux,
        'does-not-exist',
      );
      expect(file, 'core-linux.tar.gz');
    });
  });
}
