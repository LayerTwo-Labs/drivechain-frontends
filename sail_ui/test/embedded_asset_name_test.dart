import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  group('embeddedAssetName', () {
    for (final daemon in ['bitwindowd', 'drivechaind', 'drivechain-cli', 'hwi-daemon']) {
      test('macOS selects the native ARM64 asset for $daemon', () {
        expect(embeddedAssetName(daemon, isMacOS: true, arch: 'arm64'), 'macos-arm64/$daemon');
      });
    }

    test('macOS reads embedded daemons from the host arch folder', () {
      expect(embeddedAssetName('bitwindowd', isMacOS: true, arch: 'arm64'), 'macos-arm64/bitwindowd');
      expect(embeddedAssetName('bitwindowd', isMacOS: true, arch: 'x86_64'), 'macos-x86_64/bitwindowd');
      expect(embeddedAssetName('drivechaind', isMacOS: true, arch: 'arm64'), 'macos-arm64/drivechaind');
      expect(embeddedAssetName('drivechain-cli', isMacOS: true, arch: 'x86_64'), 'macos-x86_64/drivechain-cli');
    });

    test('non-macOS keeps the canonical name (single host-arch binary)', () {
      expect(embeddedAssetName('bitwindowd', isMacOS: false, arch: 'x86_64'), 'bitwindowd');
      expect(embeddedAssetName('drivechaind', isMacOS: false, arch: 'arm64'), 'drivechaind');
    });

    test('non-daemon binaries never get an arch folder', () {
      expect(embeddedAssetName('bitcoind', isMacOS: true, arch: 'arm64'), 'bitcoind');
      expect(embeddedAssetName('grpcurl', isMacOS: true, arch: 'arm64'), 'grpcurl');
    });
  });
}
