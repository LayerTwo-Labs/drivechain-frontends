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
HttpClient unaryHttpClient() => closableUnaryHttpClient().client;

/// [unaryHttpClient] plus the callback that retires its socket pool.
///
/// A connectrpc [HttpClient] is a bare closure, so a caller that rebuilds a
/// transport cannot reach the pool behind the old one. Those sockets then stay
/// open until GC finalizes the client, and a reconnect loop runs the process
/// out of file descriptors long before that.
///
/// The close drops the idle sockets and refuses new ones, but it lets a
/// request already in flight finish. A stream supervisor rebuilds on an HTTP/2
/// fault that says nothing about a healthy unary call, and most callers do not
/// retry.
({HttpClient client, void Function() close}) closableUnaryHttpClient() {
  final client = io.HttpClient()
    ..idleTimeout = const Duration(minutes: 5)
    ..connectionTimeout = const Duration(seconds: 30);
  return (client: connect_io.createHttpClient(client), close: client.close);
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
///   which caused both bitwindowd and drivechaind to tear streams down
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
      // Http2ClientTransport exposes no close, so an abandoned transport holds
      // its socket for the whole idle window. The timer only arms once the
      // connection carries no open stream, so a live stream never trips it.
      idleConnectionTimeout: const Duration(minutes: 1),
    ),
  );
}

/// Back-compat alias for callers (like `bitwindow_api.dart`) that mix unary
/// and streaming on the same transport and haven't been split yet.
/// Prefer [unaryHttpClient] / [streamingHttpClient] in new code.
HttpClient keepaliveHttpClient() => streamingHttpClient();
