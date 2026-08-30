import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pbenum.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger());
    }
  });

  // BMMProvider captures OrchestratorRPC.bmm once and holds it for the life of
  // the app. A rebuild that swapped the wrapper left that copy pointed at a
  // pool nobody could reach, and closing the pool broke it for good.
  test('a captured client still reaches the daemon after a rebuild', () async {
    var requests = 0;
    final server = await io.HttpServer.bind(io.InternetAddress.loopbackIPv4, 0);
    server.listen((req) {
      requests++;
      req.response.statusCode = 500;
      req.response.close();
    });
    addTearDown(() => server.close(force: true));

    final rpc = OrchestratorRPC(host: '127.0.0.1', port: server.port);
    final captured = rpc.bmm;

    await expectLater(captured.stop(BinaryType.BINARY_TYPE_THUNDER), throwsA(isA<Object>()));
    expect(requests, 1);

    rpc.recreateConnection();

    expect(identical(captured, rpc.bmm), isTrue, reason: 'a rebuild must not swap the wrapper');
    await expectLater(captured.stop(BinaryType.BINARY_TYPE_THUNDER), throwsA(isA<Object>()));
    expect(requests, 2, reason: 'the captured client must reach the daemon through the new pool');
  });
}
