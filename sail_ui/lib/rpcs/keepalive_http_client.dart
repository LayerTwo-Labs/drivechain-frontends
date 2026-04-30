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
/// - `pingInterval: 10s` keeps the server's `ReadIdleTimeout: 30s` from
///   firing a server-side liveness PING that would tear the connection
///   down with GOAWAY when the round-trip stalls.
/// - `pingTimeout: 5s` — if our PING isn't acked, the transport surfaces
///   the failure to the active stream, which the supervisor handles.
/// - `pingIdleConnections: true` — keep pinging even when no streams are
///   open so the long-lived transport doesn't go silent.
HttpClient streamingHttpClient() {
  return createHttpClient(
    transport: Http2ClientTransport(
      pingInterval: const Duration(seconds: 10),
      pingTimeout: const Duration(seconds: 5),
      pingIdleConnections: true,
    ),
  );
}

/// Back-compat alias for callers (like `bitwindow_api.dart`) that mix unary
/// and streaming on the same transport and haven't been split yet.
/// Prefer [unaryHttpClient] / [streamingHttpClient] in new code.
HttpClient keepaliveHttpClient() => streamingHttpClient();
