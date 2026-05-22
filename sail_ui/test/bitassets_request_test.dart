import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';

void main() {
  // Regression for #1561: register-bitasset failed because the RPC sends
  // initial_supply both as a top-level proto field AND inside the data_json
  // payload. The sidechain rejects the duplicate. data_json is metadata only —
  // commitment, keys, sockets. Supply must not leak into it.
  test('BitAssetRequest.toJson omits initial_supply (proto carries it)', () {
    final req = BitAssetRequest(
      initialSupply: 1000,
      commitment: 'c0ff33',
      encryptionPubkey: 'pubkey-enc',
      signingPubkey: 'pubkey-sign',
      socketAddrV4: '1.2.3.4:8080',
    );

    final json = req.toJson();

    expect(
      json.containsKey('initial_supply'),
      isFalse,
      reason: 'initial_supply must not be in data_json — it is a top-level proto field',
    );
    expect(json['commitment'], 'c0ff33');
    expect(json['encryption_pubkey'], 'pubkey-enc');
    expect(json['signing_pubkey'], 'pubkey-sign');
    expect(json['socket_addr_v4'], '1.2.3.4:8080');
  });

  test('BitAssetRequest.toJson omits null optional fields', () {
    final req = BitAssetRequest(initialSupply: 42);
    expect(req.toJson(), isEmpty);
  });

  test('BitAssetRequest.fromJson tolerates absent initial_supply', () {
    // Round-trip robustness: server-side metadata blobs no longer carry
    // initial_supply, so deserialising must not throw.
    final parsed = BitAssetRequest.fromJson({'commitment': 'abc'});
    expect(parsed.initialSupply, 0);
    expect(parsed.commitment, 'abc');
  });
}
