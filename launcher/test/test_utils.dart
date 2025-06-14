import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/providers/quotes_provider.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/download_manager_mock.dart';
import 'mocks/quotes_provider_mock.dart';
import 'mocks/storage_mock.dart';
import 'test_page.dart';

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
      ChangeNotifierProvider<QuotesProvider>.value(
        value: GetIt.I.get<QuotesProvider>(),
        child: SailApp(
          dense: false,
          builder: (context) {
            return MaterialApp(home: SailTestPage(child: child));
          },
          initMethod: (_) async => (),
          accentColor: SailColorScheme.black,
          log: GetIt.I.get<Logger>(),
        ),
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
    GetIt.I.registerLazySingleton<ClientSettings>(
      () => ClientSettings(store: MockStore(), log: log),
    );
  }

  if (!GetIt.I.isRegistered<MainchainRPC>()) {
    GetIt.I.registerLazySingleton<MainchainRPC>(
      () => MockMainchainRPC(),
    );
  }

  if (!GetIt.I.isRegistered<EnforcerRPC>()) {
    GetIt.I.registerLazySingleton<EnforcerRPC>(
      () => MockEnforcerRPC(),
    );
  }

  if (!GetIt.I.isRegistered<BitwindowRPC>()) {
    GetIt.I.registerLazySingleton<BitwindowRPC>(
      () => MockBitwindowRPC(),
    );
  }

  if (!GetIt.I.isRegistered<ThunderRPC>()) {
    GetIt.I.registerLazySingleton<ThunderRPC>(
      () => MockThunderRPC(),
    );
  }

  if (!GetIt.I.isRegistered<BitnamesRPC>()) {
    GetIt.I.registerLazySingleton<BitnamesRPC>(
      () => MockBitnamesRPC(),
    );
  }

  if (!GetIt.I.isRegistered<SyncProgressProvider>()) {
    GetIt.I.registerLazySingleton<SyncProgressProvider>(
      () => MockBlockInfoProvider(),
    );
  }

  if (!GetIt.I.isRegistered<BinaryProvider>()) {
    GetIt.I.registerLazySingleton<BinaryProvider>(
      () => MockDownloadProvider(),
    );
  }

  if (!GetIt.I.isRegistered<QuotesProvider>()) {
    GetIt.I.registerLazySingleton<QuotesProvider>(
      () => MockQuotesProvider(),
    );
  }

  if (!GetIt.I.isRegistered<WalletService>()) {
    GetIt.I.registerLazySingleton<WalletService>(
      () => WalletService(),
    );
  }
}
