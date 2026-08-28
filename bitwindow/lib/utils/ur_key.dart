import 'dart:convert';
import 'dart:typed_data';

import 'package:bs58/bs58.dart';
import 'package:crypto/crypto.dart';

/// One extended public key read out of a `crypto-hdkey` / `crypto-account` UR.
class UrKey {
  final String xpub;
  final String? fingerprint;
  final String? originPath;
  final String? name;

  /// UR output script tag (400-410) that wrapped the key, or null when the key
  /// arrived on its own.
  final int? scriptTag;

  const UrKey({required this.xpub, this.fingerprint, this.originPath, this.name, this.scriptTag});
}

/// bcr-2023 moved the metadata tags into the 403xx range; devices send either.
int _canonicalTag(int tag) {
  if (tag >= 40303 && tag <= 40311) {
    return tag - 40000;
  }
  return tag;
}

bool _isScriptTag(int tag) => tag >= 400 && tag <= 410;

/// UR script tags that hold [scriptType], best first.
List<int> preferredScriptTags(String scriptType) {
  switch (scriptType) {
    case 'wsh':
      return const [401, 410, 407, 406];
    case 'sh-wsh':
    case 'sh':
      return const [400];
    case 'tr':
      return const [409];
    case 'sh-wpkh':
      return const [400, 404];
    case 'pkh':
      return const [403];
    default:
      return const [404];
  }
}

/// Picks the key that matches [scriptType], or the first key when none match.
UrKey? pickKeyForScriptType(List<UrKey> keys, String scriptType) {
  if (keys.isEmpty) {
    return null;
  }
  for (final tag in preferredScriptTags(scriptType)) {
    for (final key in keys) {
      if (key.scriptTag == tag) {
        return key;
      }
    }
  }
  return keys.first;
}

/// Reads every extended public key out of an assembled UR message.
///
/// Handles `crypto-hdkey`, `crypto-output`, `crypto-account`, and a `bytes`
/// message that carries a wallet export as JSON or as a plain key string.
/// Returns an empty list when the message holds no key.
List<UrKey> parseUrKeyMessage(Uint8List message, {String? urType}) {
  final Object? root = _CborReader(message).readValue();
  final keys = <UrKey>[];
  if (_isUntaggedAccount(root, urType)) {
    _collectAccount(root, keys);
  } else {
    _collectKeys(root, null, null, keys);
  }
  if (keys.isNotEmpty) {
    return keys;
  }
  if (root is Uint8List) {
    return parseKeyText(utf8.decode(root, allowMalformed: true));
  }
  if (root is String) {
    return parseKeyText(root);
  }
  return const [];
}

/// Reads every key out of a wallet export file.
///
/// Covers the nested Coldcard/Passport export (top-level `xfp` plus one
/// `bip44`/`bip49`/`bip84`/`bip86` block per script type) and the flat
/// single-key form that carries `xpub` at the top level.
List<UrKey> parseWalletExportJson(String text) {
  final keys = <UrKey>[];
  final trimmed = text.trim();
  if (!trimmed.startsWith('{')) {
    return keys;
  }
  final Object? decoded = jsonDecode(trimmed);
  if (decoded is! Map<String, dynamic>) {
    return keys;
  }
  final masterFingerprint = _stringField(decoded, const ['xfp', 'master_fingerprint', 'fingerprint']);

  final flatXpub = _stringField(decoded, const ['xpub', 'extended_public_key', 'pubkey']);
  if (flatXpub != null && flatXpub.isNotEmpty) {
    final flatPath = _stringField(decoded, const [
      'deriv',
      'path',
      'derivation_path',
      'bip32_path',
      'origin_path',
      'origin',
    ]);
    keys.add(
      UrKey(
        xpub: flatXpub,
        fingerprint: masterFingerprint,
        originPath: flatPath == null ? null : _stripMasterPrefix(flatPath),
        name: _stringField(decoded, const ['owner', 'name']),
      ),
    );
  }

  for (final entry in decoded.entries) {
    final value = entry.value;
    if (value is! Map<String, dynamic>) {
      continue;
    }
    final xpub = value['xpub'];
    if (xpub is! String || xpub.isEmpty) {
      continue;
    }
    final deriv = value['deriv'];
    keys.add(
      UrKey(
        xpub: xpub,
        fingerprint: _stringField(value, const ['xfp']) ?? masterFingerprint,
        originPath: deriv is String ? _stripMasterPrefix(deriv) : null,
        name: _stringField(value, const ['name']),
        scriptTag: _scriptTagForName(value['name']),
      ),
    );
  }
  return keys;
}

