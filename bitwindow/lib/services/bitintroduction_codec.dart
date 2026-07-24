import 'dart:convert';

import 'package:bitwindow/models/bitintroduction_protocol.dart';

abstract interface class BitIntroductionSigningBackend {
  Future<String> sign({required String signingPublicKey, required String payload});
}

abstract interface class BitIntroductionSignatureBackend {
  Future<bool> verify({
    required String signingPublicKey,
    required String payload,
    required String signature,
  });
}

abstract interface class BitMessageProfileVerifier {
  Future<VerifiedBitMessageProfile> verify(BitMessageProfile profile);
}

abstract interface class BitMessageCipherBackend {
  Future<String> encrypt({required String encryptionPublicKey, required String plaintext});
  Future<String> decrypt({required String encryptionPublicKey, required String ciphertext});
}

class VerifiedBitIntroductionEnvelope {
  const VerifiedBitIntroductionEnvelope({
    required this.envelope,
    required this.senderProfile,
    this.replyProfile,
  });

  final SignedBitIntroductionEnvelope envelope;
  final VerifiedBitMessageProfile senderProfile;
  final VerifiedBitMessageProfile? replyProfile;
}

class BitIntroductionEnvelopeCodec {
  const BitIntroductionEnvelopeCodec({
    this.signer,
    this.signatureBackend,
    this.profileVerifier,
    this.cipherBackend,
  });

  final BitIntroductionSigningBackend? signer;
  final BitIntroductionSignatureBackend? signatureBackend;
  final BitMessageProfileVerifier? profileVerifier;
  final BitMessageCipherBackend? cipherBackend;

  Future<SignedBitIntroductionEnvelope> createSigned({
    required String id,
    required BitIntroductionKind kind,
    required VerifiedBitMessageProfile senderProfile,
    required String recipientBitNameHash,
    required DateTime timestamp,
    required String body,
    String? inReplyTo,
    VerifiedBitMessageProfile? replyProfile,
  }) async {
    final backend = signer ?? (throw StateError('A BitIntroductionSigningBackend is required to sign envelopes'));
    if (replyProfile != null && replyProfile.bitNameHash != senderProfile.bitNameHash) {
      throw ArgumentError('A reply profile must belong to the sending BitName');
    }
    final payload = BitIntroductionPayload(
      id: id,
      kind: kind,
      senderBitNameHash: senderProfile.bitNameHash,
      recipientBitNameHash: recipientBitNameHash,
      timestamp: timestamp,
      body: body,
      inReplyTo: inReplyTo,
      replyProfile: replyProfile?.profile,
    );
    final signature = await backend.sign(
      signingPublicKey: senderProfile.signingPublicKey,
      payload: canonicalJsonEncode(payload.toJson()),
    );
    return SignedBitIntroductionEnvelope(payload: payload, signature: signature);
  }

  String encode(SignedBitIntroductionEnvelope envelope) => canonicalJsonEncode(envelope.toJson());

  SignedBitIntroductionEnvelope parse(String encoded) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException catch (error) {
      throw FormatException('Invalid BitIntroduction envelope JSON: ${error.message}');
    }
    if (decoded is! Map) throw const FormatException('BitIntroduction envelope must be an object');
    return SignedBitIntroductionEnvelope.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<VerifiedBitIntroductionEnvelope> parseAndVerify(
    String encoded, {
    required VerifiedBitMessageProfile senderProfile,
  }) => verify(parse(encoded), senderProfile: senderProfile);

  Future<VerifiedBitIntroductionEnvelope> verify(
    SignedBitIntroductionEnvelope envelope, {
    required VerifiedBitMessageProfile senderProfile,
    VerifiedBitMessageProfile? verifiedReplyProfile,
  }) async {
    final backend =
        signatureBackend ?? (throw StateError('A BitIntroductionSignatureBackend is required to verify envelopes'));
    if (envelope.payload.senderBitNameHash != senderProfile.bitNameHash) {
      throw const FormatException('Envelope sender does not match the verified sender profile');
    }
    final valid = await backend.verify(
      signingPublicKey: senderProfile.signingPublicKey,
      payload: envelope.signedPayload,
      signature: envelope.signature,
    );
    if (!valid) throw const FormatException('Invalid BitIntroduction signature');

    VerifiedBitMessageProfile? verifiedReply;
    final reply = envelope.payload.replyProfile;
    if (reply != null) {
      if (reply.bitNameHash != senderProfile.bitNameHash) {
        throw const FormatException('Reply profile does not belong to the sender');
      }
      verifiedReply =
          verifiedReplyProfile ??
          await (profileVerifier ??
                  (throw StateError(
                    'A BitMessageProfileVerifier is required when an envelope carries a reply profile',
                  )))
              .verify(reply);
      if (verifiedReply.bitNameHash != senderProfile.bitNameHash) {
        throw const FormatException('Verified reply profile does not belong to the sender');
      }
      if (canonicalJsonEncode(verifiedReply.profile.toJson()) != canonicalJsonEncode(reply.toJson())) {
        throw const FormatException('Verified reply profile differs from the signed profile');
      }
    }
    return VerifiedBitIntroductionEnvelope(
      envelope: envelope,
      senderProfile: senderProfile,
      replyProfile: verifiedReply,
    );
  }

  Future<BitMessageWire> createWire({
    required SignedBitIntroductionEnvelope envelope,
    required VerifiedBitMessageProfile recipientProfile,
  }) async {
    final backend = cipherBackend ?? (throw StateError('A BitMessageCipherBackend is required to create a wire frame'));
    if (envelope.payload.recipientBitNameHash != recipientProfile.bitNameHash) {
      throw ArgumentError('Envelope recipient does not match recipientProfile');
    }
    return BitMessageWire(
      recipientBitNameHash: recipientProfile.bitNameHash,
      ciphertext: await backend.encrypt(
        encryptionPublicKey: recipientProfile.encryptionPublicKey,
        plaintext: encode(envelope),
      ),
    );
  }

  Future<SignedBitIntroductionEnvelope> openWire({
    required BitMessageWire wire,
    required VerifiedBitMessageProfile recipientProfile,
  }) async {
    final backend = cipherBackend ?? (throw StateError('A BitMessageCipherBackend is required to open a wire frame'));
    if (wire.recipientBitNameHash != recipientProfile.bitNameHash) {
      throw const FormatException('Wire recipient does not match the local BitName');
    }
    final envelope = parse(
      await backend.decrypt(
        encryptionPublicKey: recipientProfile.encryptionPublicKey,
        ciphertext: wire.ciphertext,
      ),
    );
    if (envelope.payload.recipientBitNameHash != wire.recipientBitNameHash) {
      throw const FormatException('Encrypted envelope recipient does not match its outer wire');
    }
    return envelope;
  }
}
