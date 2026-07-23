import 'dart:convert';

import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:thirds/blake3.dart';

const bitNamesCommitmentManifestProtocol = 'bitnames-commitment-manifest';
const bitNamesCommitmentManifestVersion = 1;
const bitNamesApplicationCommitmentProtocol = 'bitnames-application-commitment';
const bitIntroductionCommitmentNamespace = 'org.layertwolabs.bitintroduction';
const bitIntroductionCommitmentPurpose = 'reply-profile';
const bitIntroductionCommitmentVersion = 1;
const bitNamesCommitmentChain = 'bip300:2:bitnames';
const bitNamesCommitmentMaxBytes = 16 * 1024;

enum BitNamesCommitmentActivation {
  legacyCompatible,
  namespacedV1,
}

enum BitNamesProfileCommitmentKind {
  empty,
  legacy,
  namespaced,
  unknown,
  malformed,
  wrongNetwork,
  conflict,
}

class BitNamesCommitmentAssessment {
  const BitNamesCommitmentAssessment(
    this.kind,
    this.summary,
    this.details, {
    this.manifest,
  });

  final BitNamesProfileCommitmentKind kind;
  final String summary;
  final String details;
  final BitNamesCommitmentManifest? manifest;

  bool get verified => kind == BitNamesProfileCommitmentKind.legacy || kind == BitNamesProfileCommitmentKind.namespaced;
  bool get writable => kind == BitNamesProfileCommitmentKind.empty || verified;
}

class BitNamesCommitmentConflict implements Exception {
  const BitNamesCommitmentConflict(this.message);
  final String message;

  @override
  String toString() => message;
}

class BitNamesCommitmentManifest {
  BitNamesCommitmentManifest._(this._json);

  final Map<String, dynamic> _json;

  String get network => _json['network'] as String;
  String get bitNameHash => _json['bitname_hash'] as String;
  Map<String, dynamic> get applications => _cloneObject(_json['applications'] as Map);
  Map<String, dynamic> toJson() => _cloneObject(_json);
  String get commitment => blake3Hex(utf8.encode(canonicalJsonEncode(_json)));

  factory BitNamesCommitmentManifest.parse(
    Map<String, dynamic> source,
  ) {
    final json = _cloneObject(source);
    _boundedCanonical(json);
    if (json['protocol'] != bitNamesCommitmentManifestProtocol) {
      throw const FormatException(
        'unsupported BitNames commitment protocol',
      );
    }
    if (json['version'] != bitNamesCommitmentManifestVersion) {
      throw const FormatException(
        'unsupported BitNames commitment manifest version',
      );
    }
    if (!_hasExactKeys(json, const {
      'protocol',
      'version',
      'network',
      'bitname_hash',
      'applications',
    })) {
      throw const FormatException(
        'BitNames commitment manifest v1 has unknown or missing fields',
      );
    }
    final network = json['network'];
    if (network is! String || bitNamesCommitmentNetwork(network) != network) {
      throw const FormatException(
        'invalid BitNames commitment network',
      );
    }
    final bitNameHash = json['bitname_hash'];
    if (bitNameHash is! String || !_hashPattern.hasMatch(bitNameHash)) {
      throw const FormatException(
        'invalid BitName commitment identity',
      );
    }
    final applications = json['applications'];
    if (applications is! Map || applications.isEmpty || applications.length > 32) {
      throw const FormatException(
        'BitNames commitment applications must contain 1 to 32 entries',
      );
    }
    for (final entry in applications.entries) {
      if (entry.key is! String || !_namespacePattern.hasMatch(entry.key as String)) {
        throw const FormatException(
          'invalid BitNames application namespace',
        );
      }
      if (entry.value is! Map) {
        throw const FormatException(
          'BitNames application commitment must be an object',
        );
      }
      final application = Map<String, dynamic>.from(
        entry.value as Map,
      );
      if (application['version'] is! int ||
          (application['version'] as int) < 1 ||
          (application['version'] as int) > 0x7fffffff ||
          application['purpose'] is! String ||
          !_purposePattern.hasMatch(application['purpose'] as String) ||
          application['commitment'] is! String ||
          !_hashPattern.hasMatch(
            application['commitment'] as String,
          ) ||
          application['data'] is! Map) {
        throw const FormatException(
          'invalid BitNames application commitment entry',
        );
      }
    }
    return BitNamesCommitmentManifest._(json);
  }

