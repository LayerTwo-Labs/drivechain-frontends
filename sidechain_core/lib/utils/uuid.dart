import 'dart:math';

final _random = Random.secure();

final _rfc9562 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

const _nilUuid = '00000000-0000-0000-0000-000000000000';
const _maxUuid = 'ffffffff-ffff-ffff-ffff-ffffffffffff';

/// A random RFC 9562 version 4 UUID in lowercase 8-4-4-4-12 form.
String uuidV4() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// True for an RFC 9562 UUID in 8-4-4-4-12 form, and for the nil and max UUID.
bool isValidUuid(String value) => value == _nilUuid || value == _maxUuid || _rfc9562.hasMatch(value);
