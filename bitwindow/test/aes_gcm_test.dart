import 'dart:typed_data';

import 'package:sidechain_core/utils/hex.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/gcm.dart';

Uint8List _b(String h) => Uint8List.fromList(hexDecode(h));

String _seal(String key, String nonce, String aad, String plaintext) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(_b(key)), 128, _b(nonce), _b(aad)));
  return hexEncode(cipher.process(_b(plaintext)));
}

String _open(String key, String nonce, String aad, String sealed) {
  final cipher = GCMBlockCipher(AESEngine())
    ..init(false, AEADParameters(KeyParameter(_b(key)), 128, _b(nonce), _b(aad)));
  return hexEncode(cipher.process(_b(sealed)));
}

const _zeroKey = '0000000000000000000000000000000000000000000000000000000000000000';
const _zeroNonce = '000000000000000000000000';
const _key16 = 'feffe9928665731c6d6a8f9467308308feffe9928665731c6d6a8f9467308308';
const _nonce16 = 'cafebabefacedbaddecaf888';
const _aad16 = 'feedfacedeadbeeffeedfacedeadbeefabaddad2';
const _plain16 =
    'd9313225f88406e5a55909c5aff5269a86a7a9531534f7da2e4c303d8a318a721c3c0c95956809532fcf0e2449a6b525b16aedf5aa0de657ba637b39';
const _sealed16 =
    '522dc1f099567d07f47f37a32a84427d643a8cdcbfe5c0c97598a2bd2555d1aa8cb08e48590dbb3da7b08b1056828838c5f61e6393ba7a0abcc9f662'
    '76fc6ece0f4e1768cddf8853bb2d551b';

void main() {
  group('the GCM spec AES-256 test cases', () {
    test('case 13, nothing to seal', () {
      expect(_seal(_zeroKey, _zeroNonce, '', ''), '530f8afbc74536b9a963b4f1c4cb738b');
    });

    test('case 14, one zero block', () {
      expect(
        _seal(_zeroKey, _zeroNonce, '', '00000000000000000000000000000000'),
        'cea7403d4d606b6e074ec5d3baf39d18d0d1c8a799996bf0265b98b5d48ab919',
      );
    });

    test('case 16, with additional data', () {
      expect(_seal(_key16, _nonce16, _aad16, _plain16), _sealed16);
      expect(_open(_key16, _nonce16, _aad16, _sealed16), _plain16);
    });
  });

  test('gives the same bytes as Go crypto/cipher for a random case', () {
    const key = 'c00913e02a63e4cf532d9b2ce282fad85af699815c18c595ea804462a794f751';
    const nonce = '23135cc728c43daa5aa248d5';
    const aad = 'a17dde4906843049a995cbd0b80d23694897467e10e43cb2ef4662aceef9304835d744e43a';
    const plaintext =
        'f04165e3d13cd1f7b9adead9e072bca6ae92fbb52cc2f48f89ae44e020c506fa047bf7e8bf5a51a3054dbba8bef4c40fe97c737b7c8f72adda57c4a29edf179f02f3d0bfd3eafd8e7733b84037ea87984e250ae0406a71b3b02679e34b30c8bc5f731e1598e7bf36ebef7d2464642faaf1cb2e558fd472e7708cd38223d4c744308f5cd5f94df3386f0a1aa10e0e10a489bbc035913c00555aa37edbd7f36450d1e00d86263a54be0a939d21358a92392cc934b8eb0059df8c414ef896cf79cfbf93d64f411139219e2a2b0c5c925669ede98221155416dd569cc3949408461b88d66725571f4f2afa3043ee14a921dcfe2ad0a92907ae3be01ace9ec325b39d01fab68b965a0c468b00103c009776d77c07ece275d35250054407dd1ed550d00db344213ed8a807bd91d98a20';
    const sealed =
        'b4ee6c0b462a33131707b21e51b002e7fe98108a3de5b40183f4ad30301323db6f53a8150022ea61912513b421ee5a75d09dbe238231d5c967cd564096f5749f14a1ce4028605d58922bffebef73d489e1d6080ce869d66a741edd95e445e6b7f4e24154ebd1ae8a3f63148a633ffb825a4664dfd9718887631571c1405966cbfbe8fb3d4ea67edaf6eae534a5101a2a4335eb2f5077b03c01754eeeb2cf9c70a4970834dc88f8813e3a39a4fcd34954118f062172d0a32be1a409d8d65c58952a4893a73236b735d60f1893a1083d1c41e42018b6a92a106603b6961de9497b6951b0b21b7c33ffa7ff8040507746e7ce17e923b1537803ab87574f671bf08d717b9d0c9d953ff9834c55c754e60ad39df3cdece3ad6aa1b856c1717b44cb47ceaf24e279ec29cabd3ff35b9c2de042a153c9ffe349b769e2398ab2e3';
    expect(_seal(key, nonce, aad, plaintext), sealed);
    expect(_open(key, nonce, aad, sealed), plaintext);
  });

  test('a changed tag or additional data does not open', () {
    final badTag = _sealed16.substring(0, _sealed16.length - 2) + (_sealed16.endsWith('00') ? '01' : '00');
    expect(() => _open(_key16, _nonce16, _aad16, badTag), throwsA(isA<InvalidCipherTextException>()));
    expect(() => _open(_key16, _nonce16, '00', _sealed16), throwsA(isA<InvalidCipherTextException>()));
  });
}
