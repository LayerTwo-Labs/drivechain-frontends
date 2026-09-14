import 'dart:convert';
import 'dart:io';

import 'package:connectrpc/connect.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';

void main() {
  setUp(() {
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
  });

  tearDown(GetIt.I.reset);

  test(
    'the migration client sends network IDs and reads each status',
    () async {
      final previewStatus = ECashMigrationStatus(
        fromId: 'alphanet',
        toId: 'betanet',
        phase: 'preview',
        dataDir: '/tmp/ecash',
        commonHeight: Int64(900000),
        commonHash: 'ab' * 32,
        sourceMagic: 'eca5a104',
        targetMagic: 'eca5b104',
        blockFiles: Int64(1200),
        undoFiles: Int64(1200),
        recordsTotal: Int64.parseInt('9007199254740993'),
        pruned: true,
        pruneHeight: Int64(800000),
      );
      final startStatus = ECashMigrationStatus(
        jobId: 'migration-1',
        fromId: 'alphanet',
        toId: 'betanet',
        phase: 'prepare',
        running: true,
      );
      final completeStatus = ECashMigrationStatus(
        jobId: 'migration-1',
        fromId: 'alphanet',
        toId: 'betanet',
        phase: 'complete',
        recordsDone: Int64(2400),
        recordsTotal: Int64(2400),
        complete: true,
        syncState: 'syncing',
      );
      final responses = {
        '/orchestrator.v1.OrchestratorService/PreviewECashMigration': PreviewECashMigrationResponse(
          status: previewStatus,
        ).writeToBuffer(),
        '/orchestrator.v1.OrchestratorService/StartECashMigration': StartECashMigrationResponse(
          status: startStatus,
        ).writeToBuffer(),
        '/orchestrator.v1.OrchestratorService/GetECashMigrationStatus': GetECashMigrationStatusResponse(
          status: completeStatus,
        ).writeToBuffer(),
      };
      final requests = <({String method, String path, List<int> body})>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        final body = await request.fold(
          <int>[],
          (bytes, part) => bytes..addAll(part),
        );
        requests.add((
          method: request.method,
          path: request.uri.path,
          body: body,
        ));
        final response = responses[request.uri.path];
        if (response == null) {
          request.response.statusCode = HttpStatus.notFound;
        } else {
          request.response.headers.contentType = ContentType(
            'application',
            'proto',
          );
          request.response.add(response);
        }
        await request.response.close();
      });
      final rpc = OrchestratorRPC(host: '127.0.0.1', port: server.port);

      final preview = await rpc.previewECashMigration(
        fromId: 'alphanet',
        toId: 'betanet',
      );
      final start = await rpc.startECashMigration(
        fromId: 'alphanet',
        toId: 'betanet',
      );
      final status = await rpc.getECashMigrationStatus();

      expect(preview.status, previewStatus);
      expect(start.status, startStatus);
      expect(status.status, completeStatus);
      expect(requests.map((request) => request.path), responses.keys);
      expect(requests.map((request) => request.method), everyElement('POST'));
      final previewRequest = PreviewECashMigrationRequest.fromBuffer(
        requests[0].body,
      );
      expect(previewRequest.fromId, 'alphanet');
      expect(previewRequest.toId, 'betanet');
      final startRequest = StartECashMigrationRequest.fromBuffer(
        requests[1].body,
      );
      expect(startRequest.fromId, 'alphanet');
      expect(startRequest.toId, 'betanet');
      expect(
        GetECashMigrationStatusRequest.fromBuffer(requests[2].body),
        GetECashMigrationStatusRequest(),
      );
    },
  );

  test('each migration call returns the daemon error', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    var requests = 0;
    server.listen((request) async {
      requests++;
      await request.drain<void>();
      request.response.statusCode = HttpStatus.badRequest;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'code': 'failed_precondition',
          'message': 'The migration cannot start.',
        }),
      );
      await request.response.close();
    });
    final rpc = OrchestratorRPC(host: '127.0.0.1', port: server.port);
    final error = throwsA(
      isA<ConnectException>()
          .having((error) => error.code, 'code', Code.failedPrecondition)
          .having(
            (error) => error.message,
            'message',
            'The migration cannot start.',
          ),
    );

    await expectLater(
      rpc.previewECashMigration(fromId: 'alphanet', toId: 'betanet'),
      error,
    );
    await expectLater(
      rpc.startECashMigration(fromId: 'alphanet', toId: 'betanet'),
      error,
    );
    await expectLater(rpc.getECashMigrationStatus(), error);
    expect(requests, 3);
  });
}