  factory BitNamesCommitmentManifest.forReplyProfile(
    BitMessageProfile profile, {
    required String network,
    BitNamesCommitmentManifest? base,
  }) {
    final scope = bitNamesCommitmentNetwork(network);
    if (base != null) {
      if (base.network != scope || base.bitNameHash != profile.bitNameHash) {
        throw const BitNamesCommitmentConflict(
          'The existing commitment manifest belongs to another network or BitName',
        );
      }
      final existing = base.applications[bitIntroductionCommitmentNamespace];
      if (existing is Map &&
          (existing['version'] != bitIntroductionCommitmentVersion ||
              existing['purpose'] != bitIntroductionCommitmentPurpose)) {
        throw const BitNamesCommitmentConflict(
          'The BitIntroduction namespace uses an unknown version and was preserved',
        );
      }
    }
    final payload = profile.toCommitmentPayloadJson();
    final applications = base?.applications ?? <String, dynamic>{};
    applications[bitIntroductionCommitmentNamespace] = {
      'version': bitIntroductionCommitmentVersion,
      'purpose': bitIntroductionCommitmentPurpose,
      'commitment': bitNamesApplicationCommitment(
        namespace: bitIntroductionCommitmentNamespace,
        purpose: bitIntroductionCommitmentPurpose,
        network: scope,
        bitNameHash: profile.bitNameHash,
        payload: payload,
      ),
      'data': payload,
    };
    return BitNamesCommitmentManifest.parse({
      'protocol': bitNamesCommitmentManifestProtocol,
      'version': bitNamesCommitmentManifestVersion,
      'network': scope,
      'bitname_hash': profile.bitNameHash,
      'applications': applications,
    });
  }

  BitMessageProfile replyProfile() {
    final raw = applications[bitIntroductionCommitmentNamespace];
    if (raw is! Map) {
      throw const FormatException(
        'manifest has no BitIntroduction commitment',
      );
    }
    final entry = Map<String, dynamic>.from(raw);
    if (entry['version'] != bitIntroductionCommitmentVersion || entry['purpose'] != bitIntroductionCommitmentPurpose) {
      throw const FormatException(
        'unsupported BitIntroduction commitment version or purpose',
      );
    }
    if (!_hasExactKeys(entry, const {
      'version',
      'purpose',
      'commitment',
      'data',
    })) {
      throw const FormatException(
        'BitIntroduction commitment v1 has unknown or missing fields',
      );
    }
    final data = entry['data'];
    if (data is! Map) {
      throw const FormatException(
        'BitIntroduction commitment data is malformed',
      );
    }
    final profile = BitMessageProfile.fromJson(
      Map<String, dynamic>.from(data),
    );
    if (profile.bitNameHash != bitNameHash) {
      throw const FormatException(
        'BitIntroduction profile belongs to another BitName',
      );
    }
    final expected = bitNamesApplicationCommitment(
      namespace: bitIntroductionCommitmentNamespace,
      purpose: bitIntroductionCommitmentPurpose,
      network: network,
      bitNameHash: bitNameHash,
      payload: profile.toCommitmentPayloadJson(),
    );
    if (entry['commitment'] != expected ||
        canonicalJsonEncode(data) !=
            canonicalJsonEncode(
              profile.toCommitmentPayloadJson(),
            )) {
      throw const FormatException(
        'BitIntroduction commitment data does not match its leaf',
      );
    }
    return profile.withCommitmentManifest(toJson());
  }
}

class BitNamesCommitmentWritePlan {
  const BitNamesCommitmentWritePlan({
    required this.profile,
    required this.commitment,
    required this.kind,
    required this.migratesLegacy,
    required this.preservedApplications,
  });

  final BitMessageProfile profile;
  final String commitment;
  final BitNamesProfileCommitmentKind kind;
  final bool migratesLegacy;
  final int preservedApplications;

  String get summary => switch (kind) {
    BitNamesProfileCommitmentKind.namespaced =>
      migratesLegacy
          ? 'Migrating the legacy reply profile into the namespaced v1 manifest'
          : 'Publishing a namespaced v1 reply-profile commitment',
    _ => 'Publishing a legacy-compatible reply-profile commitment',
  };
}

class BitNamesCommitmentPlanner {
  const BitNamesCommitmentPlanner({
    required this.network,
    required this.activation,
  });

  final String network;
  final BitNamesCommitmentActivation activation;

  BitNamesCommitmentAssessment assess({
    required String? onChainCommitment,
    BitMessageProfile? knownProfile,
  }) => assessBitMessageProfileCommitment(
    profile: knownProfile,
    onChainCommitment: onChainCommitment,
    network: network,
  );

