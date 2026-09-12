final _hexDigest = RegExp(r'^[0-9a-fA-F]{64}$');

/// Returns an error message for a data commitment, or null when it is valid.
/// A commitment resolves only through a socket address, so one without an
/// address is a hash that nobody can read.
String? validateCommitment({
  required String? commitment,
  required String? ipv4,
  required String? ipv6,
}) {
  if (commitment == null || commitment.isEmpty) {
    return null;
  }

  if (!_hexDigest.hasMatch(commitment)) {
    return 'Commitment must be a 64-character BLAKE3 digest';
  }

  final hasAddress = (ipv4 != null && ipv4.isNotEmpty) || (ipv6 != null && ipv6.isNotEmpty);
  if (!hasAddress) {
    return 'Set an address. A commitment with no address is a hash nobody can read.';
  }

  return null;
}
