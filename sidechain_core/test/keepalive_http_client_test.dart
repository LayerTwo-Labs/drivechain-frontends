import 'dart:async';
import 'dart:io' as io;

import 'package:connectrpc/connect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/rpcs/keepalive_http_client.dart';

void main() {
  // A rebuilt transport left its socket pool open, so a reconnect loop ran the
  // process out of file descriptors (errno 24).
  test('the unary client closes its sockets on demand', () async {
    final server = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
    server.listen((req) => req.response.close());
    addTearDown(() => server.close(force: true));

    final url = 'http://127.0.0.1:${server.port}/';
    HttpRequest get() => HttpRequest(url, 'GET', Headers(), null, null);

    final first = closableUnaryHttpClient();
    expect((await first.client(get())).status, 200);
    first.close();

    // A closed pool must not serve a later call.
    await expectLater(first.client(get()), throwsA(isA<Object>()));

    // A fresh pool still works, so closing one does not break the next.
    final second = closableUnaryHttpClient();
    expect((await second.client(get())).status, 200);
    second.close();
  });

  // A stream supervisor rebuilds on an HTTP/2 fault that says nothing about a
  // healthy unary call. A force close aborted that call, and most callers do
  // not retry.
  test('a close lets a request in flight finish', () async {
    final release = Completer<void>();
    final server = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      await release.future;
      await req.response.close();
    });
    addTearDown(() => server.close(force: true));

    final url = 'http://127.0.0.1:${server.port}/';
    final pool = closableUnaryHttpClient();

    final inFlight = pool.client(HttpRequest(url, 'GET', Headers(), null, null));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    pool.close();

    release.complete();
    expect((await inFlight).status, 200);

    // The retired pool still refuses new work.
    await expectLater(
      pool.client(HttpRequest(url, 'GET', Headers(), null, null)),
      throwsA(isA<Object>()),
    );
  });
}
