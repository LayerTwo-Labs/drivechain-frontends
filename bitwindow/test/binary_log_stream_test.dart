import 'package:bitwindow/main.dart';
import 'package:fake_async/fake_async.dart';
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
}

class _FakeOrchestrator implements OrchestratorRPC {
  final List<String> streams = [];

  /// True to answer one stream that fails and then closes, as a backend that
  /// goes away does.
  bool failFirst = false;

  @override
  Stream<StreamLogsResponse> streamLogs(String name, {int tail = 0}) {
    streams.add(name);
    if (failFirst) {
      failFirst = false;
      return Stream<StreamLogsResponse>.error(Exception('the backend went away'));
    }
    return const Stream<StreamLogsResponse>.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
