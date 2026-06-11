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
        'files': {
          'linux-x86_64': 'core-linux.tar.gz',
          'macos-x86_64': 'core-mac.tar.gz',
          'macos-arm64': 'core-mac.tar.gz',
          'windows-x86_64': 'core-win.zip',
        },
      },
      'knots': {
        'files': {
          'linux-x86_64': 'knots-linux.tar.gz',
          'macos-x86_64': 'knots-mac.tar.gz',
          'macos-arm64': 'knots-mac.tar.gz',
          'windows-x86_64': 'knots-win.zip',
        },
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

  group('fileForPlatform arch selection', () {
    test('prefers the native arm64 build', () {
      final files = {'macos-x86_64': 'mac-x86.zip', 'macos-arm64': 'mac-arm.zip'};
      expect(fileForPlatform(files, OS.macos, 'arm64'), 'mac-arm.zip');
    });

    test('macOS arm64 with no native entry resolves null (no swap to x86_64)', () {
      final files = {'macos-x86_64': 'mac-x86.zip'};
      expect(fileForPlatform(files, OS.macos, 'arm64'), isNull);
    });

    test('x86_64 resolves the x86_64 build', () {
      final files = {'macos-x86_64': 'mac-x86.zip', 'macos-arm64': 'mac-arm.zip'};
      expect(fileForPlatform(files, OS.macos, 'x86_64'), 'mac-x86.zip');
    });

    test('missing platform resolves null (no cross-arch Linux fallback)', () {
      expect(fileForPlatform({'linux-x86_64': 'lin.zip'}, OS.linux, 'arm64'), isNull);
    });
  });
}
