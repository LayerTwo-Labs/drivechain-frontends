import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart' as app;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BitWindow starts and shows the app', (tester) async {
    final errorHandler = FlutterError.onError;
    final errorBuilder = ErrorWidget.builder;
    try {
      final (dir, logFile, log) = await app.init('');
      final binaries = GetIt.I.get<BinaryProvider>();
      binaries.binaries.whereType<BitWindow>().single.extraBootArgs = [
        '--api.host=${Environment.bitwindowdHost.value}:${Environment.bitwindowdPort.value}',
        '--orchestrator.addr=http://${Environment.orchestratorHost.value}:${Environment.orchestratorPort.value}',
      ];
      addTearDown(binaries.onShutdown);
      await app.runMainWindow(log, dir, logFile);

      for (var step = 0; step < 30; step++) {
        await tester.pump(const Duration(seconds: 2));
        final finder = find.byType(app.BitwindowApp);
        if (tester.any(finder) && tester.widget<app.BitwindowApp>(finder).backendReady.value) {
          break;
        }
      }

      final finder = find.byType(app.BitwindowApp);
      expect(finder, findsOneWidget);
      expect(tester.widget<app.BitwindowApp>(finder).backendReady.value, isTrue);
      expect(find.textContaining('Initialization failed'), findsNothing);
      expect((await GetIt.I.get<OrchestratorRPC>().listBinaries()).binaries, isNotEmpty);
      expect(await GetIt.I.get<BitwindowRPC>().bitwindowd.listAddressBook(), isA<List<AddressBookEntry>>());
    } finally {
      FlutterError.onError = errorHandler;
      ErrorWidget.builder = errorBuilder;
    }
  });
}
