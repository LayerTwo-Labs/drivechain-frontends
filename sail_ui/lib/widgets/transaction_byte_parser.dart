// Client-side parser that breaks a raw Bitcoin transaction hex string into
// labeled, offset-annotated byte fields for display. Pure Dart, no Flutter.

/// A single labeled, offset-annotated field within a raw transaction.
class TxByteField {
  /// Byte offset of this field within the raw transaction.
  final int offset;

  /// Hex of just this field's bytes (lowercase, no separators).
  final String hex;

  /// Human-readable label, e.g. "Version" or "Input #0 prevout txid".
  final String label;

  /// Optional decoded interpretation, e.g. "2" for a version field.
  final String? value;

  const TxByteField({
    required this.offset,
    required this.hex,
    required this.label,
    this.value,
  });

  int get length => hex.length ~/ 2;
}

class ParsedTransaction {
  final List<TxByteField> fields;
  final bool isSegwit;
  final int version;
  final int inputCount;
  final int outputCount;
  final int locktime;

  const ParsedTransaction({
    required this.fields,
    required this.isSegwit,
    required this.version,
    required this.inputCount,
    required this.outputCount,
    required this.locktime,
  });
}

class TxParseException implements Exception {
  final String message;
  const TxParseException(this.message);
  @override
  String toString() => 'TxParseException: $message';
}

/// Parses [rawHex] into annotated fields. Throws [TxParseException] on
/// malformed or truncated input.
ParsedTransaction parseTransactionHex(String rawHex) {
  final hex = rawHex.trim().toLowerCase();
  if (hex.isEmpty) {
    throw const TxParseException('empty transaction hex');
  }
  if (hex.length.isOdd) {
    throw const TxParseException('odd-length hex string');
  }
  if (!RegExp(r'^[0-9a-f]+$').hasMatch(hex)) {
    throw const TxParseException('non-hex characters in input');
  }

  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }

  final reader = _ByteReader(bytes);
  final fields = <TxByteField>[];

  final version = reader.readUint32LE();
  fields.add(TxByteField(offset: version.offset, hex: version.hex, label: 'Version', value: '${version.value}'));

  var isSegwit = false;
  if (reader.remaining >= 2 && reader.peek(0) == 0x00 && reader.peek(1) == 0x01) {
    final marker = reader.read(2);
    isSegwit = true;
    fields.add(
      TxByteField(offset: marker.offset, hex: marker.hex, label: 'SegWit marker + flag', value: '0001'),
    );
  }

  final inputCount = reader.readVarint();
  fields.add(
    TxByteField(
      offset: inputCount.offset,
      hex: inputCount.hex,
      label: 'Input count',
      value: '${inputCount.value}',
    ),
  );

  for (var i = 0; i < inputCount.value; i++) {
    final txid = reader.read(32);
    fields.add(
      TxByteField(
        offset: txid.offset,
        hex: txid.hex,
        label: 'Input #$i prevout txid',
        value: _reverseHex(txid.hex),
      ),
    );
    final vout = reader.readUint32LE();
    fields.add(
      TxByteField(offset: vout.offset, hex: vout.hex, label: 'Input #$i prevout vout', value: '${vout.value}'),
    );

    final scriptLen = reader.readVarint();
    fields.add(
      TxByteField(
        offset: scriptLen.offset,
        hex: scriptLen.hex,
        label: 'Input #$i scriptSig length',
        value: '${scriptLen.value}',
      ),
    );
    if (scriptLen.value > 0) {
      final script = reader.read(scriptLen.value);
      fields.add(TxByteField(offset: script.offset, hex: script.hex, label: 'Input #$i scriptSig'));
    }

    final sequence = reader.readUint32LE();
    fields.add(
      TxByteField(offset: sequence.offset, hex: sequence.hex, label: 'Input #$i sequence', value: '${sequence.value}'),
    );
  }

  final outputCount = reader.readVarint();
  fields.add(
    TxByteField(
      offset: outputCount.offset,
      hex: outputCount.hex,
      label: 'Output count',
      value: '${outputCount.value}',
    ),
  );

  for (var i = 0; i < outputCount.value; i++) {
    final value = reader.readUint64LE();
    fields.add(
      TxByteField(offset: value.offset, hex: value.hex, label: 'Output #$i value (sats)', value: '${value.value}'),
    );

    final scriptLen = reader.readVarint();
    fields.add(
      TxByteField(
        offset: scriptLen.offset,
        hex: scriptLen.hex,
        label: 'Output #$i scriptPubKey length',
        value: '${scriptLen.value}',
      ),
    );
    if (scriptLen.value > 0) {
      final script = reader.read(scriptLen.value);
      fields.add(TxByteField(offset: script.offset, hex: script.hex, label: 'Output #$i scriptPubKey'));
    }
  }

  if (isSegwit) {
    for (var i = 0; i < inputCount.value; i++) {
      final stackItems = reader.readVarint();
      fields.add(
        TxByteField(
          offset: stackItems.offset,
          hex: stackItems.hex,
          label: 'Input #$i witness item count',
          value: '${stackItems.value}',
        ),
      );
      for (var j = 0; j < stackItems.value; j++) {
        final itemLen = reader.readVarint();
        fields.add(
          TxByteField(
            offset: itemLen.offset,
            hex: itemLen.hex,
            label: 'Input #$i witness[$j] length',
            value: '${itemLen.value}',
          ),
        );
        if (itemLen.value > 0) {
          final item = reader.read(itemLen.value);
          fields.add(TxByteField(offset: item.offset, hex: item.hex, label: 'Input #$i witness[$j]'));
        }
      }
    }
  }

  final locktime = reader.readUint32LE();
  fields.add(TxByteField(offset: locktime.offset, hex: locktime.hex, label: 'Lock time', value: '${locktime.value}'));

  if (reader.remaining != 0) {
    throw TxParseException('${reader.remaining} trailing byte(s) after lock time');
  }

  return ParsedTransaction(
    fields: fields,
    isSegwit: isSegwit,
    version: version.value,
    inputCount: inputCount.value,
    outputCount: outputCount.value,
    locktime: locktime.value,
  );
}

