import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/services/bitmessage_transport.dart';
import 'package:flutter_test/flutter_test.dart';

class _Dialer implements BitMessageHttpDialer {
  _Dialer(this.profile, {this.fail = false});
  final BitMessageProfile profile;
  final bool fail;
  int requests = 0;
  @override
  Future<BitMessageHttpResponse> get(Uri uri, {required Duration timeout}) async {
    requests++;
    if (fail) {
      throw StateError('Tor is unavailable');
    }
    return BitMessageHttpResponse(statusCode: 200, body: canonicalJsonEncode(profile.toJson()));
  }

  @override
  Future<BitMessageHttpResponse> postJson(Uri uri, {required String body, required Duration timeout}) async {
    requests++;
    return const BitMessageHttpResponse(statusCode: 202, body: '{}');
  }

  @override
  void close() {}
}

void main() {
  test('Tor-only delivery never falls back to a direct endpoint', () async {
    final hash = 'a' * 64;
    final profile = BitMessageProfile(
      bitNameHash: hash,
      signingPublicKey: 'signing-key',
      encryptionPublicKey: 'encryption-key',
      directEndpoints: [Uri.parse('http://127.0.0.1/bitname/$hash/')],
      torEndpoints: [Uri.parse('http://${'a' * 56}.onion/bitname/$hash/')],
    );
    final verified = VerifiedBitMessageProfile.verified(
      profile: profile,
      onChainCommitment: bitMessageProfileCommitment(profile),
      verificationReference: 'test-block',
    );
    final direct = _Dialer(profile);
    final tor = _Dialer(profile, fail: true);
    final transport = BitMessageTransport(directDialer: direct, torDialer: tor);
    final wire = BitMessageWire(recipientBitNameHash: hash, ciphertext: 'encrypted');
    await expectLater(transport.send(wire, verified, torOnly: true), throwsA(isA<BitMessageTransportException>()));
    expect(tor.requests, 1);
    expect(direct.requests, 0);
    final noTor = BitMessageTransport(directDialer: direct);
    await expectLater(noTor.send(wire, verified, torOnly: true), throwsA(isA<BitMessageTransportException>()));
    expect(direct.requests, 0);
  });
}
