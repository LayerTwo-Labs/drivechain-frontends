import 'package:bitwindow/pages/debug_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _Binaries extends ChangeNotifier implements BinaryProvider {
  @override
  List<Binary> binaries = [BitWindow(), Drivechaind()];

  @override
  bool isConnected(Binary binary) => binary is BitWindow;

  @override
  bool isInitializing(Binary binary) => false;

  @override
  bool isStopping(Binary binary) => false;

  @override
  String? connectionError(Binary binary) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Backend extends ChangeNotifier implements BackendStateProvider {
  _Backend({required this.orchestratorReachable});

  @override
  bool orchestratorReachable;

  @override
  bool orchestratorAnswered = true;

  @override
  bool starting = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(() => GetIt.I.reset());

  Future<String> drivechaindStatus(WidgetTester tester, {required bool reachable}) async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<BinaryProvider>(_Binaries());
    GetIt.I.registerSingleton<BackendStateProvider>(_Backend(orchestratorReachable: reachable));
    await tester.pumpSailPage(const ProcessesTab());
    await tester.pump();
    final cells = tester.widgetList<SailTableCell>(find.byType(SailTableCell)).map((c) => c.value).toList();
    const statusColumn = 3;
    return cells[cells.indexOf(Drivechaind().name) + statusColumn];
  }

  testWidgets('drivechaind reads as connected when the orchestrator answers', (tester) async {
    expect(await drivechaindStatus(tester, reachable: true), 'Connected');
  });

  testWidgets('drivechaind reads as disconnected when the orchestrator is silent', (tester) async {
    expect(await drivechaindStatus(tester, reachable: false), 'Disconnected');
  });
}
