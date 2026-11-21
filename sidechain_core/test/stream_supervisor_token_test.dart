import 'dart:async';
import 'dart:io';

import 'package:connectrpc/connect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/auth/local_auth.dart';
import 'package:sidechain_core/rpcs/stream_supervisor.dart';

void main() {
  test('a rejected token subscribes again at once with the new cookie', () async {
    final dir = await Directory.systemTemp.createTemp('token');
    addTearDown(() => dir.delete(recursive: true));
    final cookie = File('${dir.path}/${LocalAuth.cookieFileName}');
    await cookie.writeAsString('old');
    LocalAuth.configure(dir);
    expect(await LocalAuth.token(), 'old');

    final controllers = <StreamController<int>>[];
    final tokens = <String?>[];
    final supervisor = StreamSupervisor<int>(
      subscribe: () {
        final c = StreamController<int>();
        controllers.add(c);
        unawaited(LocalAuth.token().then(tokens.add));
        return c.stream;
      },
      onEvent: (_) {},
      onTransportDeath: () {},
      logger: Logger(level: Level.off),
      tag: 'test',
    );
    supervisor.start();

    // Two failures while the daemon is down raise the backoff to 500 ms.
    for (var i = 0; i < 2; i++) {
      controllers.last.addError(StateError('connection refused'));
      final count = controllers.length;
      while (controllers.length == count) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
    }

    await cookie.writeAsString('new');
    controllers.last.addError(ConnectException(Code.unauthenticated, LocalAuth.tokenRejectedMessage));
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(controllers, hasLength(4), reason: 'the subscribe after a rejected token waits for no backoff');
    expect(tokens.last, 'new');
    await supervisor.dispose();
  });
}
