import 'package:faucet/api/api_base.dart';
import 'package:faucet/providers/transactions_provider.dart';
import 'package:faucet/test_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';
import 'mocks/mock_transactions_provider.dart';
import 'mocks/storage_mock.dart';

Future<void> _setDeviceSize() async {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  await binding.setSurfaceSize(const Size(1200, 720));
}

extension TestExtension on WidgetTester {
  Future<void> pumpSailPage(Widget child) async {
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
    );
    await pumpAndSettle();
  }
}

Future<void> registerTestDependencies() async {
  final log = Logger();
  if (!GetIt.I.isRegistered<Logger>()) {
    GetIt.I.registerLazySingleton<Logger>(() => log);
  }

  if (!GetIt.I.isRegistered<ClientSettings>()) {
    GetIt.I.registerLazySingleton<ClientSettings>(() => ClientSettings(store: MockStore(), log: log));
  }

  if (!GetIt.I.isRegistered<SettingsProvider>()) {
    final settingsProvider = await SettingsProvider.create();
    GetIt.I.registerLazySingleton<SettingsProvider>(() => settingsProvider);
  }

  if (!GetIt.I.isRegistered<API>()) {
    GetIt.I.registerLazySingleton<API>(() => MockAPI());
  }

  if (!GetIt.I.isRegistered<TransactionsProvider>()) {
    GetIt.I.registerLazySingleton<TransactionsProvider>(() => MockTransactionsProvider());
  }
}
