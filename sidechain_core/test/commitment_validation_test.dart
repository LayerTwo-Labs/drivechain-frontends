import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/commitment_validation.dart';

const _digest = '9f2c4b8e7a1d05c3e6f8b2a4d7091ce5ab36f4d82c0917be5a3f6c1d4e8027a1';

void main() {
  test('no commitment is valid', () {
    expect(validateCommitment(commitment: null, ipv4: null, ipv6: null), isNull);
    expect(validateCommitment(commitment: '', ipv4: null, ipv6: null), isNull);
  });

  test('a commitment with an IPv4 address is valid', () {
    expect(
      validateCommitment(commitment: _digest, ipv4: '203.0.113.7:6002', ipv6: null),
      isNull,
    );
  });

  test('a commitment with only an IPv6 address is valid', () {
    expect(
      validateCommitment(commitment: _digest, ipv4: '', ipv6: '[::1]:6002'),
      isNull,
    );
  });

  test('a commitment with no address is rejected', () {
    expect(
      validateCommitment(commitment: _digest, ipv4: '', ipv6: ''),
      'Set an address. A commitment with no address is a hash nobody can read.',
    );
  });

  test('a commitment that is not a digest is rejected', () {
    expect(
      validateCommitment(commitment: 'deadbeef', ipv4: '203.0.113.7:6002', ipv6: null),
      'Commitment must be a 64-character BLAKE3 digest',
    );
  });
}
