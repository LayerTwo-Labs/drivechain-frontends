import 'package:bitwindow/pages/welcome/multisig_config_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SingleSigResult', () {
    test('defaults to the electrum provider', () {
      const r = SingleSigResult(scriptType: 'native-segwit');
      expect(r.provider, 'electrum');
    });

    test('carries the chosen provider', () {
      const r = SingleSigResult(scriptType: 'native-segwit', provider: 'core');
      expect(r.provider, 'core');
    });
  });

  group('coldcardConfig', () {
    MultisigWalletSpec spec(String scriptType, {String? fingerprint = 'd34db33f'}) {
      return MultisigWalletSpec(
        m: 2,
        n: 2,
        scriptType: scriptType,
        cosigners: [
          CosignerKeystore(owner: 'Key 1')
            ..xpub = 'tpub1'
            ..fingerprint = fingerprint
            ..originPath = "48'/1'/0'/2'",
          CosignerKeystore(owner: 'Key 2')
            ..xpub = 'tpub2'
            ..fingerprint = fingerprint
            ..originPath = "48'/1'/0'/2'",
        ],
        receiveDescriptor: '',
        changeDescriptor: '',
      );
    }

    test('emits a P2WSH setup file', () {
      final out = spec('wsh').coldcardConfig('vault');
      expect(out, contains('Format: P2WSH'));
      expect(out, contains('Policy: 2 of 2'));
      expect(out, contains('D34DB33F: tpub1'));
    });

    test('returns null for taproot, which has no Coldcard format', () {
      expect(spec('tr').coldcardConfig('vault'), isNull);
    });

    test('returns null when a fingerprint is missing', () {
      expect(spec('wsh', fingerprint: '').coldcardConfig('vault'), isNull);
    });
  });

  group('parseKeyExpression', () {
    test('splits an origin-prefixed key', () {
      final r = parseKeyExpression("[d34db33f/84'/1'/0']tpubDC6RvHt");
      expect(r.fingerprint, 'd34db33f');
      expect(r.originPath, "84'/1'/0'");
      expect(r.xpub, 'tpubDC6RvHt');
    });

    test('leaves a bare xpub alone', () {
      final r = parseKeyExpression('  tpubDC6RvHt  ');
      expect(r.fingerprint, isNull);
      expect(r.originPath, isNull);
      expect(r.xpub, 'tpubDC6RvHt');
    });
  });
}
