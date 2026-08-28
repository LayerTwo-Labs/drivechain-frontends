import 'dart:convert';
import 'dart:typed_data';

import 'package:bitwindow/utils/ur_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/ur_psbt.dart';

// BIP32 test vector 1, chain m/0'. The parser must rebuild exactly this xpub
// from the raw key material a crypto-hdkey carries.
const _bip32Vector1Account0Xpub =
    'xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw';
const _chainCodeHex = '47fdacbd0f1097043b78c63c20c34ef4ed9a111d980047ad16282c7ae6236141';
const _keyDataHex = '035a784662a4a20a65bf6aab9ae98a6c068a81c52e4b032c0fb5400c706cfccc56';
const _masterFingerprint = 0x3442193e;

Uint8List _hex(String s) {
  final out = Uint8List(s.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(s.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

/// Minimal CBOR writer for the UR shapes the tests build.
class _Cbor {
  final BytesBuilder _b = BytesBuilder();

  Uint8List bytes() => _b.toBytes();

  void _header(int major, int value) {
    final mt = major << 5;
    if (value < 24) {
      _b.addByte(mt | value);
    } else if (value < 0x100) {
      _b.addByte(mt | 24);
      _b.addByte(value);
    } else if (value < 0x10000) {
      _b.addByte(mt | 25);
      _b.addByte((value >> 8) & 0xff);
      _b.addByte(value & 0xff);
    } else {
      _b.addByte(mt | 26);
      for (var shift = 24; shift >= 0; shift -= 8) {
        _b.addByte((value >> shift) & 0xff);
      }
    }
  }

  void uint(int v) => _header(0, v);
  void byteString(Uint8List v) {
    _header(2, v.length);
    _b.add(v);
  }

  void array(int n) => _header(4, n);
  void map(int n) => _header(5, n);
  void tag(int n) => _header(6, n);
  void boolean(bool v) => _b.addByte(v ? 0xf5 : 0xf4);
}

/// Writes a crypto-hdkey holding the BIP32 vector-1 account key.
void _writeHdKey(_Cbor c) {
  c.map(4);
  c.uint(3);
  c.byteString(_hex(_keyDataHex));
  c.uint(4);
  c.byteString(_hex(_chainCodeHex));
  c.uint(6);
  c.tag(304);
  c.map(3);
  c.uint(1);
  c.array(2);
  c.uint(0);
  c.boolean(true);
  c.uint(2);
  c.uint(_masterFingerprint);
  c.uint(3);
  c.uint(1);
  c.uint(8);
  c.uint(_masterFingerprint);
}

Uint8List _hdKeyMessage() {
  final c = _Cbor();
  _writeHdKey(c);
  return c.bytes();
}

/// Writes a crypto-account whose descriptor list holds the same key twice,
/// once under wpkh (404) and once under wsh (401).
Uint8List _accountMessage() {
  final c = _Cbor();
  c.tag(311);
  c.map(2);
  c.uint(1);
  c.uint(_masterFingerprint);
  c.uint(2);
  c.array(2);
  c.tag(404);
  _writeHdKey(c);
  c.tag(401);
  _writeHdKey(c);
  return c.bytes();
}

const _passportExport =
    '''
{
  "xfp": "3442193E",
  "account": 0,
  "bip84": {
    "name": "p2wpkh",
    "xfp": "AABBCCDD",
    "deriv": "m/84'/0'/0'",
    "xpub": "$_bip32Vector1Account0Xpub"
  },
  "bip48_2": {
    "name": "p2wsh",
    "deriv": "m/48'/0'/0'/2'",
    "xpub": "$_bip32Vector1Account0Xpub"
  }
}
''';

/// The form a `ur:crypto-account` carries: the UR type names the registry
/// entry, so the account map itself is untagged.
Uint8List _untaggedAccountMessage() {
  final c = _Cbor();
  c.map(2);
  c.uint(1);
  c.uint(_masterFingerprint);
  c.uint(2);
  c.array(2);
  c.tag(404);
  _writeHdKey(c);
  c.tag(401);
  _writeHdKey(c);
  return c.bytes();
}

/// Rebuilds one multi-part frame with a new sequence number, so a test can
/// send the fountain part a UR v2 encoder emits past seqLen.
String _reframeWithSeqNum(String frame, int seqNum) {
  if (seqNum >= 24) {
    throw ArgumentError('the test only rebuilds a one-byte sequence number');
  }
  final body = frame.substring(frame.indexOf('/') + 1);
  final header = body.substring(0, body.indexOf('/'));
  final seqLen = int.parse(header.split('-')[1]);
  final payload = ByteWords.decode(body.substring(body.indexOf('/') + 1));

  // The part is cbor([seqNum, seqLen, messageLen, checksum, fragment]) and the
  // array header comes first, so only byte 1 carries the sequence number.
  final rebuilt = Uint8List.fromList(payload);
  rebuilt[1] = seqNum;
  return 'ur:crypto-psbt/$seqNum-$seqLen/${ByteWords.encode(rebuilt)}';
}

/// An account whose first output nests the key: sh(wsh(hdkey)), the shape a
/// nested-segwit multisig export carries.
Uint8List _nestedAccountMessage() {
  final c = _Cbor();
  c.map(2);
  c.uint(1);
  c.uint(_masterFingerprint);
  c.uint(2);
  c.array(2);
  c.tag(400);
  c.tag(401);
  _writeHdKey(c);
  c.tag(401);
  _writeHdKey(c);
  return c.bytes();
}

/// An account whose output is wsh(sortedmulti(2, hdkey, hdkey)): the script tag
/// wraps a map that holds the cosigner keys.
Uint8List _sortedMultiAccountMessage() {
  final c = _Cbor();
  c.map(2);
  c.uint(1);
  c.uint(_masterFingerprint);
  c.uint(2);
  c.array(1);
  c.tag(401);
  c.tag(407);
  c.map(2);
  c.uint(1);
  c.uint(2);
  c.uint(2);
  c.array(2);
  _writeHdKey(c);
  _writeHdKey(c);
  return c.bytes();
}

void main() {
  group('parseUrKeyMessage', () {
    test('rebuilds the xpub from a crypto-hdkey', () {
      final keys = parseUrKeyMessage(_hdKeyMessage());

      expect(keys, hasLength(1));
      expect(keys.single.xpub, _bip32Vector1Account0Xpub);
      expect(keys.single.originPath, "0'");
      expect(keys.single.fingerprint, '3442193e');
      expect(keys.single.scriptTag, isNull);
    });

    test('reads every output of a crypto-account and tags each script type', () {
      final keys = parseUrKeyMessage(_accountMessage());

      expect(keys, hasLength(2));
      expect(keys.map((k) => k.scriptTag), [404, 401]);
      expect(keys.every((k) => k.xpub == _bip32Vector1Account0Xpub), isTrue);
    });

    test('reads a wallet export carried in a bytes payload', () {
      final c = _Cbor();
      c.byteString(Uint8List.fromList(utf8.encode(_passportExport)));

      final keys = parseUrKeyMessage(c.bytes());

      expect(keys, hasLength(2));
      expect(keys.first.originPath, "84'/0'/0'");
    });

    test('reads an untagged crypto-account, the form a UR carries', () {
      final keys = parseUrKeyMessage(_untaggedAccountMessage(), urType: 'crypto-account');

      expect(keys, hasLength(2));
      expect(keys.map((k) => k.scriptTag), [404, 401]);
      expect(keys.first.fingerprint, '3442193e');
    });

    test('reads an untagged crypto-account without a type hint', () {
      expect(parseUrKeyMessage(_untaggedAccountMessage()), hasLength(2));
    });

    test('keeps the outer wrapper of a nested output', () {
      final keys = parseUrKeyMessage(_nestedAccountMessage(), urType: 'crypto-account');

      expect(keys, hasLength(2));
      expect(keys.map((k) => k.scriptTag), [400, 401]);
      expect(pickKeyForScriptType(keys, 'sh-wsh')!.scriptTag, 400);
      expect(pickKeyForScriptType(keys, 'wsh')!.scriptTag, 401);
    });

    test('reads a bare key carried in a bytes payload', () {
      final c = _Cbor();
      c.byteString(Uint8List.fromList(utf8.encode("[3442193E/48'/0'/0'/2']$_bip32Vector1Account0Xpub")));

      final keys = parseUrKeyMessage(c.bytes(), urType: 'bytes');

      expect(keys.single.xpub, _bip32Vector1Account0Xpub);
      expect(keys.single.originPath, "48'/0'/0'/2'");
    });

    test('reads the cosigner keys of a sortedmulti output', () {
      final keys = parseUrKeyMessage(_sortedMultiAccountMessage(), urType: 'crypto-account');

      expect(keys, hasLength(2));
      expect(keys.map((k) => k.scriptTag), [401, 401]);
      expect(keys.first.xpub, _bip32Vector1Account0Xpub);
    });

    test('returns nothing for a message that holds no key', () {
      final c = _Cbor();
      c.map(1);
      c.uint(1);
      c.uint(7);

      expect(parseUrKeyMessage(c.bytes()), isEmpty);
    });
  });

  group('URDecoder', () {
    test('joins a multi-part sequence and learns the type', () {
      final psbt = Uint8List.fromList(List<int>.generate(600, (i) => i % 256));
      final frames = URPsbt.encode(psbt, maxFragmentLen: 100);
      expect(frames.length, greaterThan(1));

      final decoder = URDecoder();
      for (final frame in frames) {
        decoder.receive(frame);
      }

      expect(decoder.type, 'crypto-psbt');
      expect(decoder.expectedCount, frames.length);
      expect(decoder.isComplete, isTrue);
      expect(decoder.result(), psbt);
    });

    test('carries a single-frame crypto-hdkey through to the parser', () {
      final message = _hdKeyMessage();
      final decoder = URDecoder();

      decoder.receive('ur:crypto-hdkey/${ByteWords.encode(message)}');

      expect(decoder.type, 'crypto-hdkey');
      expect(decoder.isComplete, isTrue);
      expect(parseUrKeyMessage(decoder.messageBytes()).single.xpub, _bip32Vector1Account0Xpub);
    });

    test('keeps the parts it holds when a fountain part arrives', () {
      final psbt = Uint8List.fromList(List<int>.generate(600, (i) => i % 256));
      final frames = URPsbt.encode(psbt, maxFragmentLen: 100);
      final decoder = URDecoder();
      decoder.receive(frames.first);

      // A UR v2 encoder emits mixed parts past seqLen. They must not wipe the
      // pure parts already received.
      expect(decoder.receive(_reframeWithSeqNum(frames.first, frames.length + 1)), isFalse);
      expect(decoder.receivedCount, 1);

      for (final frame in frames.skip(1)) {
        decoder.receive(frame);
      }
      expect(decoder.result(), psbt);
    });

    test('refuses a frame whose type the caller did not ask for', () {
      final decoder = URPsbt.decoder();

      expect(() => decoder.receive('ur:crypto-hdkey/aeaeae'), throwsFormatException);
    });

    test('refuses a second type mid-sequence', () {
      final decoder = URDecoder();
      decoder.receive('ur:crypto-hdkey/${ByteWords.encode(_hdKeyMessage())}');

      expect(() => decoder.receive('ur:crypto-account/aeaeae'), throwsFormatException);
    });
  });

  group('parseWalletExportJson', () {
    test('reads every block of a nested Passport export', () {
      final keys = parseWalletExportJson(_passportExport);

      expect(keys, hasLength(2));
      expect(keys[0].originPath, "84'/0'/0'");
      expect(keys[0].fingerprint, 'AABBCCDD');
      expect(keys[0].scriptTag, 404);
      expect(keys[1].originPath, "48'/0'/0'/2'");
      expect(keys[1].fingerprint, '3442193E');
      expect(keys[1].scriptTag, 401);
    });

    test('reads the flat single-key export', () {
      final keys = parseWalletExportJson(
        "{\"xpub\":\"$_bip32Vector1Account0Xpub\",\"path\":\"m/84'/0'/0'\",\"master_fingerprint\":\"3442193e\"}",
      );

      expect(keys, hasLength(1));
      expect(keys.single.originPath, "84'/0'/0'");
      expect(keys.single.fingerprint, '3442193e');
    });
  });

  group('pickKeyForScriptType', () {
    test('picks the block that matches the policy', () {
      final keys = parseWalletExportJson(_passportExport);

      expect(pickKeyForScriptType(keys, 'wsh')!.originPath, "48'/0'/0'/2'");
      expect(pickKeyForScriptType(keys, 'wpkh')!.originPath, "84'/0'/0'");
    });

    test('falls back to the first key when no block matches', () {
      final keys = parseWalletExportJson(_passportExport);

      expect(pickKeyForScriptType(keys, 'pkh')!.originPath, "84'/0'/0'");
    });

    test('returns null for an empty list', () {
      expect(pickKeyForScriptType(const [], 'wsh'), isNull);
    });
  });

  group('parseKeyText', () {
    test('reads a key expression', () {
      final keys = parseKeyText("[3442193E/48'/0'/0'/2']$_bip32Vector1Account0Xpub");

      expect(keys.single.fingerprint, '3442193e');
      expect(keys.single.originPath, "48'/0'/0'/2'");
    });

    test('reads a bare xpub', () {
      expect(parseKeyText(_bip32Vector1Account0Xpub).single.xpub, _bip32Vector1Account0Xpub);
    });

    test('rejects text that is not a key', () {
      expect(parseKeyText('hello'), isEmpty);
    });
  });
}