  BitNamesCommitmentWritePlan plan({
    required BitMessageProfile profile,
    required String? currentCommitment,
    BitMessageProfile? knownProfile,
  }) {
    final baseProfile = profile.withCommitmentManifest(null);
    final assessment = assess(
      onChainCommitment: currentCommitment,
      knownProfile: knownProfile ?? baseProfile,
    );
    if (!assessment.writable) {
      throw BitNamesCommitmentConflict(assessment.details);
    }
    final existingNamespaced = assessment.kind == BitNamesProfileCommitmentKind.namespaced;
    final useNamespaced = existingNamespaced || activation == BitNamesCommitmentActivation.namespacedV1;
    if (!useNamespaced) {
      return BitNamesCommitmentWritePlan(
        profile: baseProfile,
        commitment: bitMessageProfileCommitment(baseProfile),
        kind: BitNamesProfileCommitmentKind.legacy,
        migratesLegacy: false,
        preservedApplications: 0,
      );
    }
    final manifest = BitNamesCommitmentManifest.forReplyProfile(
      baseProfile,
      network: network,
      base: assessment.manifest,
    );
    final committedProfile = baseProfile.withCommitmentManifest(manifest.toJson());
    return BitNamesCommitmentWritePlan(
      profile: committedProfile,
      commitment: manifest.commitment,
      kind: BitNamesProfileCommitmentKind.namespaced,
      migratesLegacy: assessment.kind == BitNamesProfileCommitmentKind.legacy,
      preservedApplications: manifest.applications.length - 1,
    );
  }
}

BitNamesCommitmentAssessment assessBitMessageProfileCommitment({
  required BitMessageProfile? profile,
  required String? onChainCommitment,
  required String network,
}) {
  if (onChainCommitment == null) {
    return const BitNamesCommitmentAssessment(
      BitNamesProfileCommitmentKind.empty,
      'No application commitment is set',
      'BitWindow can publish without replacing another application.',
    );
  }
  final commitment = onChainCommitment.trim().toLowerCase();
  if (!_hashPattern.hasMatch(commitment)) {
    return const BitNamesCommitmentAssessment(
      BitNamesProfileCommitmentKind.malformed,
      'The on-chain commitment is malformed',
      'BitWindow will not replace a malformed or ambiguous commitment.',
    );
  }
  if (profile == null) {
    return const BitNamesCommitmentAssessment(
      BitNamesProfileCommitmentKind.unknown,
      'Another or unknown application commitment is present',
      'BitWindow cannot authenticate its contents, so publishing is blocked to preserve it.',
    );
  }
  final manifestJson = profile.commitmentManifest;
  if (manifestJson == null) {
    if (bitMessageProfileCommitment(profile) == commitment) {
      return const BitNamesCommitmentAssessment(
        BitNamesProfileCommitmentKind.legacy,
        'Legacy BitIntroduction reply profile',
        'This commitment is recognized and remains verifiable.',
      );
    }
    return const BitNamesCommitmentAssessment(
      BitNamesProfileCommitmentKind.conflict,
      'The commitment was replaced',
      'The saved reply profile no longer matches on-chain state; BitWindow will not overwrite it.',
    );
  }

  String manifestCommitment;
  try {
    _boundedCanonical(manifestJson);
    manifestCommitment = blake3Hex(
      utf8.encode(canonicalJsonEncode(manifestJson)),
    );
  } catch (_) {
    return const BitNamesCommitmentAssessment(
      BitNamesProfileCommitmentKind.malformed,
      'The saved commitment proof is malformed',
      'BitWindow cannot authenticate this manifest and will not replace the on-chain commitment.',
    );
  }
  if (manifestCommitment != commitment) {
    return const BitNamesCommitmentAssessment(
      BitNamesProfileCommitmentKind.conflict,
      'The commitment was replaced',
      'The saved manifest no longer matches on-chain state; BitWindow will not overwrite it.',
    );
  }
  if (manifestJson['protocol'] != bitNamesCommitmentManifestProtocol ||
      manifestJson['version'] != bitNamesCommitmentManifestVersion) {
    return const BitNamesCommitmentAssessment(
      BitNamesProfileCommitmentKind.unknown,
      'Unknown commitment manifest version',
      'The authenticated bytes are preserved, but this BitWindow version will not interpret or overwrite them.',
    );
  }
  try {
    final manifest = BitNamesCommitmentManifest.parse(manifestJson);
    if (manifest.network != bitNamesCommitmentNetwork(network)) {
      return const BitNamesCommitmentAssessment(
        BitNamesProfileCommitmentKind.wrongNetwork,
        'Reply profile belongs to another network',
        'Cross-network commitment replay was rejected.',
      );
    }
    final committed = manifest.replyProfile();
    if (canonicalJsonEncode(
          committed.toCommitmentPayloadJson(),
        ) !=
        canonicalJsonEncode(
          profile.toCommitmentPayloadJson(),
        )) {
      return const BitNamesCommitmentAssessment(
        BitNamesProfileCommitmentKind.conflict,
        'Reply-profile commitment data differs',
        'The manifest is authenticated but does not describe the supplied reply profile.',
      );
    }
    return BitNamesCommitmentAssessment(
      BitNamesProfileCommitmentKind.namespaced,
      'Namespaced BitIntroduction v1 commitment',
      'The manifest is authenticated for ${manifest.network} and preserves ${manifest.applications.length - 1} other application namespace(s).',
      manifest: manifest,
    );
  } catch (_) {
    return const BitNamesCommitmentAssessment(
      BitNamesProfileCommitmentKind.malformed,
      'The commitment manifest is invalid',
      'BitWindow will not interpret or replace invalid authenticated application data.',
    );
  }
}

