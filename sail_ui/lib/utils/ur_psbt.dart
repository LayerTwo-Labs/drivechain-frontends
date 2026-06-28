import 'dart:convert';
import 'dart:typed_data';

/// Encoder/decoder for the Uniform Resources (UR) `crypto-psbt` type used by
/// airgap signers (Coldcard, SeedSigner, Passport, Keystone, Sparrow).
///
/// A PSBT is CBOR-wrapped as a byte string (BCR-2020-006, tag conveyed by the
/// UR type label `crypto-psbt`), ByteWords-encoded (BCR-2020-012) and split
/// into multi-part frames (BCR-2020-005 / BCR-2024-001). Parts are pure
/// sequential (seqNum 1..seqLen, no fountain mixing); per the spec this is a
/// conformant encoder and standard fountain decoders accept these parts.
class URPsbt {
  static const String type = 'crypto-psbt';

  /// Encode raw PSBT bytes into one or more `ur:crypto-psbt/...` frames.
  ///
  /// [maxFragmentLen] caps the PSBT-payload bytes per frame (before ByteWords
  /// expansion). With a single fragment the single-part form
  /// `ur:crypto-psbt/<bytewords>` is emitted; otherwise multi-part frames
  /// `ur:crypto-psbt/<seq>-<total>/<bytewords>` are emitted. All multi-part
  /// fragments are equal length, the final one zero-padded (BCR-2024-001).
  static List<String> encode(Uint8List psbt, {int maxFragmentLen = 200}) {
    final message = _cborWrapBytes(psbt);

    if (message.length <= maxFragmentLen) {
      return ['ur:$type/${ByteWords.encode(message)}'];
    }

    final seqLen = (message.length / maxFragmentLen).ceil();
    final fragLen = (message.length / seqLen).ceil();
    final checksum = _crc32(message);
    final frames = <String>[];

    for (var i = 0; i < seqLen; i++) {
      final start = i * fragLen;
      final fragment = Uint8List(fragLen);
      final available = (message.length - start).clamp(0, fragLen);
      if (available > 0) {
        fragment.setRange(0, available, message, start);
      }

      final part = _cborEncodePart(
        seqNum: i + 1,
        seqLen: seqLen,
        messageLen: message.length,
        checksum: checksum,
        fragment: fragment,
      );
      frames.add('ur:$type/${i + 1}-$seqLen/${ByteWords.encode(part)}');
    }
    return frames;
  }

  /// Encode a base64 PSBT into UR frames.
  static List<String> encodeBase64(String psbtBase64, {int maxFragmentLen = 200}) {
    return encode(base64.decode(psbtBase64.trim()), maxFragmentLen: maxFragmentLen);
  }

  static URDecoder decoder() => URDecoder();
}

/// Stateful reassembler for multi-part `ur:crypto-psbt` frames. Feed frames as
/// they are scanned; [isComplete] flips once enough distinct parts arrive.
class URDecoder {
  int? _seqLen;
  int? _messageLen;
  int? _checksum;
  final Map<int, Uint8List> _parts = {};
  Uint8List? _single;

  /// Number of distinct parts received so far.
  int get receivedCount => _single != null ? 1 : _parts.length;

  /// Total parts expected (null until the first multi-part frame is seen).
  int? get expectedCount => _single != null ? 1 : _seqLen;

  bool get isComplete {
    if (_single != null) return true;
    if (_seqLen == null) return false;
    return _parts.length == _seqLen;
  }

  /// Feed one `ur:...` frame. Returns true if this frame was accepted (correct
  /// type and well-formed). Throws [FormatException] on a malformed frame.
  bool receive(String frame) {
    final lower = frame.trim().toLowerCase();
    if (!lower.startsWith('ur:${URPsbt.type}/')) {
      throw const FormatException('not a ur:crypto-psbt frame');
    }
    final body = frame.trim().substring('ur:${URPsbt.type}/'.length);
    final slash = body.indexOf('/');

    if (slash == -1) {
      _single = _cborUnwrapBytes(ByteWords.decode(body));
      return true;
    }

    final header = body.substring(0, slash);
    final dash = header.indexOf('-');
    if (dash == -1) throw const FormatException('malformed multipart header');
    final seqNum = int.parse(header.substring(0, dash));
    final payload = ByteWords.decode(body.substring(slash + 1));

    final part = _cborDecodePart(payload);
    _seqLen ??= part.seqLen;
    _messageLen ??= part.messageLen;
    _checksum ??= part.checksum;

    if (part.seqLen != _seqLen || part.messageLen != _messageLen || part.checksum != _checksum) {
      throw const FormatException('mismatched multipart frame');
    }
    if (seqNum != part.seqNum || seqNum < 1 || seqNum > _seqLen!) {
      throw const FormatException('bad sequence number');
    }
    _parts[seqNum] = part.fragment;
    return true;
  }

