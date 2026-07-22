import 'dart:convert';
import 'package:thirds/blake3.dart';

const bitIntroductionProtocol = 'bitintroduction';
const bitIntroductionProtocolVersion = 1;

enum BitIntroductionKind {
  introduction('introduction'),
  acceptance('acceptance'),
  message('message');

  const BitIntroductionKind(this.wireName);
  final String wireName;
  static BitIntroductionKind fromWireName(String value) {
    for (final kind in values) {
      if (kind.wireName == value) return kind;
    }
    throw FormatException('Unsupported BitIntroduction kind: $value');
  }
}

class BitMessageProfile {
  BitMessageProfile({
    required String bitNameHash,
    required this.signingPublicKey,
    required this.encryptionPublicKey,
    Iterable<Uri> directEndpoints = const [],
    Iterable<Uri> torEndpoints = const [],
    this.paymailFeeSats,
  }) : bitNameHash = _bitNameHash(bitNameHash),
       directEndpoints = List.unmodifiable(_endpoints(directEndpoints, false)),
       torEndpoints = List.unmodifiable(_endpoints(torEndpoints, true)) {
    _notEmpty(signingPublicKey, 'signingPublicKey');
    _notEmpty(encryptionPublicKey, 'encryptionPublicKey');
    if (paymailFeeSats != null && paymailFeeSats! < 0) {
      throw ArgumentError.value(paymailFeeSats, 'paymailFeeSats', 'must be non-negative');
    }
  }

  final String bitNameHash;
  final String signingPublicKey;
  final String encryptionPublicKey;
  final List<Uri> directEndpoints;
  final List<Uri> torEndpoints;
  final int? paymailFeeSats;

  factory BitMessageProfile.fromJson(Map<String, dynamic> json) => BitMessageProfile(
    bitNameHash: _string(json, 'bitname_hash'),
    signingPublicKey: _string(json, 'signing_public_key'),
    encryptionPublicKey: _string(json, 'encryption_public_key'),
    directEndpoints: _uriList(json['direct_endpoints'], 'direct_endpoints'),
    torEndpoints: _uriList(json['tor_endpoints'], 'tor_endpoints'),
    paymailFeeSats: _optionalInt(json, 'paymail_fee_sats'),
  );

  Map<String, dynamic> toJson() => {
    'bitname_hash': bitNameHash,
    'signing_public_key': signingPublicKey,
    'encryption_public_key': encryptionPublicKey,
    'direct_endpoints': directEndpoints.map((uri) => '$uri').toList(),
    'tor_endpoints': torEndpoints.map((uri) => '$uri').toList(),
    if (paymailFeeSats != null) 'paymail_fee_sats': paymailFeeSats,
  };
}

class VerifiedBitMessageProfile {
  VerifiedBitMessageProfile.verified({
    required this.profile,
    required String onChainCommitment,
    required this.verificationReference,
  }) : onChainCommitment = onChainCommitment.trim().toLowerCase() {
    if (!_hashPattern.hasMatch(this.onChainCommitment)) {
      throw ArgumentError.value(onChainCommitment, 'onChainCommitment', 'must be a 32-byte hexadecimal hash');
    }
    if (bitMessageProfileCommitment(profile) != this.onChainCommitment) {
      throw ArgumentError.value(onChainCommitment, 'onChainCommitment', 'does not commit to the canonical profile');
    }
    _notEmpty(verificationReference, 'verificationReference');
  }

  final BitMessageProfile profile;
  final String onChainCommitment;
  final String verificationReference;
  String get bitNameHash => profile.bitNameHash;
  String get bitNameCommit => onChainCommitment;
  String get signingPublicKey => profile.signingPublicKey;
  String get encryptionPublicKey => profile.encryptionPublicKey;
  List<Uri> get directEndpoints => profile.directEndpoints;
  List<Uri> get torEndpoints => profile.torEndpoints;
  int? get paymailFeeSats => profile.paymailFeeSats;
}

String bitMessageProfileCommitment(BitMessageProfile profile) =>
    blake3Hex(utf8.encode(canonicalJsonEncode(profile.toJson())));

