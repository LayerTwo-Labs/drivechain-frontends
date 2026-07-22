import 'dart:convert';

import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:http/http.dart' as http;

// dart format off

enum BitMessageTransportType { direct, tor }

class BitMessageHttpResponse {
  const BitMessageHttpResponse({required this.statusCode, required this.body});
  final int statusCode;
  final String body;
}

abstract interface class BitMessageHttpDialer {
  Future<BitMessageHttpResponse> get(Uri uri, {required Duration timeout});
  Future<BitMessageHttpResponse> postJson(Uri uri, {required String body, required Duration timeout});
  void close();
}

class DirectBitMessageHttpDialer implements BitMessageHttpDialer {
  DirectBitMessageHttpDialer({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  @override
  Future<BitMessageHttpResponse> get(Uri uri, {required Duration timeout}) async {
    final response = await _client.get(uri, headers: const {'accept': 'application/json'}).timeout(timeout);
    return BitMessageHttpResponse(statusCode: response.statusCode, body: response.body);
  }

  @override
  Future<BitMessageHttpResponse> postJson(
    Uri uri, {
    required String body,
    required Duration timeout,
  }) async {
    final response = await _client
        .post(
          uri,
          headers: const {'accept': 'application/json', 'content-type': 'application/json'},
          body: body,
        )
        .timeout(timeout);
    return BitMessageHttpResponse(statusCode: response.statusCode, body: response.body);
  }

  @override
  void close() => _client.close();
}

class BitMessageSendResult {
  const BitMessageSendResult({required this.transport, this.endpoint, this.failedAttempts = const []});
  final BitMessageTransportType transport;
  final Uri? endpoint;
  final List<String> failedAttempts;
}

class BitMessageTransportException implements Exception {
  const BitMessageTransportException(this.message, this.attempts);
  final String message;
  final List<String> attempts;

  @override
  String toString() => '$message (${attempts.join('; ')})';
}

class BitMessageTransport {
  BitMessageTransport({
    required this.directDialer,
    this.torDialer,
    this.requestTimeout = const Duration(seconds: 10),
    this.maxProfileResponseBytes = 16 * 1024,
  }) {
    if (maxProfileResponseBytes <= 0) {
      throw ArgumentError.value(maxProfileResponseBytes, 'maxProfileResponseBytes', 'must be positive');
    }
  }

  final BitMessageHttpDialer directDialer;
  final BitMessageHttpDialer? torDialer;
  final Duration requestTimeout;
  final int maxProfileResponseBytes;

  Future<BitMessageSendResult> send(BitMessageWire wire, VerifiedBitMessageProfile profile,
    {bool torOnly = false}) async {
    if (wire.recipientBitNameHash != profile.bitNameHash) {
      throw ArgumentError('Wire recipient does not match the verified profile');
    }
    final routes = _routes(profile.profile, torOnly);
    if (torOnly && routes.isEmpty) {
      throw const BitMessageTransportException('Tor mode is enabled but no Tor route is available', []);
    }

    final failures = <String>[];
    for (final route in routes) {
      try {
        await _verifyProfile(route, profile);
        final response = await route.dialer.postJson(route.endpoint.resolve('bitmessage_submit'),
          body: canonicalJsonEncode(wire.toJson()), timeout: requestTimeout);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw StateError('submit returned HTTP ${response.statusCode}');
        }
        return BitMessageSendResult(transport: route.type, endpoint: route.endpoint,
          failedAttempts: List.unmodifiable(failures));
      } catch (error) {
        failures.add('${route.type.name}:${route.endpoint}: $error');
      }
    }
    throw BitMessageTransportException('No BitMessage route accepted the message', List.unmodifiable(failures));
  }

  Future<BitMessageProfile?> discoverProfile(BitMessageProfile previous, {bool torOnly = false}) async {
    for (final route in _routes(previous, torOnly)) {
      try {
        final profile = await _readProfile(route);
        if (profile.bitNameHash == previous.bitNameHash) return profile;
      } catch (_) {}
    }
    return null;
  }

  List<_HttpRoute> _routes(BitMessageProfile profile, bool torOnly) => [
    if (!torOnly) ...profile.directEndpoints.map((uri) => _HttpRoute(BitMessageTransportType.direct, uri, directDialer)),
    if (torDialer != null) ...profile.torEndpoints.map((uri) => _HttpRoute(BitMessageTransportType.tor, uri, torDialer!)),
  ];

  Future<void> _verifyProfile(_HttpRoute route, VerifiedBitMessageProfile expected) async {
    final served = await _readProfile(route);
    if (bitMessageProfileCommitment(served) != expected.onChainCommitment) {
      throw StateError('served profile does not match the authoritative BitName commitment');
    }
    if (canonicalJsonEncode(served.toJson()) != canonicalJsonEncode(expected.profile.toJson())) {
      throw StateError('served profile differs from the verified profile');
    }
  }

  Future<BitMessageProfile> _readProfile(_HttpRoute route) async {
    final response = await route.dialer.get(route.endpoint.resolve('bitname_commit'), timeout: requestTimeout);
    if (response.statusCode != 200) throw StateError('commit returned HTTP ${response.statusCode}');
    if (utf8.encode(response.body).length > maxProfileResponseBytes) {
      throw StateError('committed profile response is too large');
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw StateError('committed profile response is not valid JSON');
    }
    if (decoded is! Map) throw StateError('committed profile response must be an object');
    return BitMessageProfile.fromJson(Map<String, dynamic>.from(decoded));
  }

  void close() {
    directDialer.close();
    if (!identical(torDialer, directDialer)) torDialer?.close();
  }
}

class _HttpRoute {
  const _HttpRoute(this.type, this.endpoint, this.dialer);
  final BitMessageTransportType type;
  final Uri endpoint;
  final BitMessageHttpDialer dialer;
}
