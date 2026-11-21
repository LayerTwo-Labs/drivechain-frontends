import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _Orchestrator implements OrchestratorRPC {
  List<BinaryStatusMsg> statuses = [];

  @override
  Future<ListBinariesResponse> listBinaries({bool forceBackend = false}) async =>
      ListBinariesResponse(binaries: statuses);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Binaries extends ChangeNotifier implements BinaryProvider {
  @override
  List<Binary> binaries = [Drivechaind()];

  @override
  bool isInitializing(Binary binary) => false;

  @override
  bool isStopping(Binary binary) => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => GetIt.I.registerSingleton<Logger>(Logger(level: Level.off)));
  tearDown(() => GetIt.I.reset());

  test('a poll that only moves the uptime does not notify', () async {
    final orchestrator = _Orchestrator();
    final backend = BackendStateProvider(orchestrator);
    var notifies = 0;
    backend.addListener(() => notifies++);

    orchestrator.statuses = [BinaryStatusMsg(name: 'enforcer', running: true, uptimeSeconds: Int64(1))];
    await backend.poll();
    expect(notifies, 1);

    orchestrator.statuses = [BinaryStatusMsg(name: 'enforcer', running: true, uptimeSeconds: Int64(2))];
    await backend.poll();
    expect(notifies, 1);

    orchestrator.statuses = [BinaryStatusMsg(name: 'enforcer', running: false, uptimeSeconds: Int64(3))];
    await backend.poll();
    expect(notifies, 2);
  });

  test('a poll of a stopped binary with no uptime does not notify', () async {
    final orchestrator = _Orchestrator();
    final backend = BackendStateProvider(orchestrator);
    var notifies = 0;
    backend.addListener(() => notifies++);

    orchestrator.statuses = [BinaryStatusMsg(name: 'thunder', downloadable: true)];
    await backend.poll();
    await backend.poll();
    expect(notifies, 1);
  });

  test('a watch frame that only moves the uptime or beats does not notify', () async {
    final backend = BackendStateProvider(_Orchestrator());
    var notifies = 0;
    backend.addListener(() => notifies++);

    backend.applyWatchFrame(
      WatchBinariesResponse(
        binaries: [BinaryStatusMsg(name: 'enforcer', running: true, uptimeSeconds: Int64(1))],
      ),
    );
    expect(notifies, 1);

    backend.applyWatchFrame(WatchBinariesResponse(heartbeat: true));
    backend.applyWatchFrame(
      WatchBinariesResponse(
        binaries: [BinaryStatusMsg(name: 'enforcer', running: true, uptimeSeconds: Int64(9))],
      ),
    );
    expect(notifies, 1);
    expect(backend.binaries['enforcer']!.running, isTrue);

    backend.applyWatchFrame(WatchBinariesResponse(binaries: [BinaryStatusMsg(name: 'enforcer')]));
    expect(notifies, 2);
  });

  test('a starting orchestrator reads as initializing until a poll answers', () async {
    final orchestrator = _Orchestrator();
    final backend = BackendStateProvider(orchestrator)..starting = true;
    final drivechaind = DrivechaindState(binaries: _Binaries(), backend: backend);

    expect(drivechaind.connected, isFalse);
    expect(drivechaind.initializingBinary, isTrue);
    expect(drivechaind.connectionError, isNull);

    await backend.poll();
    expect(backend.starting, isFalse);
    expect(drivechaind.connected, isTrue);
  });

  test('an orchestrator that never answers ends the start', () async {
    final backend = BackendStateProvider(_DownOrchestrator())..starting = true;
    final drivechaind = DrivechaindState(binaries: _Binaries(), backend: backend);

    for (var i = 0; i < 5; i++) {
      await backend.poll();
    }
    expect(backend.starting, isFalse);
    expect(drivechaind.connectionError, isNotNull);
  });
}

class _DownOrchestrator implements OrchestratorRPC {
  @override
  Future<ListBinariesResponse> listBinaries({bool forceBackend = false}) async => throw StateError('down');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