  /// Assembled PSBT bytes. Throws if not yet [isComplete] or checksum fails.
  Uint8List result() {
    if (_single != null) return _single!;
    if (!isComplete) throw StateError('UR not complete');

    final builder = BytesBuilder();
    for (var i = 1; i <= _seqLen!; i++) {
      builder.add(_parts[i]!);
    }
    final padded = builder.toBytes();
    if (padded.length < _messageLen!) {
      throw const FormatException('assembled message shorter than messageLen');
    }
    // Fragments are equal-length with the final one zero-padded; strip padding.
    final message = Uint8List.sublistView(padded, 0, _messageLen!);
    if (_crc32(message) != _checksum) {
      throw const FormatException('checksum mismatch');
    }
    return _cborUnwrapBytes(message);
  }

  /// Assembled PSBT as base64.
  String resultBase64() => base64.encode(result());
}

class _Part {
  final int seqNum;
  final int seqLen;
  final int messageLen;
  final int checksum;
  final Uint8List fragment;
  _Part(this.seqNum, this.seqLen, this.messageLen, this.checksum, this.fragment);
}

Uint8List _cborWrapBytes(Uint8List data) {
  final builder = BytesBuilder();
  _cborWriteByteStringHeader(builder, data.length);
  builder.add(data);
  return builder.toBytes();
}

Uint8List _cborUnwrapBytes(Uint8List message) {
  final r = _CborReader(message);
  final bytes = r.readByteString();
  return bytes;
}

void _cborWriteByteStringHeader(BytesBuilder b, int len) {
  _cborWriteTypedLen(b, 2, len);
}

void _cborWriteUint(BytesBuilder b, int value) {
  _cborWriteTypedLen(b, 0, value);
}

void _cborWriteTypedLen(BytesBuilder b, int majorType, int len) {
  final mt = majorType << 5;
  if (len < 24) {
    b.addByte(mt | len);
  } else if (len < 0x100) {
    b.addByte(mt | 24);
    b.addByte(len);
  } else if (len < 0x10000) {
    b.addByte(mt | 25);
    b.addByte((len >> 8) & 0xff);
    b.addByte(len & 0xff);
  } else if (len < 0x100000000) {
    b.addByte(mt | 26);
    b.addByte((len >> 24) & 0xff);
    b.addByte((len >> 16) & 0xff);
    b.addByte((len >> 8) & 0xff);
    b.addByte(len & 0xff);
  } else {
    b.addByte(mt | 27);
    for (var shift = 56; shift >= 0; shift -= 8) {
      b.addByte((len >> shift) & 0xff);
    }
  }
}

Uint8List _cborEncodePart({
  required int seqNum,
  required int seqLen,
  required int messageLen,
  required int checksum,
  required Uint8List fragment,
}) {
  final b = BytesBuilder();
  b.addByte(0x80 | 5); // array of 5
  _cborWriteUint(b, seqNum);
  _cborWriteUint(b, seqLen);
  _cborWriteUint(b, messageLen);
  _cborWriteUint(b, checksum);
  _cborWriteByteStringHeader(b, fragment.length);
  b.add(fragment);
  return b.toBytes();
}

_Part _cborDecodePart(Uint8List data) {
  final r = _CborReader(data);
  final arrayLen = r.readArrayHeader();
  if (arrayLen != 5) throw const FormatException('multipart array must have 5 items');
  final seqNum = r.readUint();
  final seqLen = r.readUint();
  final messageLen = r.readUint();
  final checksum = r.readUint();
  final fragment = r.readByteString();
  return _Part(seqNum, seqLen, messageLen, checksum, fragment);
}

class _CborReader {
  final Uint8List _data;
  int _pos = 0;
  _CborReader(this._data);