String? _stringField(Map<String, dynamic> map, List<String> names) {
  for (final name in names) {
    final value = map[name];
    if (value is String && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

/// Maps a Coldcard/Passport script name (`p2wpkh`, `p2wsh`, ...) onto the UR
/// output script tag, so a file import and a QR import rank keys the same way.
int? _scriptTagForName(Object? name) {
  if (name is! String) {
    return null;
  }
  switch (name.toLowerCase()) {
    case 'p2pkh':
      return 403;
    case 'p2sh':
    case 'p2wpkh-p2sh':
    case 'p2sh-p2wpkh':
    case 'p2wsh-p2sh':
    case 'p2sh-p2wsh':
      return 400;
    case 'p2wpkh':
      return 404;
    case 'p2wsh':
      return 401;
    case 'p2tr':
      return 409;
    default:
      return null;
  }
}

String _stripMasterPrefix(String path) {
  if (path.startsWith('m/') || path.startsWith('M/')) {
    return path.substring(2);
  }
  return path;
}

void _collectKeys(Object? node, int? scriptTag, int? accountFingerprint, List<UrKey> out) {
  if (node is _CborTag) {
    final tag = _canonicalTag(node.tag);
    if (tag == 311) {
      _collectAccount(node.value, out);
      return;
    }
    // The outer tag names the whole expression: sh(wsh(...)) is nested segwit,
    // and the inner wsh alone would read as native.
    _collectKeys(node.value, scriptTag ?? (_isScriptTag(tag) ? tag : null), accountFingerprint, out);
    return;
  }
  if (node is List) {
    for (final item in node) {
      _collectKeys(item, scriptTag, accountFingerprint, out);
    }
    return;
  }
  if (node is Map) {
    final key = _hdKeyFromMap(node, scriptTag, accountFingerprint);
    if (key != null) {
      out.add(key);
      return;
    }
    // A multi or sortedmulti descriptor holds its cosigner keys in a map value.
    for (final value in node.values) {
      _collectKeys(value, scriptTag, accountFingerprint, out);
    }
  }
}

/// A `ur:crypto-account` carries its map untagged, because the UR type already
/// names the registry entry. Key 2 holds the output list there, where an hdkey
/// holds a bool.
bool _isUntaggedAccount(Object? node, String? urType) {
  if (node is! Map || node.containsKey(3)) {
    return false;
  }
  if (node[2] is! List) {
    return false;
  }
  return urType == null || urType.endsWith('account');
}

void _collectAccount(Object? value, List<UrKey> out) {
  if (value is! Map) {
    return;
  }
  final fingerprint = _fingerprintHex(value[1]);
  _collectKeys(value[2], null, fingerprint, out);
}

UrKey? _hdKeyFromMap(Map<Object?, Object?> map, int? scriptTag, int? accountFingerprint) {
  final keyData = map[3];
  final chainCode = map[4];
  if (keyData is! Uint8List || keyData.length != 33) {
    return null;
  }
  if (chainCode is! Uint8List || chainCode.length != 32) {
    return null;
  }
  if (map[2] == true) {
    return null; // a private key never belongs in a watch-only import
  }

  final origin = _untag(map[6]);
  final components = origin is Map ? origin[1] : null;
  final path = components is List ? _keyPath(components) : null;
  final depth = origin is Map && origin[3] is int
      ? origin[3]! as int
      : (components is List ? components.length ~/ 2 : 0);
  final childNumber = components is List ? _lastChildNumber(components) : 0;

  final originFingerprint = origin is Map ? _fingerprintHex(origin[2]) : null;
  final parentFingerprint = map[8] is int ? map[8]! as int : 0;

  final useInfo = _untag(map[5]);
  final testnet = useInfo is Map && useInfo[2] == 1;

  final serialized = _serializeExtendedKey(
    version: testnet ? 0x043587cf : 0x0488b21e,
    depth: depth,
    parentFingerprint: parentFingerprint,
    childNumber: childNumber,
    chainCode: chainCode,
    keyData: keyData,
  );

  final fingerprint = originFingerprint ?? accountFingerprint;
  return UrKey(
    xpub: serialized,
    fingerprint: fingerprint == null ? null : _hex32(fingerprint),
    originPath: path,
    name: map[9] is String ? map[9]! as String : null,
    scriptTag: scriptTag,
  );
}

Object? _untag(Object? node) => node is _CborTag ? node.value : node;

int? _fingerprintHex(Object? value) => value is int ? value : null;

String _hex32(int value) => value.toRadixString(16).padLeft(8, '0');

/// Renders keypath components as `48'/0'/0'/2'`, or null when a component is
/// a range or a wildcard rather than a plain index.
String? _keyPath(List<Object?> components) {
  final parts = <String>[];
  for (var i = 0; i + 1 < components.length; i += 2) {
    final index = components[i];
    if (index is! int) {
      return null;
    }
    parts.add(components[i + 1] == true ? "$index'" : '$index');
  }
  return parts.join('/');
}

int _lastChildNumber(List<Object?> components) {
  if (components.length < 2) {
    return 0;
  }
  final index = components[components.length - 2];
  if (index is! int) {
    return 0;
  }
  final hardened = components[components.length - 1] == true;
  return hardened ? index | 0x80000000 : index;
}

String _serializeExtendedKey({
  required int version,
  required int depth,
  required int parentFingerprint,
  required int childNumber,
  required Uint8List chainCode,
  required Uint8List keyData,
}) {
  final payload = Uint8List(78);
  final view = ByteData.view(payload.buffer);
  view.setUint32(0, version);
  payload[4] = depth & 0xff;
  view.setUint32(5, parentFingerprint);
  view.setUint32(9, childNumber);
  payload.setRange(13, 45, chainCode);
  payload.setRange(45, 78, keyData);

  final checksum = sha256.convert(sha256.convert(payload).bytes).bytes.sublist(0, 4);
  return base58.encode(Uint8List.fromList([...payload, ...checksum]));
}

class _CborTag {
  final int tag;
  final Object? value;
  const _CborTag(this.tag, this.value);
}

/// Reader for the CBOR subset the UR key types use.
class _CborReader {
  final Uint8List _data;
  int _pos = 0;
  _CborReader(this._data);

  Object? readValue() {
    final initial = _data[_pos++];
    final major = initial >> 5;
    switch (major) {
      case 0:
        return _argument(initial);
      case 1:
        return -1 - _argument(initial);
      case 2:
        return _bytes(_argument(initial));
      case 3:
        return utf8.decode(_bytes(_argument(initial)), allowMalformed: true);
      case 4:
        return List<Object?>.generate(_argument(initial), (_) => readValue(), growable: false);
      case 5:
        final length = _argument(initial);
        final map = <Object?, Object?>{};
        for (var i = 0; i < length; i++) {
          final key = readValue();
          map[key] = readValue();
        }
        return map;
      case 6:
        return _CborTag(_argument(initial), readValue());
      default:
        return _simple(initial);
    }
  }

  Object? _simple(int initial) {
    final value = initial & 0x1f;
    switch (value) {
      case 20:
        return false;
      case 21:
        return true;
      case 22:
      case 23:
        return null;
      default:
        throw const FormatException('unsupported cbor simple value');
    }
  }

  Uint8List _bytes(int length) {
    final out = Uint8List.fromList(Uint8List.sublistView(_data, _pos, _pos + length));
    _pos += length;
    return out;
  }

  int _argument(int initial) {
    final ai = initial & 0x1f;
    if (ai < 24) {
      return ai;
    }
    if (ai == 24) {
      return _data[_pos++];
    }
    if (ai == 25) {
      final v = (_data[_pos] << 8) | _data[_pos + 1];
      _pos += 2;
      return v;
    }
    if (ai == 26) {
      final v = (_data[_pos] << 24) | (_data[_pos + 1] << 16) | (_data[_pos + 2] << 8) | _data[_pos + 3];
      _pos += 4;
      return v;
    }
    if (ai == 27) {
      var v = 0;
      for (var i = 0; i < 8; i++) {
        v = (v << 8) | _data[_pos++];
      }
      return v;
    }
    throw const FormatException('unsupported cbor argument');
  }
}

final RegExp _xpubPattern = RegExp(r'^[xyztuvYZUV]pub[1-9A-HJ-NP-Za-km-z]{50,120}$');
final RegExp _keyExpressionPattern = RegExp(r'^\[([0-9a-fA-F]{8})(?:/([^\]]*))?\](.+)$');

/// Reads a single-frame QR body: `[fingerprint/origin]xpub`, a bare xpub, or a
/// wallet export in JSON. Returns null when the text holds no key.
List<UrKey> parseKeyText(String raw) {
  final trimmed = raw.trim();
  if (trimmed.startsWith('{')) {
    return parseWalletExportJson(trimmed);
  }
  final match = _keyExpressionPattern.firstMatch(trimmed);
  if (match != null) {
    final xpub = match.group(3)!.trim();
    if (!_xpubPattern.hasMatch(xpub)) {
      return const [];
    }
    return [UrKey(xpub: xpub, fingerprint: match.group(1)?.toLowerCase(), originPath: match.group(2))];
  }
  if (_xpubPattern.hasMatch(trimmed)) {
    return [UrKey(xpub: trimmed)];
  }
  return const [];
}
