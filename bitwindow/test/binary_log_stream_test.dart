import 'package:bitwindow/main.dart';
import 'package:fake_async/fake_async.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

// A recovery boot ran the whole boot again, and every run opened one more log
// stream. The log page then held every line twice.
void main() {
  late _FakeOrchestrator orchestrator;
  late Logger log;

  setUp(() async {
    await GetIt.I.reset();
    forgetBinaryLogStreams();
    log = Logger(level: Level.off);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<LogProvider>(LogProvider());
    orchestrator = _FakeOrchestrator();
  });

  tearDown(() async {
    forgetBinaryLogStreams();
    await GetIt.I.reset();
  });

  test('one binary gets one log stream, over two boots', () {
    streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.BINARY_TYPE_BITCOIND, log);
    streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.BINARY_TYPE_BITCOIND, log);

    expect(orchestrator.streams, ['bitcoind']);
  });

  test('a stream that ends opens again, so the log page keeps its lines', () {
    fakeAsync((async) {
      streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.BINARY_TYPE_BITCOIND, log);
      async.flushMicrotasks();
      expect(orchestrator.streams, ['bitcoind']);

      async.elapse(const Duration(seconds: 6));
      expect(orchestrator.streams, ['bitcoind', 'bitcoind']);
    });
  });

  test('an error and a close open one stream, not two', () {
    fakeAsync((async) {
      orchestrator.failFirst = true;
      streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.BINARY_TYPE_BITCOIND, log);
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 6));
      expect(orchestrator.streams, ['bitcoind', 'bitcoind']);
    });
  });

  test('every binary gets its own log stream', () {
    streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.BINARY_TYPE_BITCOIND, log);
    streamBinaryLogs(orchestrator, 'enforcer', BinaryType.BINARY_TYPE_ENFORCER, log);

    expect(orchestrator.streams, ['bitcoind', 'enforcer']);
  });

  test('a retry sends the last cursor and keeps the tail for a new run', () {
    fakeAsync((async) {
      orchestrator.outputs['bitcoind'] = [
        [
          StreamLogsResponse(runId: 'first', sequence: Int64(7), line: 'same line'),
          StreamLogsResponse(runId: 'first', sequence: Int64(8), line: 'same line'),
        ],
        [StreamLogsResponse(runId: 'second', sequence: Int64(1), line: 'startup line')],
      ];
      streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.BINARY_TYPE_BITCOIND, log);
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 5));
      expect(orchestrator.requests[1].runId, 'first');
      expect(orchestrator.requests[1].afterSequence, Int64(8));
      expect(orchestrator.requests[1].tail, 100);

      async.elapse(const Duration(seconds: 5));
      expect(orchestrator.requests[2].runId, 'second');
      expect(orchestrator.requests[2].afterSequence, Int64(1));
      expect(orchestrator.requests[2].tail, 100);
      expect(
        GetIt.I.get<LogProvider>().getLogsForBinary(BinaryType.BINARY_TYPE_BITCOIND).map((entry) => entry.message),
        ['same line', 'same line', 'startup line'],
      );
    });
  });

  test('each binary keeps its own cursor', () {
    fakeAsync((async) {
      orchestrator.outputs['bitcoind'] = [
        [StreamLogsResponse(runId: 'core', sequence: Int64(4))],
      ];
      orchestrator.outputs['enforcer'] = [
        [StreamLogsResponse(runId: 'enforcer', sequence: Int64(12))],
      ];
      streamBinaryLogs(orchestrator, 'bitcoind', BinaryType.BINARY_TYPE_BITCOIND, log);
      streamBinaryLogs(orchestrator, 'enforcer', BinaryType.BINARY_TYPE_ENFORCER, log);
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 5));

      final core = orchestrator.requests.lastWhere((request) => request.name == 'bitcoind');
      final enforcer = orchestrator.requests.lastWhere((request) => request.name == 'enforcer');
      expect((core.runId, core.afterSequence), ('core', Int64(4)));
      expect((enforcer.runId, enforcer.afterSequence), ('enforcer', Int64(12)));
    });
  });
}

class _FakeOrchestrator implements OrchestratorRPC {
  final List<String> streams = [];
  final requests = <StreamLogsRequest>[];
  final outputs = <String, List<List<StreamLogsResponse>>>{};

  /// True to answer one stream that fails and then closes, as a backend that
  /// goes away does.
  bool failFirst = false;

  @override
  Stream<StreamLogsResponse> streamLogs(String name, {int tail = 0, String runId = '', Int64? afterSequence}) {
    streams.add(name);
    requests.add(StreamLogsRequest(name: name, tail: tail, runId: runId, afterSequence: afterSequence));
    if (failFirst) {
      failFirst = false;
      return Stream<StreamLogsResponse>.error(Exception('the backend went away'));
    }
    final batches = outputs[name];
    return Stream<StreamLogsResponse>.fromIterable(batches == null || batches.isEmpty ? [] : batches.removeAt(0));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