  int _readArgument(int initialByte) {
    final ai = initialByte & 0x1f;
    if (ai < 24) return ai;
    if (ai == 24) return _data[_pos++];
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

  int readUint() {
    final b = _data[_pos++];
    if ((b >> 5) != 0) throw const FormatException('expected cbor uint');
    return _readArgument(b);
  }

  int readArrayHeader() {
    final b = _data[_pos++];
    if ((b >> 5) != 4) throw const FormatException('expected cbor array');
    return _readArgument(b);
  }

  Uint8List readByteString() {
    final b = _data[_pos++];
    if ((b >> 5) != 2) throw const FormatException('expected cbor byte string');
    final len = _readArgument(b);
    final out = Uint8List.sublistView(_data, _pos, _pos + len);
    _pos += len;
    return Uint8List.fromList(out);
  }
}

/// ByteWords encoding (BCR-2020-012). Appends a 4-byte big-endian CRC32 of the
/// payload, then encodes each byte as its two-letter (first+last) word form.
class ByteWords {
  static const String _words =
      'ableacidalsoapexaquaarchatomauntawayaxisbackbaldbarnbeltbetabias'
      'bluebodybragbrewbulbbuzzcalmcashcatschefcityclawcodecolacookcost'
      'cruxcurlcuspcyandarkdatadaysdelidicedietdoordowndrawdropdrumdull'
      'dutyeacheasyechoedgeepicevenexamexiteyesfactfairfernfigsfilmfish'
      'fizzflapflewfluxfoxyfreefrogfuelfundgalagamegeargemsgiftgirlglow'
      'goodgraygrimgurugushgyrohalfhanghardhawkheathelphighhillholyhope'
      'hornhutsicedideaidleinchinkyintoirisironitemjadejazzjoinjoltjowl'
      'judojugsjumpjunkjurykeepkenokeptkeyskickkilnkingkitekiwiknoblamb'
      'lavalazyleaflegsliarlimplionlistlogoloudloveluaulucklungmainmany'
      'mathmazememomenumeowmildmintmissmonknailnavyneednewsnextnoonnote'
      'numbobeyoboeomitonyxopenovalowlspaidpartpeckplaypluspoempoolpose'
      'puffpumapurrquadquizraceramprealredorichroadrockroofrubyruinruns'
      'rustsafesagascarsetssilkskewslotsoapsolosongstubsurfswantacotask'
      'taxitenttiedtimetinytoiltombtoystriptunatwinuglyundouniturgeuser'
      'vastveryvetovialvibeviewvisavoidvowswallwandwarmwaspwavewaxywebs'
      'whatwhenwhizwolfworkyankyawnyellyogayurtzapszerozestzinczonezoom';

  static final List<String> _wordList = _buildWordList();
  static final Map<String, int> _minimalIndex = _buildMinimalIndex();

  static List<String> _buildWordList() {
    final clean = _words.replaceAll(' ', '');
    final list = <String>[];
    for (var i = 0; i < 256; i++) {
      list.add(clean.substring(i * 4, i * 4 + 4));
    }
    return list;
  }

  static Map<String, int> _buildMinimalIndex() {
    final map = <String, int>{};
    for (var i = 0; i < 256; i++) {
      final w = _wordList[i];
      map['${w[0]}${w[3]}'] = i;
    }
    return map;
  }

  /// Minimal ByteWords encoding of [payload] with appended CRC32 checksum.
  static String encode(Uint8List payload) {
    final crc = _crc32(payload);
    final withCrc = Uint8List(payload.length + 4);
    withCrc.setRange(0, payload.length, payload);
    withCrc[payload.length] = (crc >> 24) & 0xff;
    withCrc[payload.length + 1] = (crc >> 16) & 0xff;
    withCrc[payload.length + 2] = (crc >> 8) & 0xff;
    withCrc[payload.length + 3] = crc & 0xff;

    final sb = StringBuffer();
    for (final byte in withCrc) {
      final w = _wordList[byte];
      sb.write(w[0]);
      sb.write(w[3]);
    }
    return sb.toString();
  }

  /// Decode minimal ByteWords back to the payload, verifying the CRC32.
  static Uint8List decode(String minimal) {
    final s = minimal.toLowerCase();
    if (s.length % 2 != 0 || s.length < 2) {
      throw const FormatException('invalid bytewords length');
    }
    final bytes = Uint8List(s.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      final key = s.substring(i * 2, i * 2 + 2);
      final idx = _minimalIndex[key];
      if (idx == null) throw FormatException('invalid byteword "$key"');
      bytes[i] = idx;
    }
    if (bytes.length < 5) throw const FormatException('bytewords too short for checksum');
    final payload = Uint8List.sublistView(bytes, 0, bytes.length - 4);
    final crc =
        (bytes[bytes.length - 4] << 24) |
        (bytes[bytes.length - 3] << 16) |
        (bytes[bytes.length - 2] << 8) |
        bytes[bytes.length - 1];
    if (_crc32(Uint8List.fromList(payload)) != (crc & 0xffffffff)) {
      throw const FormatException('bytewords checksum mismatch');
    }
    return Uint8List.fromList(payload);
  }
}

final List<int> _crc32Table = _buildCrc32Table();

List<int> _buildCrc32Table() {
  final table = List<int>.filled(256, 0);
  for (var n = 0; n < 256; n++) {
    var c = n;
    for (var k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? (0xedb88320 ^ (c >> 1)) : (c >> 1);
    }
    table[n] = c & 0xffffffff;
  }
  return table;
}

int _crc32(Uint8List data) {
  var crc = 0xffffffff;
  for (final b in data) {
    crc = _crc32Table[(crc ^ b) & 0xff] ^ (crc >> 8);
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}
