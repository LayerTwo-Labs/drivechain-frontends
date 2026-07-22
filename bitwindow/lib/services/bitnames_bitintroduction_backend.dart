import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/services/bitintroduction_codec.dart';
import 'package:sail_ui/sail_ui.dart';

class BitnamesBitIntroductionSigner implements BitIntroductionSigningBackend {
  const BitnamesBitIntroductionSigner(this.rpc);
  final BitnamesRPC rpc;
  @override
  Future<String> sign({required String signingPublicKey, required String payload}) =>
      rpc.signArbitraryMsg(msg: payload, verifyingKey: signingPublicKey);
}

class BitnamesBitIntroductionSignatureVerifier implements BitIntroductionSignatureBackend {
  const BitnamesBitIntroductionSignatureVerifier(this.rpc);
  final BitnamesRPC rpc;

  @override
  Future<bool> verify({
    required String signingPublicKey,
    required String payload,
    required String signature,
  }) => rpc.verifySignature(signature: signature, verifyingKey: signingPublicKey, msg: payload);
}

class BitnamesBitMessageCipher implements BitMessageCipherBackend {
  const BitnamesBitMessageCipher(this.rpc);
  final BitnamesRPC rpc;

  @override
  Future<String> encrypt({required String encryptionPublicKey, required String plaintext}) =>
      rpc.encryptMsg(msg: plaintext, encryptionPubkey: encryptionPublicKey);

  @override
  Future<String> decrypt({required String encryptionPublicKey, required String ciphertext}) =>
      rpc.decryptMsg(ciphertext: ciphertext, encryptionPubkey: encryptionPublicKey);
}

class BitnamesBitMessageProfileVerifier implements BitMessageProfileVerifier {
  const BitnamesBitMessageProfileVerifier(this.rpc);
  final BitnamesRPC rpc;

  @override
  Future<VerifiedBitMessageProfile> verify(BitMessageProfile profile) async {
    final resolution = await rpc.resolveBitName(profile.bitNameHash);
    if (resolution == null) throw StateError('BitName is no longer registered');
    return verifyAt(profile, resolution.data, canonicalJsonEncode(resolution.outpoint));
  }

  VerifiedBitMessageProfile verifyAt(BitMessageProfile profile, BitNameData data, String reference) {
    final commitment = data.commitment;
    if (commitment == null) throw StateError('BitName has not committed to a reply profile');
    if (!_sameKey(data.signingPubkey, profile.signingPublicKey)) {
      throw StateError('Reply profile signing key does not match BitNames');
    }
    if (!_sameKey(data.encryptionPubkey, profile.encryptionPublicKey)) {
      throw StateError('Reply profile encryption key does not match BitNames');
    }
    if (data.paymailFeeSats != profile.paymailFeeSats) {
      throw StateError('Reply profile introduction fee does not match BitNames');
    }
    return VerifiedBitMessageProfile.verified(
      profile: profile,
      onChainCommitment: commitment,
      verificationReference: reference,
    );
  }

  bool _sameKey(String? onChain, String claimed) => onChain?.toLowerCase() == claimed.toLowerCase();
}