String _reverseHex(String hex) {
  final out = StringBuffer();
  for (var i = hex.length - 2; i >= 0; i -= 2) {
    out.write(hex.substring(i, i + 2));
  }
  return out.toString();
}

class _Read {
  final int offset;
  final String hex;
  final int value;
  const _Read(this.offset, this.hex, this.value);
}

class _ByteReader {
  final List<int> _bytes;
  int _pos = 0;

  _ByteReader(this._bytes);

  int get remaining => _bytes.length - _pos;

  int peek(int ahead) => _bytes[_pos + ahead];

  void _require(int n) {
    if (remaining < n) {
      throw TxParseException('unexpected end of data: need $n byte(s), have $remaining');
    }
  }

  _Read read(int n) {
    _require(n);
    final start = _pos;
    final sb = StringBuffer();
    for (var i = 0; i < n; i++) {
      sb.write(_bytes[_pos + i].toRadixString(16).padLeft(2, '0'));
    }
    _pos += n;
    return _Read(start, sb.toString(), 0);
  }

  _Read readUint32LE() {
    _require(4);
    final start = _pos;
    var v = 0;
    final sb = StringBuffer();
    for (var i = 0; i < 4; i++) {
      final b = _bytes[_pos + i];
      sb.write(b.toRadixString(16).padLeft(2, '0'));
      v |= b << (8 * i);
    }
    _pos += 4;
    return _Read(start, sb.toString(), v);
  }

  _Read readUint64LE() {
    _require(8);
    final start = _pos;
    var v = 0;
    final sb = StringBuffer();
    for (var i = 0; i < 8; i++) {
      final b = _bytes[_pos + i];
      sb.write(b.toRadixString(16).padLeft(2, '0'));
      v |= b << (8 * i);
    }
    _pos += 8;
    return _Read(start, sb.toString(), v);
  }

  _Read readVarint() {
    _require(1);
    final start = _pos;
    final prefix = _bytes[_pos];
    if (prefix < 0xfd) {
      _pos += 1;
      return _Read(start, prefix.toRadixString(16).padLeft(2, '0'), prefix);
    }
    final int count;
    if (prefix == 0xfd) {
      count = 2;
    } else if (prefix == 0xfe) {
      count = 4;
    } else {
      count = 8;
    }
    _require(1 + count);
    var v = 0;
    final sb = StringBuffer();
    sb.write(prefix.toRadixString(16).padLeft(2, '0'));
    for (var i = 0; i < count; i++) {
      final b = _bytes[_pos + 1 + i];
      sb.write(b.toRadixString(16).padLeft(2, '0'));
      v |= b << (8 * i);
    }
    _pos += 1 + count;
    return _Read(start, sb.toString(), v);
  }
}
