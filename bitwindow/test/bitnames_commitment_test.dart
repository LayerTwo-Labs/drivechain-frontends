import 'dart:convert';

import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/models/bitnames_commitment.dart';
import 'package:bitwindow/services/bitnames_bitintroduction_backend.dart';
import 'package:bitwindow/services/bitmessage_server.dart';
import 'package:bitwindow/services/bitmessage_transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thirds/blake3.dart';

const _alice = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _bob = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

void main() {
  group('canonical application commitment', () {
    test('has stable leaf and manifest vectors independent of map order', () {
      final profile = _profile(_alice);
      final manifest = BitNamesCommitmentManifest.forReplyProfile(
        profile,
        network: 'signet',
      );

      expect(
        bitNamesApplicationCommitment(
          namespace: bitIntroductionCommitmentNamespace,
          purpose: bitIntroductionCommitmentPurpose,
          network: 'signet',
          bitNameHash: _alice,
          payload: profile.toCommitmentPayloadJson(),
        ),
        '463e5fbee68c9336d70d4d8cb344be2a5297249e7756697f4c557ef75d32c422',
      );
      expect(
        manifest.commitment,
        '907b33497089067984a15be6dc423e3e6585f9bfcb65b79a74b42101368d3a89',
      );

      final json = manifest.toJson();
      final reordered = <String, dynamic>{
        'applications': json['applications'],
        'bitname_hash': json['bitname_hash'],
        'network': json['network'],
        'version': json['version'],
        'protocol': json['protocol'],
      };
      expect(
        BitNamesCommitmentManifest.parse(reordered).commitment,
        manifest.commitment,
      );
    });

    test('isolates network, identity, namespace, purpose, version, and payload', () {
      final payload = _profile(_alice).toCommitmentPayloadJson();
      String commit({
        String network = 'signet',
        String identity = _alice,
        String namespace = bitIntroductionCommitmentNamespace,
        String purpose = bitIntroductionCommitmentPurpose,
        int version = 1,
        Map<String, dynamic>? data,
      }) => bitNamesApplicationCommitment(
        namespace: namespace,
        purpose: purpose,
        network: network,
        bitNameHash: identity,
        payload: data ?? payload,
        version: version,
      );

      expect(
        {
          commit(),
          commit(network: 'regtest'),
          commit(identity: _bob),
          commit(namespace: 'org.example.other'),
          commit(purpose: 'contact-card'),
          commit(version: 2),
          commit(data: {...payload, 'paymail_fee_sats': 501}),
        },
        hasLength(7),
      );
      expect(bitNamesCommitmentNetwork('signet'), 'bip300:2:bitnames:signet');
      expect(
        bitNamesCommitmentNetwork('bip300:2:bitnames:signet'),
        'bip300:2:bitnames:signet',
      );
    });
  });

  group('activation and compatibility', () {
    test('nested commitment proof data is immutable after profile construction', () {
      final base = _profile(_alice);
      final manifest = BitNamesCommitmentManifest.forReplyProfile(
        base,
        network: 'signet',
      );
      final profile = base.withCommitmentManifest(manifest.toJson());
      final before = bitNamesAuthoritativeProfileCommitment(profile);
      final applications = profile.commitmentManifest!['applications'] as Map;
      final entry = applications[bitIntroductionCommitmentNamespace] as Map;
      final data = entry['data'] as Map;
      final endpoints = data['direct_endpoints'] as List;

      expect(() => applications.clear(), throwsUnsupportedError);
      expect(() => data['paymail_fee_sats'] = 1, throwsUnsupportedError);
      expect(() => endpoints.add('https://attacker.test'), throwsUnsupportedError);
      expect(bitNamesAuthoritativeProfileCommitment(profile), before);
    });

    test('legacy commitments remain verifiable and legacy mode does not migrate', () {
      final profile = _profile(_alice);
      final commitment = bitMessageProfileCommitment(profile);
      final assessment = assessBitMessageProfileCommitment(
        profile: profile,
        onChainCommitment: commitment,
        network: 'signet',
      );
      final plan =
          const BitNamesCommitmentPlanner(
            network: 'signet',
            activation: BitNamesCommitmentActivation.legacyCompatible,
          ).plan(
            profile: _profile(_alice, fee: 501),
            currentCommitment: commitment,
            knownProfile: profile,
          );

      expect(assessment.kind, BitNamesProfileCommitmentKind.legacy);
      expect(plan.kind, BitNamesProfileCommitmentKind.legacy);
      expect(plan.profile.commitmentManifest, isNull);
      expect(plan.migratesLegacy, isFalse);
    });

    test('activation migrates legacy and legacy mode never downgrades namespaced', () {
      final legacy = _profile(_alice);
      const active = BitNamesCommitmentPlanner(
        network: 'signet',
        activation: BitNamesCommitmentActivation.namespacedV1,
      );
      final migration = active.plan(
        profile: _profile(_alice, fee: 501),
        currentCommitment: bitMessageProfileCommitment(legacy),
        knownProfile: legacy,
      );
      final restarted = BitMessageProfile.fromJson(
        jsonDecode(jsonEncode(migration.profile.toJson())) as Map<String, dynamic>,
      );
      final update =
          const BitNamesCommitmentPlanner(
            network: 'signet',
            activation: BitNamesCommitmentActivation.legacyCompatible,
          ).plan(
            profile: _profile(_alice, fee: 502),
            currentCommitment: migration.commitment,
            knownProfile: restarted,
          );

      expect(migration.migratesLegacy, isTrue);
      expect(migration.kind, BitNamesProfileCommitmentKind.namespaced);
      expect(update.kind, BitNamesProfileCommitmentKind.namespaced);
      expect(update.profile.commitmentManifest, isNotNull);
    });

    test('preserves an authenticated commitment from another application', () {
      final profile = _profile(_alice);
      final initial = BitNamesCommitmentManifest.forReplyProfile(
        profile,
        network: 'signet',
      ).toJson();
      (initial['applications'] as Map<String, dynamic>)['org.example.wallet'] = {
        'version': 7,
        'purpose': 'preferences',
        'commitment': 'c' * 64,
        'data': {'color': 'blue'},
      };
      final shared = BitNamesCommitmentManifest.parse(initial);
      final known = profile.withCommitmentManifest(shared.toJson());
      final plan =
          const BitNamesCommitmentPlanner(
            network: 'signet',
            activation: BitNamesCommitmentActivation.namespacedV1,
          ).plan(
            profile: _profile(_alice, fee: 700),
            currentCommitment: shared.commitment,
            knownProfile: known,
          );

      final applications = BitNamesCommitmentManifest.parse(
        plan.profile.commitmentManifest!,
      ).applications;
      expect(plan.preservedApplications, 1);
      expect(applications['org.example.wallet'], {
        'version': 7,
        'purpose': 'preferences',
        'commitment': 'c' * 64,
        'data': {'color': 'blue'},
      });
    });
  });

  group('fail-closed conflict handling', () {
    test('unknown or malformed on-chain commitments cannot be replaced', () {
      final unknown = assessBitMessageProfileCommitment(
        profile: null,
        onChainCommitment: 'd' * 64,
        network: 'signet',
      );
      final malformed = assessBitMessageProfileCommitment(
        profile: _profile(_alice),
        onChainCommitment: 'not-a-hash',
        network: 'signet',
      );
      const planner = BitNamesCommitmentPlanner(
        network: 'signet',
        activation: BitNamesCommitmentActivation.namespacedV1,
      );

      expect(unknown.kind, BitNamesProfileCommitmentKind.unknown);
      expect(unknown.writable, isFalse);
      expect(malformed.kind, BitNamesProfileCommitmentKind.malformed);
      expect(
        () => planner.plan(
          profile: _profile(_alice),
          currentCommitment: 'd' * 64,
        ),
        throwsA(isA<BitNamesCommitmentConflict>()),
      );
    });

    test('authenticated unknown manifest version is preserved but not interpreted', () {
      final manifest = BitNamesCommitmentManifest.forReplyProfile(
        _profile(_alice),
        network: 'signet',
      ).toJson()..['version'] = 2;
      final profile = _profile(_alice).withCommitmentManifest(manifest);
      final assessment = assessBitMessageProfileCommitment(
        profile: profile,
        onChainCommitment: _hashJson(manifest),
        network: 'signet',
      );

      expect(assessment.kind, BitNamesProfileCommitmentKind.unknown);
      expect(assessment.writable, isFalse);
    });

    test('unknown own-namespace shape and tampered leaves cannot be overwritten', () {
      final raw = BitNamesCommitmentManifest.forReplyProfile(
        _profile(_alice),
        network: 'signet',
      ).toJson();
      final unknown = _clone(raw);
      final unknownApps = unknown['applications'] as Map<String, dynamic>;
      (unknownApps[bitIntroductionCommitmentNamespace] as Map<String, dynamic>)['version'] = 2;
      final extendedEntry = _clone(raw);
      final extendedApps = extendedEntry['applications'] as Map<String, dynamic>;
      (extendedApps[bitIntroductionCommitmentNamespace] as Map<String, dynamic>)['future_field'] = true;
      final extendedManifest = _clone(raw)..['future_field'] = true;
      final tampered = _clone(raw);
      final tamperedApps = tampered['applications'] as Map<String, dynamic>;
      final entry = tamperedApps[bitIntroductionCommitmentNamespace] as Map<String, dynamic>;
      (entry['data'] as Map<String, dynamic>)['paymail_fee_sats'] = 999;

      for (final manifest in [
        unknown,
        extendedEntry,
        extendedManifest,
        tampered,
      ]) {
        final profile = _profile(_alice).withCommitmentManifest(manifest);
        final assessment = assessBitMessageProfileCommitment(
          profile: profile,
          onChainCommitment: _hashJson(manifest),
          network: 'signet',
        );
        expect(assessment.verified, isFalse);
        expect(assessment.writable, isFalse);
      }
    });

    test('rejects root replacement, cross-network replay, and identity confusion', () {
      final manifest = BitNamesCommitmentManifest.forReplyProfile(
        _profile(_alice),
        network: 'signet',
      );
      final committed = _profile(_alice).withCommitmentManifest(manifest.toJson());

      expect(
        assessBitMessageProfileCommitment(
          profile: committed,
          onChainCommitment: 'e' * 64,
          network: 'signet',
        ).kind,
        BitNamesProfileCommitmentKind.conflict,
      );
      expect(
        assessBitMessageProfileCommitment(
          profile: committed,
          onChainCommitment: manifest.commitment,
          network: 'regtest',
        ).kind,
        BitNamesProfileCommitmentKind.wrongNetwork,
      );
      expect(
        assessBitMessageProfileCommitment(
          profile: _profile(_bob).withCommitmentManifest(manifest.toJson()),
          onChainCommitment: manifest.commitment,
          network: 'signet',
        ).verified,
        isFalse,
      );
    });

    test('rejects excessive and noncanonical manifest data', () {
      final manifest = BitNamesCommitmentManifest.forReplyProfile(
        _profile(_alice),
        network: 'signet',
      ).toJson();
      final oversized = _clone(manifest);
      final apps = oversized['applications'] as Map<String, dynamic>;
      (apps[bitIntroductionCommitmentNamespace] as Map<String, dynamic>)['padding'] = 'x' * bitNamesCommitmentMaxBytes;
      final floating = _clone(manifest)..['version'] = 1.0;

      expect(
        () => BitNamesCommitmentManifest.parse(oversized),
        throwsFormatException,
      );
      expect(
        () => BitNamesCommitmentManifest.parse(floating),
        throwsFormatException,
      );
      expect(
        () => bitNamesApplicationCommitment(
          namespace: 'org..ambiguous',
          purpose: 'reply profile',
          network: 'signet',
          bitNameHash: _alice,
          payload: const {},
        ),
        throwsFormatException,
      );
    });
  });

  test('legacy and namespaced commit responses round-trip without ambiguity', () {
    final legacy = _profile(_alice);
    final manifest = BitNamesCommitmentManifest.forReplyProfile(
      legacy,
      network: 'signet',
    );
    final namespaced = legacy.withCommitmentManifest(manifest.toJson());

    expect(
      bitNamesProfileFromCommitResponse(bitNamesCommitResponse(legacy)).commitmentManifest,
      isNull,
    );
    final decoded = bitNamesProfileFromCommitResponse(bitNamesCommitResponse(namespaced));
    expect(decoded.toJson(), namespaced.toJson());
    expect(
      bitNamesAuthoritativeProfileCommitment(decoded),
      manifest.commitment,
    );
  });

  test('real loopback server and transport exchange the canonical manifest', () async {
    late BitMessageProfile committed;
    BitMessageWire? received;
    final server = BitMessageServer(
      profileProvider: (hash) => committed,
      onIncomingWire: (wire) => received = wire,
    );
    final endpoint = await server.start();
    final base = BitMessageProfile(
      bitNameHash: _alice,
      signingPublicKey: 'signing',
      encryptionPublicKey: 'encryption',
      directEndpoints: [endpoint.resolve('bitname/$_alice/')],
      paymailFeeSats: 500,
    );
    final manifest = BitNamesCommitmentManifest.forReplyProfile(
      base,
      network: 'signet',
    );
    committed = base.withCommitmentManifest(manifest.toJson());
    final verified = VerifiedBitMessageProfile.verified(
      profile: committed,
      onChainCommitment: manifest.commitment,
      verificationReference: 'loopback',
      commitmentVerifier: (profile, commitment) => assessBitMessageProfileCommitment(
        profile: profile,
        onChainCommitment: commitment,
        network: 'signet',
      ).verified,
    );
    final transport = BitMessageTransport(
      directDialer: DirectBitMessageHttpDialer(),
    );
    final wire = BitMessageWire(
      recipientBitNameHash: _alice,
      ciphertext: 'encrypted',
    );

    try {
      final result = await transport.send(wire, verified);
      expect(result.transport, BitMessageTransportType.direct);
      expect(received?.toJson(), wire.toJson());
    } finally {
      transport.close();
      await server.stop();
    }
  });

  test('transport rejects a namespaced proof sent as an ambiguous legacy profile', () async {
    final base = _profile(_alice);
    final manifest = BitNamesCommitmentManifest.forReplyProfile(
      base,
      network: 'signet',
    );
    final committed = base.withCommitmentManifest(manifest.toJson());
    final dialer = _CommitDialer(jsonEncode(committed.toJson()));
    final transport = BitMessageTransport(directDialer: dialer);
    final verified = VerifiedBitMessageProfile.verified(
      profile: committed,
      onChainCommitment: manifest.commitment,
      verificationReference: 'test',
      commitmentVerifier: (_, commitment) => commitment == manifest.commitment,
    );

    await expectLater(
      transport.send(
        BitMessageWire(
          recipientBitNameHash: _alice,
          ciphertext: 'encrypted',
        ),
        verified,
      ),
      throwsA(isA<BitMessageTransportException>()),
    );
    expect(dialer.postCalls, 0);
    transport.close();
  });

  test('current and historical backend verification accepts both formats', () {
    final legacy = _profile(_alice);
    final manifest = BitNamesCommitmentManifest.forReplyProfile(
      legacy,
      network: 'signet',
    );
    final namespaced = legacy.withCommitmentManifest(manifest.toJson());
    final verifier = BitnamesBitMessageProfileVerifier(
      MockBitnamesRPC(),
      commitmentNetwork: 'signet',
    );
    BitNameData data(String commitment) => BitNameData(
      commitment: commitment,
      signingPubkey: legacy.signingPublicKey,
      encryptionPubkey: legacy.encryptionPublicKey,
      paymailFeeSats: legacy.paymailFeeSats,
    );

    expect(
      verifier.verifyAt(legacy, data(bitMessageProfileCommitment(legacy)), 'current:outpoint').verificationReference,
      'current:outpoint',
    );
    expect(
      verifier.verifyAt(namespaced, data(manifest.commitment), 'historical:block:4').verificationReference,
      'historical:block:4',
    );
    expect(
      () => BitnamesBitMessageProfileVerifier(
        MockBitnamesRPC(),
        commitmentNetwork: 'regtest',
      ).verifyAt(namespaced, data(manifest.commitment), 'wrong-network'),
      throwsStateError,
    );
  });
}

