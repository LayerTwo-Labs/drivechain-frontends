import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/sail_test_page.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/storage_mock.dart';

Future<void> _setDeviceSize() async {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  await binding.setSurfaceSize(const Size(1200, 720));
}

extension TestExtension on WidgetTester {
  Future<void> pumpSailPage(
    Widget child,
  ) async {
    await _setDeviceSize();
    await registerTestDependencies();

    await pumpWidget(
      SailApp(
        dense: false,
        builder: (context) {
          return MaterialApp(home: SailTestPage(child: child));
        },
        initMethod: (_) async => (),
        accentColor: SailColorScheme.black,
        log: GetIt.I.get<Logger>(),
      ),
      duration: const Duration(seconds: 10),
    );
    await pump();
  }
}

Future<void> registerTestDependencies() async {
  final log = Logger();
  if (!GetIt.I.isRegistered<Logger>()) {
    GetIt.I.registerLazySingleton<Logger>(() => log);
  }

  if (!GetIt.I.isRegistered<ClientSettings>()) {
    GetIt.I.registerLazySingleton<ClientSettings>(
      () => ClientSettings(store: MockStore(), log: log),
    );
  }

  if (!GetIt.I.isRegistered<BitwindowClientSettings>()) {
    GetIt.I.registerLazySingleton<BitwindowClientSettings>(
      () => BitwindowClientSettings(store: MockStore(), log: log),
    );
  }

  if (!GetIt.I.isRegistered<SettingsProvider>()) {
    final settingsProvider = await SettingsProvider.create();
    GetIt.I.registerLazySingleton<SettingsProvider>(
      () => settingsProvider,
    );
  }

  if (!GetIt.I.isRegistered<FormatterProvider>()) {
    GetIt.I.registerLazySingleton<FormatterProvider>(
      () => FormatterProvider(GetIt.I.get<SettingsProvider>()),
    );
  }

  if (!GetIt.I.isRegistered<BinaryProvider>()) {
    GetIt.I.registerLazySingleton<BinaryProvider>(
      () => MockBinaryProvider(),
    );
  }
}
