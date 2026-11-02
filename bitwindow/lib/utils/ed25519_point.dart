final _p = (BigInt.one << 255) - BigInt.from(19);
final _d = (BigInt.from(-121665) * BigInt.from(121666).modInverse(_p)) % _p;

/// True when [bytes] is the RFC 8032 encoding of a point on the ed25519 curve.
bool isEd25519Point(List<int> bytes) {
  if (bytes.length != 32) {
    return false;
  }
  var y = BigInt.zero;
  for (var i = 31; i >= 0; i--) {
    y = (y << 8) | BigInt.from(bytes[i]);
  }
  final sign = (y >> 255) & BigInt.one;
  y &= (BigInt.one << 255) - BigInt.one;
  if (y >= _p) {
    return false;
  }

  final y2 = (y * y) % _p;
  final u = (y2 - BigInt.one) % _p;
  final v = (_d * y2 + BigInt.one) % _p;
  final x2 = (u * v.modPow(_p - BigInt.two, _p)) % _p;
  if (x2 == BigInt.zero) {
    return sign == BigInt.zero;
  }
  return x2.modPow((_p - BigInt.one) >> 1, _p) == BigInt.one;
}