BitMessageProfile _profile(String hash, {int fee = 500}) => BitMessageProfile(
  bitNameHash: hash,
  signingPublicKey: 'signing-$hash',
  encryptionPublicKey: 'encryption-$hash',
  directEndpoints: [Uri.parse('https://example.test/bitname/$hash/')],
  torEndpoints: [
    Uri.parse(
      'http://abcdefghijklmnopqrstuvwxyz234567abcdefghijklmnopqrstuvwxyz23.onion/bitname/$hash/',
    ),
  ],
  paymailFeeSats: fee,
);

String _hashJson(Map<String, dynamic> json) => blake3Hex(utf8.encode(canonicalJsonEncode(json)));

Map<String, dynamic> _clone(Map<String, dynamic> json) => Map<String, dynamic>.from(
  jsonDecode(jsonEncode(json)) as Map,
);

class _CommitDialer implements BitMessageHttpDialer {
  _CommitDialer(this.body);

  final String body;
  int postCalls = 0;

  @override
  Future<BitMessageHttpResponse> get(
    Uri uri, {
    required Duration timeout,
  }) async => BitMessageHttpResponse(statusCode: 200, body: body);

  @override
  Future<BitMessageHttpResponse> postJson(
    Uri uri, {
    required String body,
    required Duration timeout,
  }) async {
    postCalls++;
    return const BitMessageHttpResponse(statusCode: 202, body: '{}');
  }

  @override
  void close() {}
}
