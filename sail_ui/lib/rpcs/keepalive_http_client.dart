import 'dart:io' as io;

import 'package:connectrpc/connect.dart';
import 'package:connectrpc/http2.dart';
import 'package:connectrpc/io.dart' as connect_io;

/// HTTP transport for **unary** RPC calls — plain HTTP/1.1.
///
/// Unary calls are short-lived; HTTP/1.1 is well-trodden in the Dart
/// connectrpc package and avoids the multiplexing failure modes that bite
/// only long-running streams. We deliberately don't share an HTTP/2
/// connection between unary and streaming calls so a poisoned streaming
/// transport can't take down list/get RPCs that are otherwise fine.
HttpClient unaryHttpClient() {
  final client = io.HttpClient()
    ..idleTimeout = const Duration(minutes: 5)
    ..connectionTimeout = const Duration(seconds: 30);
  return connect_io.createHttpClient(client);
}

/// HTTP transport for **server-streaming** RPCs — HTTP/2 with keepalive PINGs.
///
/// Server-streaming over HTTP/2 is the path the connectrpc Dart package is
/// best tested against. Half-open detection at the HTTP/2 layer (PING
/// timeout) plus the application-level [StreamSupervisor] watchdog gives
/// us two independent layers of liveness checks.
///
/// PING config:
/// - `pingInterval: 20s` keeps the server's `ReadIdleTimeout: 30s` from
///   firing without flooding it. Earlier we ran 10s with idle-pings on,
///   which caused both bitwindowd and orchestratord to tear streams down
///   every ~15s with HTTP/2 PROTOCOL_ERROR / GOAWAY (CONNECT_ERROR=10) —
///   server-side flood-protection mistook the steady ping cadence on
///   otherwise-quiet streams for misbehavior.
/// - `pingTimeout: 10s` — long enough to absorb GC / scheduler jitter.
/// - `pingIdleConnections: false` — server-side handlers already emit
///   5s heartbeat frames, which keep the read-idle timer reset on their
///   own. Layering client pings on top is what tripped the flood guard.
HttpClient streamingHttpClient() {
  return createHttpClient(
    transport: Http2ClientTransport(
      pingInterval: const Duration(seconds: 20),
      pingTimeout: const Duration(seconds: 10),
      pingIdleConnections: false,
    ),
  );
}

/// Back-compat alias for callers (like `bitwindow_api.dart`) that mix unary
/// and streaming on the same transport and haven't been split yet.
/// Prefer [unaryHttpClient] / [streamingHttpClient] in new code.
HttpClient keepaliveHttpClient() => streamingHttpClient();
