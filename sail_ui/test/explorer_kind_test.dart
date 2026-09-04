import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/explorer/v1/explorer.pb.dart' as pb;

void main() {
  group('explorer', () {
    test('names each kind so a reader sees money arriving or leaving', () {
      expect(kindLabel(pb.Kind.KIND_DEPOSIT), 'Deposit');
      expect(kindLabel(pb.Kind.KIND_WITHDRAWAL), 'Withdrawal');
      expect(kindLabel(pb.Kind.KIND_TRANSFER), 'Transfer');
      expect(kindLabel(pb.Kind.KIND_UNSPECIFIED), 'Transfer');
    });

    test('files every chain under the key the orchestrator uses', () {
      // A display name is not a key: Big Block Covenant files under bbc.
      expect(Bbc().registryKey, 'bbc');
      expect(LiquidSignet().registryKey, 'liquid-signet');
      expect(Thunder().registryKey, 'thunder');
      expect(ZSide().registryKey, 'zside');
      expect(CoinShift().registryKey, 'coinshift');
      expect(BitAssets().registryKey, 'bitassets');
      for (final chain in Sidechain.all) {
        expect(
          Sidechain.fromString(chain.registryKey),
          isNotNull,
          reason: '${chain.name} files under ${chain.registryKey}',
        );
      }
    });

    test('shortens a long id and leaves a short one alone', () {
      const txid = '48b4eed66e27c813e1d0f78746c2706da309b673b42a18d03fe50ab3524aecae';
      expect(shortenId(txid), '48b4eed6…524aecae');
      expect(shortenId('short'), 'short');
    });
  });
}
