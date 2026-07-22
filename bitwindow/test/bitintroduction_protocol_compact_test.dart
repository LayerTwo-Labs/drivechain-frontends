import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/services/bitintroduction_codec.dart';
import 'package:bitwindow/services/bitmessage_server.dart';
import 'package:bitwindow/services/bitmessage_transport.dart';
import 'package:flutter_test/flutter_test.dart';

final _alice = List.filled(64, 'a').join(), _bob = List.filled(64, 'b').join();

void main() {
  test('canonical signature rejects payload tampering', () async {
    final signer = _SignatureBackend();
    final codec = BitIntroductionEnvelopeCodec(signer: signer, signatureBackend: signer);
    final signed = await codec.createSigned(
      id: 'intro-1',
      kind: BitIntroductionKind.introduction,
      senderProfile: _verified(_profile(_alice)),
      recipientBitNameHash: _bob,
      timestamp: DateTime.utc(2026),
      body: 'hello',
    );
    final tampered = codec.parse(
      codec.encode(signed).replaceFirst('"body":"hello"', '"body":"changed"'),
    );
    await expectLater(
      codec.verify(tampered, senderProfile: _verified(_profile(_alice))),
      throwsFormatException,
    );
  });

  test('verified profile requires its exact chain commitment', () {
    final profile = _profile(_alice, fee: 7);
    expect(() => _verified(profile, '0' * 64), throwsArgumentError);
    expect(_verified(profile).paymailFeeSats, 7);
  });

  test('torOnly never attempts a direct endpoint', () async {
    final direct = _CountingDialer();
    final transport = BitMessageTransport(directDialer: direct);
    await expectLater(
      transport.send(
        BitMessageWire(recipientBitNameHash: _bob, ciphertext: 'cipher'),
        _verified(_profile(_bob, direct: Uri.parse('http://127.0.0.1:9/'))),
        torOnly: true,
      ),
      throwsA(isA<BitMessageTransportException>()),
    );
    expect(direct.calls, 0);
  });

  test('real local multi-identity server verifies and accepts a wire', () async {
    BitMessageProfile? served;
    BitMessageWire? received;
    final server = BitMessageServer(
      profileProvider: (hash) => hash == _bob ? served : null,
      onIncomingWire: (wire) => received = wire,
    );
    final root = await server.start();
    addTearDown(server.stop);
    served = _profile(_bob, direct: root.resolve('bitname/$_bob/'));
    final transport = BitMessageTransport(directDialer: DirectBitMessageHttpDialer());
    addTearDown(transport.close);
    final wire = BitMessageWire(recipientBitNameHash: _bob, ciphertext: 'encrypted');
    final result = await transport.send(wire, _verified(served));
    expect(result.transport, BitMessageTransportType.direct);
    expect(received?.ciphertext, 'encrypted');
  });
}

BitMessageProfile _profile(String hash, {Uri? direct, int? fee}) => BitMessageProfile(
  bitNameHash: hash,
  signingPublicKey: 'sign-$hash',
  encryptionPublicKey: 'encrypt-$hash',
  directEndpoints: direct == null ? const [] : [direct],
  paymailFeeSats: fee,
);

VerifiedBitMessageProfile _verified(BitMessageProfile profile, [String? commitment]) =>
    VerifiedBitMessageProfile.verified(
      profile: profile,
      onChainCommitment: commitment ?? bitMessageProfileCommitment(profile),
      verificationReference: 'block:1',
    );

class _SignatureBackend implements BitIntroductionSigningBackend, BitIntroductionSignatureBackend {
  @override
  Future<String> sign({required String signingPublicKey, required String payload}) async =>
      '$signingPublicKey:$payload';

  @override
  Future<bool> verify({
    required String signingPublicKey,
    required String payload,
    required String signature,
  }) async => signature == '$signingPublicKey:$payload';
}

class _CountingDialer implements BitMessageHttpDialer {
  int calls = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    calls++;
    throw StateError('unexpected request');
  }
}