class BitIntroductionPayload {
  BitIntroductionPayload({
    this.version = bitIntroductionProtocolVersion,
    required this.id,
    required this.kind,
    required String senderBitNameHash,
    required String recipientBitNameHash,
    required DateTime timestamp,
    required this.body,
    this.inReplyTo,
    this.replyProfile,
  }) : senderBitNameHash = _bitNameHash(senderBitNameHash),
       recipientBitNameHash = _bitNameHash(recipientBitNameHash),
       timestamp = timestamp.toUtc() {
    if (version != bitIntroductionProtocolVersion) {
      throw ArgumentError.value(version, 'version', 'unsupported protocol version');
    }
    _boundedId(id, 'id');
    if (inReplyTo != null) _boundedId(inReplyTo!, 'inReplyTo');
    if (kind == BitIntroductionKind.acceptance && inReplyTo == null) {
      throw ArgumentError('Acceptance messages must reference the introduction ID');
    }
    if (replyProfile != null && replyProfile!.bitNameHash != this.senderBitNameHash) {
      throw ArgumentError('replyProfile must belong to senderBitNameHash');
    }
  }

  final int version;
  final String id;
  final BitIntroductionKind kind;
  final String senderBitNameHash;
  final String recipientBitNameHash;
  final DateTime timestamp;
  final String body;
  final String? inReplyTo;
  final BitMessageProfile? replyProfile;

  factory BitIntroductionPayload.fromJson(Map<String, dynamic> json) {
    final protocol = _string(json, 'protocol');
    if (protocol != bitIntroductionProtocol) throw FormatException('Unsupported protocol: $protocol');
    final reply = json['reply_profile'];
    if (reply != null && reply is! Map) throw const FormatException('reply_profile must be an object');
    final parent = json['in_reply_to'];
    if (parent != null && parent is! String) throw const FormatException('in_reply_to must be a string');
    return BitIntroductionPayload(
      version: _integer(json, 'version'),
      id: _string(json, 'id'),
      kind: BitIntroductionKind.fromWireName(_string(json, 'kind')),
      senderBitNameHash: _string(json, 'sender_bitname_hash'),
      recipientBitNameHash: _string(json, 'recipient_bitname_hash'),
      timestamp: DateTime.fromMillisecondsSinceEpoch(_integer(json, 'timestamp_ms'), isUtc: true),
      body: _string(json, 'body', empty: true),
      inReplyTo: parent as String?,
      replyProfile: reply == null ? null : BitMessageProfile.fromJson(Map<String, dynamic>.from(reply)),
    );
  }

  Map<String, dynamic> toJson() => {
    'protocol': bitIntroductionProtocol,
    'version': version,
    'id': id,
    'kind': kind.wireName,
    'sender_bitname_hash': senderBitNameHash,
    'recipient_bitname_hash': recipientBitNameHash,
    'timestamp_ms': timestamp.millisecondsSinceEpoch,
    'body': body,
    if (inReplyTo != null) 'in_reply_to': inReplyTo,
    if (replyProfile != null) 'reply_profile': replyProfile!.toJson(),
  };
}

class SignedBitIntroductionEnvelope {
  SignedBitIntroductionEnvelope({required this.payload, required this.signature}) {
    _notEmpty(signature, 'signature');
  }

  final BitIntroductionPayload payload;
  final String signature;
  String get signedPayload => canonicalJsonEncode(payload.toJson());

  factory SignedBitIntroductionEnvelope.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    if (payload is! Map) throw const FormatException('payload must be an object');
    return SignedBitIntroductionEnvelope(
      payload: BitIntroductionPayload.fromJson(Map<String, dynamic>.from(payload)),
      signature: _string(json, 'signature'),
    );
  }

  Map<String, dynamic> toJson() => {'payload': payload.toJson(), 'signature': signature};
}

class BitMessageWire {
  BitMessageWire({required String recipientBitNameHash, required this.ciphertext})
    : recipientBitNameHash = _bitNameHash(recipientBitNameHash) {
    _notEmpty(ciphertext, 'ciphertext');
  }

