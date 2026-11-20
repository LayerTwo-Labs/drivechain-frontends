import 'package:fixnum/fixnum.dart';
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
}
