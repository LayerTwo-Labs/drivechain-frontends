import 'package:bitwindow/pages/welcome/multisig_config_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a replaced public key drops the private key of the old one', () {
    final k = CosignerKeystore(owner: 'Key 1')
      ..xpub = 'xpubOld'
      ..xprv = 'xprvOld'
      ..fingerprint = 'aaaaaaaa';

    k.replaceKey(parseKeyExpression("[d34db33f/48'/1'/0'/2']xpubNew"));

    expect(k.xpub, 'xpubNew');
    expect(k.xprv, isNull);
    expect(k.fingerprint, 'd34db33f');
    expect(k.derivationPath, "m/48'/1'/0'/2'");
    expect(cosignerInputs([k]).single.xprv, isEmpty);
  });
}
