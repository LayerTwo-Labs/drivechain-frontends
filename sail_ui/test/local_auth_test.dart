import 'dart:convert';
import 'dart:io';

import 'package:connectrpc/connect.dart' as crpc;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sail_ui/auth/local_auth.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('localauth_test');
    LocalAuth.configure(dir);
  });

  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  void writeCookie(String value) {
    File('${dir.path}/${LocalAuth.cookieFileName}').writeAsStringSync(value);
  }

  test('absent cookie -> no token (auth disabled)', () async {
    expect(await LocalAuth.token(), isNull);
  });

  test('reads and trims the cookie token', () async {
    writeCookie('  abc123\n');
    expect(await LocalAuth.token(), 'abc123');
  });

  // An absent read must NOT be cached, so a cookie written after the first
  // (absent) read is still picked up.
  test('does not cache an absent cookie', () async {
    expect(await LocalAuth.token(), isNull);
    writeCookie('late');
    expect(await LocalAuth.token(), 'late');
  });

  // A successful read IS cached (no per-call disk read).
  test('caches the token after first read', () async {
    writeCookie('first');
    expect(await LocalAuth.token(), 'first');
    writeCookie('second'); // cookie rotated on disk
    expect(await LocalAuth.token(), 'first', reason: 'served from cache');
  });

  // reset() is what the interceptor calls on the local-auth rejection: it drops
  // the cache so the next read picks up the rotated cookie.
  test('reset re-reads the rotated cookie', () async {
    writeCookie('first');
    expect(await LocalAuth.token(), 'first');
    writeCookie('second');
    LocalAuth.reset();
    expect(await LocalAuth.token(), 'second');
  });

  test('interceptor retries unary calls after formatted token rejection', () async {
    writeCookie('old');

    var calls = 0;
    final intercepted = LocalAuth.interceptor()<String, String>((req) async {
      calls++;
      if (calls == 1) {
        expect(req.headers['authorization'], 'Bearer old');
        writeCookie('new');
        throw crpc.ConnectException(
          crpc.Code.unauthenticated,
          '[unauthenticated] ${LocalAuth.tokenRejectedMessage}',
        );
      }

      expect(req.headers['authorization'], 'Bearer new');
      return crpc.UnaryResponse<String, String>(
        req.spec,
        crpc.Headers(),
        'ok',
        crpc.Headers(),
      );
    });

    final spec = crpc.Spec<String, String>(
      '/test.Auth/Call',
      crpc.StreamType.unary,
      () => '',
      () => '',
    );
    final resp = await intercepted(
      crpc.UnaryRequest<String, String>(
        spec,
        'http://example.invalid',
        crpc.Headers(),
        'request',
        crpc.CancelableSignal(),
      ),
    );

    expect(calls, 2);
    expect((resp as crpc.UnaryResponse<String, String>).message, 'ok');
    expect(await LocalAuth.token(), 'new');
  });

  test('raw JSON posts retry after token rejection', () async {
    writeCookie('old');

    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (calls == 1) {
        expect(request.headers['authorization'], 'Bearer old');
        writeCookie('new');
        return http.Response(
          jsonEncode({
            'code': 'unauthenticated',
            'message': LocalAuth.tokenRejectedMessage,
          }),
          401,
        );
      }

      expect(request.headers['authorization'], 'Bearer new');
      return http.Response('ok', 200);
    });

    final resp = await LocalAuth.postJsonWithAuth(
      Uri.parse('http://example.invalid/cusf.mainchain.v1.ValidatorService/GetChainTip'),
      body: '{}',
      client: client,
    );

    expect(calls, 2);
    expect(resp.body, 'ok');
    expect(await LocalAuth.token(), 'new');
  });
}
