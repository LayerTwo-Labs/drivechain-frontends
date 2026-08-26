import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  group('embeddedAssetName', () {
    test('macOS appends the host arch for embedded daemons', () {
      expect(embeddedAssetName('bitwindowd', isMacOS: true, arch: 'arm64'), 'bitwindowd-arm64');
      expect(embeddedAssetName('bitwindowd', isMacOS: true, arch: 'x86_64'), 'bitwindowd-x86_64');
      expect(embeddedAssetName('drivechaind', isMacOS: true, arch: 'arm64'), 'drivechaind-arm64');
      expect(embeddedAssetName('drivechain-cli', isMacOS: true, arch: 'x86_64'), 'drivechain-cli-x86_64');
    });

    test('non-macOS keeps the canonical name (single host-arch binary)', () {
      expect(embeddedAssetName('bitwindowd', isMacOS: false, arch: 'x86_64'), 'bitwindowd');
      expect(embeddedAssetName('drivechaind', isMacOS: false, arch: 'arm64'), 'drivechaind');
    });

    test('non-daemon binaries are never suffixed', () {
      expect(embeddedAssetName('bitcoind', isMacOS: true, arch: 'arm64'), 'bitcoind');
      expect(embeddedAssetName('grpcurl', isMacOS: true, arch: 'arm64'), 'grpcurl');
    });
  });
}