String bitNamesApplicationCommitment({
  required String namespace,
  required String purpose,
  required String network,
  required String bitNameHash,
  required Map<String, dynamic> payload,
  int version = bitIntroductionCommitmentVersion,
}) {
  if (!_namespacePattern.hasMatch(namespace) ||
      !_purposePattern.hasMatch(purpose) ||
      !_hashPattern.hasMatch(bitNameHash) ||
      version < 1 ||
      version > 0x7fffffff) {
    throw const FormatException(
      'invalid application commitment domain',
    );
  }
  final preimage = {
    'protocol': bitNamesApplicationCommitmentProtocol,
    'version': version,
    'network': bitNamesCommitmentNetwork(network),
    'bitname_hash': bitNameHash,
    'namespace': namespace,
    'purpose': purpose,
    'payload': _cloneObject(payload),
  };
  _boundedCanonical(preimage);
  return blake3Hex(
    utf8.encode(canonicalJsonEncode(preimage)),
  );
}

String bitNamesCommitmentNetwork(String network) {
  final normalized = network.trim().toLowerCase();
  final full = normalized.startsWith('$bitNamesCommitmentChain:') ? normalized : '$bitNamesCommitmentChain:$normalized';
  final suffix = full.substring(
    bitNamesCommitmentChain.length + 1,
  );
  if (!_networkPattern.hasMatch(suffix)) {
    throw const FormatException(
      'invalid BitNames commitment network',
    );
  }
  return full;
}

String bitNamesAuthoritativeProfileCommitment(
  BitMessageProfile profile,
) {
  final manifest = profile.commitmentManifest;
  return manifest == null
      ? bitMessageProfileCommitment(profile)
      : BitNamesCommitmentManifest.parse(
          manifest,
        ).commitment;
}

Map<String, dynamic> bitNamesCommitResponse(
  BitMessageProfile profile,
) {
  final manifest = profile.commitmentManifest;
  return manifest == null
      ? profile.toCommitmentPayloadJson()
      : BitNamesCommitmentManifest.parse(
          manifest,
        ).toJson();
}

BitMessageProfile bitNamesProfileFromCommitResponse(
  Map<String, dynamic> response,
) {
  if (response['protocol'] == bitNamesCommitmentManifestProtocol) {
    return BitNamesCommitmentManifest.parse(
      response,
    ).replyProfile();
  }
  final profile = BitMessageProfile.fromJson(response);
  if (profile.commitmentManifest != null) {
    throw const FormatException(
      'legacy profile response cannot carry a manifest wrapper',
    );
  }
  return profile;
}

final _hashPattern = RegExp(r'^[0-9a-f]{64}$');
final _namespacePattern = RegExp(
  r'^(?=.{3,127}$)[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$',
);
final _purposePattern = RegExp(
  r'^[a-z0-9](?:[a-z0-9._-]{0,62}[a-z0-9])?$',
);
final _networkPattern = RegExp(
  r'^[a-z0-9](?:[a-z0-9._-]{0,62}[a-z0-9])?$',
);

bool _hasExactKeys(Map value, Set<String> keys) => value.length == keys.length && value.keys.every(keys.contains);

Map<String, dynamic> _cloneObject(Map source) {
  try {
    return Map<String, dynamic>.from(
      jsonDecode(jsonEncode(source)) as Map,
    );
  } catch (_) {
    throw const FormatException(
      'commitment data must be a JSON object',
    );
  }
}

void _boundedCanonical(Map<String, dynamic> value) {
  late final List<int> encoded;
  try {
    encoded = utf8.encode(canonicalJsonEncode(value));
  } on ArgumentError {
    throw const FormatException(
      'commitment data must use canonical JSON values',
    );
  }
  if (encoded.length > bitNamesCommitmentMaxBytes) {
    throw const FormatException(
      'BitNames commitment manifest exceeds 16 KiB',
    );
  }
}