  final String recipientBitNameHash;
  final String ciphertext;

  factory BitMessageWire.fromJson(Map<String, dynamic> json) => BitMessageWire(
    recipientBitNameHash: _string(json, 'recipient_bitname_hash'),
    ciphertext: _string(json, 'ciphertext'),
  );

  Map<String, dynamic> toJson() => {'recipient_bitname_hash': recipientBitNameHash, 'ciphertext': ciphertext};
}

String canonicalJsonEncode(Object? value) {
  if (value == null) return 'null';
  if (value is String) return jsonEncode(value);
  if (value is bool) return '$value';
  if (value is int) return '$value';
  if (value is num) throw ArgumentError.value(value, 'value', 'canonical signed JSON only permits integer numbers');
  if (value is List) return '[${value.map(canonicalJsonEncode).join(',')}]';
  if (value is Map) {
    final entries = value.entries.map((entry) {
      if (entry.key is! String) {
        throw ArgumentError.value(entry.key, 'key', 'canonical JSON object keys must be strings');
      }
      return MapEntry(entry.key as String, entry.value);
    }).toList()..sort((a, b) => a.key.compareTo(b.key));
    return '{${entries.map((e) => '${jsonEncode(e.key)}:${canonicalJsonEncode(e.value)}').join(',')}}';
  }
  throw ArgumentError.value(value, 'value', 'not a JSON value');
}

final _hashPattern = RegExp(r'^[0-9a-f]{64}$');

String _bitNameHash(String value) {
  final hash = value.trim().toLowerCase();
  if (!_hashPattern.hasMatch(hash)) {
    throw ArgumentError.value(value, 'bitNameHash', 'must be a 32-byte hexadecimal hash');
  }
  return hash;
}

void _notEmpty(String value, String name) {
  if (value.trim().isEmpty) throw ArgumentError.value(value, name, 'must not be empty');
}

void _boundedId(String value, String name) {
  if (value.trim().isEmpty || value.length > 256) {
    throw ArgumentError.value(value, name, 'must contain 1-256 characters');
  }
}

List<Uri> _endpoints(Iterable<Uri> input, bool tor) {
  final unique = <String, Uri>{};
  for (final endpoint in input) {
    final scheme = endpoint.scheme.toLowerCase();
    final host = endpoint.host.toLowerCase();
    final basicInvalid = !endpoint.hasScheme || host.isEmpty || endpoint.hasFragment || endpoint.userInfo.isNotEmpty;
    final routeInvalid = tor
        ? scheme != 'http' || !host.endsWith('.onion')
        : !{'http', 'https'}.contains(scheme) || host.endsWith('.onion');
    if (basicInvalid || routeInvalid) {
      throw ArgumentError.value(endpoint, tor ? 'torEndpoints' : 'directEndpoints', 'invalid endpoint');
    }
    var path = endpoint.path.isEmpty ? '/' : endpoint.path;
    if (!path.endsWith('/')) path += '/';
    final normalized = endpoint.replace(scheme: scheme, host: host, path: path);
    unique['$normalized'] = normalized;
  }
  final keys = unique.keys.toList()..sort();
  return keys.map((key) => unique[key]!).toList();
}

List<Uri> _uriList(dynamic value, String field) {
  if (value == null) return const [];
  if (value is! List) throw FormatException('$field must be an array');
  return value.map((item) {
    if (item is! String) throw FormatException('$field entries must be strings');
    final uri = Uri.tryParse(item);
    if (uri == null) throw FormatException('$field contains an invalid URI');
    return uri;
  }).toList();
}

String _string(Map<String, dynamic> json, String field, {bool empty = false}) {
  final value = json[field];
  if (value is! String || (!empty && value.trim().isEmpty)) {
    throw FormatException('$field must be ${empty ? 'a string' : 'a non-empty string'}');
  }
  return value;
}

int _integer(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! int) throw FormatException('$field must be an integer');
  return value;
}

int? _optionalInt(Map<String, dynamic> json, String field) => json[field] == null ? null : _integer(json, field);
