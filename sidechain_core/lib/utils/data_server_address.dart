/// Returns a host with a port, or null when the host is empty. A resolver
/// parses `host:port`, so a bare domain takes the default port.
String? hostWithPort(String? host, int defaultPort) {
  final trimmed = host?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }

  return trimmed.contains(':') ? trimmed : '$trimmed:$defaultPort';
}

/// Returns the address a resolver reaches for a BitName. A resolver reads the
/// IPv4 address, then the IPv6 address, then the host.
String dataServerAddress({
  required String? website,
  required String? ipv4,
  required String? ipv6,
  required int defaultPort,
}) {
  final v4 = ipv4?.trim() ?? '';
  if (v4.isNotEmpty) {
    return v4;
  }

  final v6 = ipv6?.trim() ?? '';
  if (v6.isNotEmpty) {
    return v6;
  }

  return hostWithPort(website, defaultPort) ?? '';
}
