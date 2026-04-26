import 'package:connectrpc/connect.dart';
import 'package:connectrpc/http2.dart';

/// Build a connectrpc HTTP client with sensible keepalive defaults.
///
/// `package:connectrpc`'s default `createHttpClient()` does not send PING
/// frames, so an idle server-streaming RPC (like `WatchWalletData`) is
/// invisible to the underlying TCP socket. Go's `http2.Server` —
/// configured with `ReadIdleTimeout: 30s` in the orchestrator — then
/// triggers a server-side liveness PING; if the round-trip stalls, the
/// server tears the connection down with a `GOAWAY`, which surfaces as
/// "Connection is being forcefully terminated. (errorCode: 10)" on the
/// Dart side.
///
/// Sending client-side PINGs every 10s keeps the server's read idle
/// timer reset, *and* lets the connectrpc transport detect a dead
/// connection proactively (within `pingTimeout`) so the next call
/// transparently establishes a fresh socket via `Http2ClientTransport`'s
/// internal `verify()` loop — no manual transport rebuild needed.
///
/// `pingIdleConnections: true` ensures we keep pinging even when no
/// streams are open, so a long-lived connection doesn't go silent and
/// hit the server's 30s idle window.
HttpClient keepaliveHttpClient() {
  return createHttpClient(
    transport: Http2ClientTransport(
      pingInterval: const Duration(seconds: 10),
      pingTimeout: const Duration(seconds: 5),
      pingIdleConnections: true,
    ),
  );
}
