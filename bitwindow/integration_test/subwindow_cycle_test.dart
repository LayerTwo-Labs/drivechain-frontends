import 'package:bitwindow/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sail_ui/sail_ui.dart';

const _cycles = int.fromEnvironment('CYCLES', defaultValue: 10);

void main(List<String> args) {
  // Each sub-window engine runs this entrypoint with its window arguments.
  if (args.isNotEmpty && args.first == 'multi_window') {
    app.main(args);
    return;
  }

  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('sub-windows open and close with no crash', (t) async {
    app.main([]);
    for (var i = 0; i < 1200 && find.text('Wallet').evaluate().isEmpty; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Wallet'), findsWidgets);
    await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 5)));

    final windows = GetIt.I.get<WindowProvider>();
    final types = [
      app.SubWindowTypes.addressbook,
      app.SubWindowTypes.hashCalculator,
      app.SubWindowTypes.converter,
      app.SubWindowTypes.blockExplorer,
      app.SubWindowTypes.messageSigner,
    ];
    for (var cycle = 1; cycle <= _cycles; cycle++) {
      for (final type in types) {
        final info = await t.runAsync(() => windows.open(type));
        expect(info, isNotNull);
        await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
        await t.pump();
        final closed = await t.runAsync(() => windows.close(info!.id));
        expect(closed, isTrue);
        await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 1)));
        await t.pump();
      }
    }
  });
}
