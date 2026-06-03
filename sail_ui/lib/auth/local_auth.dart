import 'dart:convert';
import 'dart:io' as io;

import 'package:connectrpc/connect.dart';
import 'package:http/http.dart' as http;

/// Local-auth cookie support shared by every frontend. Mirrors the Go
/// `localauth` package: the orchestrator writes a random token to
/// `<appDir>/.auth.cookie` (the dir holding `wallet.json`), and [interceptor]
/// attaches it as a bearer token to every RPC.
///
/// The token is **cached** (read from disk once, not per call). The catch is
/// that the orchestrator rotates the cookie when it (re)starts — which happens
/// *after* the app launched it — so a cached token can briefly be the previous
/// run's. The interceptor handles that: when a call comes back with the
/// specific local-auth error ([Code.unauthenticated] + "local auth"), it drops
/// the cache, refetches the cookie, and retries once.
class LocalAuth {
  LocalAuth._();

  static const cookieFileName = '.auth.cookie';

  static String? _cookiePath;
  static String? _token;

  /// Records the app data directory holding `.auth.cookie` (same dir as
  /// `wallet.json`). Call once at startup before any RPC.
  static void configure(io.Directory appDir) {
    _cookiePath = '${appDir.path}/$cookieFileName';
    _token = null;
  }

  /// Waits for the cookie to first exist (the orchestrator writes it shortly
  /// after it spawns). Optional. Returns true once present, false after
  /// [timeout] (e.g. auth disabled).
  static Future<bool> load({Duration timeout = const Duration(seconds: 15)}) async {
    final deadline = DateTime.now().add(timeout);
    while (true) {
      if (await token() != null) return true;
      if (!DateTime.now().isBefore(deadline)) return false;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  /// Returns the cookie token, cached after the first successful read. Drop the
  /// cache with [reset] when it's rejected so the next read picks up a rotated
  /// cookie. Null when the cookie is absent (auth disabled).
  static Future<String?> token() async => _token ??= await _read();

  /// Drops the cached token so the next [token] re-reads from disk.
  static void reset() => _token = null;

  static Future<String?> _read() async {
    final path = _cookiePath;
    if (path == null) return null;
    try {
      final file = io.File(path);
      if (!await file.exists()) return null;
      final value = (await file.readAsString()).trim();
      return value.isEmpty ? null : value;
    } catch (_) {
      return null;
    }
  }

  /// The sentinel message the Go `localauth.verify` returns for a stale/
  /// rejected token (its `TokenRejectedMessage`). Keep in sync with the Go side.
  static const tokenRejectedMessage = 'token invalid';

  /// True only for the specific "your token is stale, refetch" rejection.
  static bool _isTokenRejected(Object e) {
    if (e is! ConnectException || e.code != Code.unauthenticated) {
      return false;
    }
    return e.message == tokenRejectedMessage || e.toString().endsWith(tokenRejectedMessage);
  }

  /// True for the raw Connect/HTTP form of the same stale-token rejection.
  static bool isTokenRejectedHttpResponse(int statusCode, String body) {
    if (statusCode != 401) return false;

    final trimmed = body.trim();
    if (trimmed == tokenRejectedMessage) return true;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) return false;
      return decoded['code'] == 'unauthenticated' && decoded['message'] == tokenRejectedMessage;
    } catch (_) {
      return trimmed.endsWith(tokenRejectedMessage);
    }
  }

  /// POST JSON to a local Connect endpoint with the cached bearer token. Raw
  /// console calls bypass the generated Connect transport, so they need the
  /// same stale-cookie retry behavior as [interceptor].
  static Future<http.Response> postJsonWithAuth(
    Uri uri, {
    required String body,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      var response = await _postJsonOnce(httpClient, uri, body);
      if (isTokenRejectedHttpResponse(response.statusCode, response.body)) {
        reset();
        response = await _postJsonOnce(httpClient, uri, body);
      }
      return response;
    } finally {
      if (client == null) httpClient.close();
    }
  }

  static Future<http.Response> _postJsonOnce(
    http.Client client,
    Uri uri,
    String body,
  ) async {
    final tok = await token();
    return client.post(
      uri,
      headers: {
        'content-type': 'application/json',
        if (tok != null) 'authorization': 'Bearer $tok',
      },
      body: body,
    );
  }

  /// A connectrpc interceptor that attaches the cached cookie token and, on the
  /// specific local-auth rejection, refetches the (rotated) cookie and retries
  /// once. Add to each `Transport(interceptors: [...])`.
  static Interceptor interceptor() {
    return <I extends Object, O extends Object>(AnyFn<I, O> next) {
      return (req) async {
        final tok = await token();
        if (tok != null) req.headers['authorization'] = 'Bearer $tok';
        try {
          return await next(req);
        } catch (e) {
          if (!_isTokenRejected(e)) rethrow;
          // Cookie was rotated (orchestrator restarted). Refetch and, for unary
          // calls, retry once; streams recover on their supervisor's reconnect
          // now that the cache is cleared.
          reset();
          final fresh = await token();
          if (req is UnaryRequest && fresh != null && fresh != tok) {
            req.headers['authorization'] = 'Bearer $fresh';
            return await next(req);
          }
          rethrow;
        }
      };
    };
  }
}
