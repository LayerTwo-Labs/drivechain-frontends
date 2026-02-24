import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/voting_provider.dart';
import 'package:truthcoin/routing/router.dart';

import 'mocks/mock_truthcoin_rpc.dart';
import 'mocks/storage_mock.dart';

Future<void> _setDeviceSize() async {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  await binding.setSurfaceSize(const Size(1200, 720));
}

Future<void> loadFonts() async {
  final inter = rootBundle.load('./assets/fonts/Inter-Regular.ttf');
  final fontLoader = FontLoader('Inter')..addFont(inter);
  await fontLoader.load();
}

extension TestExtension on WidgetTester {
  Future<void> pumpSailPage(
    Widget child,
  ) async {
    await _setDeviceSize();
    await loadFonts();
    await registerTestDependencies();

    await pumpWidget(
      SailApp(
        dense: false,
        builder: (context) {
          final appRouter = GetIt.I.get<AppRouter>();

          return MaterialApp.router(
            routerDelegate: appRouter.delegate(
              // ignore: deprecated_member_use
              deepLinkBuilder: (_) => DeepLink([SailTestRoute(child: child)]),
            ),
            routeInformationParser: appRouter.defaultRouteParser(),
            title: 'Truthcoin',
            theme: ThemeData(
              fontFamily: 'Inter',
            ),
          );
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
  if (!GetIt.I.isRegistered<AppRouter>()) {
    GetIt.I.registerLazySingleton<AppRouter>(
      () => AppRouter(),
    );
  }
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

  if (!GetIt.I.isRegistered<BinaryProvider>()) {
    GetIt.I.registerLazySingleton<BinaryProvider>(
      () => MockBinaryProvider(),
    );
  }

  if (!GetIt.I.isRegistered<FormatterProvider>()) {
    final settings = GetIt.I.get<SettingsProvider>();
    GetIt.I.registerLazySingleton<FormatterProvider>(
      () => FormatterProvider(settings),
    );
  }
}

/// Setup for market and voting tests with controllable mock RPC.
/// Returns the mock RPC so tests can configure responses.
Future<TestTruthcoinRPC> setupMarketVotingTests() async {
  await resetGetIt();

  // Register Logger first - many providers depend on it
  final log = Logger(level: Level.off);
  GetIt.I.registerLazySingleton<Logger>(() => log);

  final mockRpc = TestTruthcoinRPC();

  GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
  GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);

  GetIt.I.registerLazySingleton<AppRouter>(() => AppRouter());

  // Register ClientSettings before SettingsProvider
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(store: MockStore(), log: log),
  );

  GetIt.I.registerLazySingleton<BitwindowClientSettings>(
    () => BitwindowClientSettings(store: MockStore(), log: log),
  );

  // Create settings provider
  final settingsProvider = await SettingsProvider.create();
  GetIt.I.registerLazySingleton<SettingsProvider>(() => settingsProvider);

  final formatter = FormatterProvider(settingsProvider);
  GetIt.I.registerLazySingleton<FormatterProvider>(() => formatter);

  // Now register providers that depend on RPC and Logger
  final marketProvider = MarketProvider();
  GetIt.I.registerLazySingleton<MarketProvider>(() => marketProvider);

  final votingProvider = VotingProvider();
  GetIt.I.registerLazySingleton<VotingProvider>(() => votingProvider);

  return mockRpc;
}

/// Reset GetIt for clean test state
Future<void> resetGetIt() async {
  await GetIt.I.reset();
}

/// Helper to wait for provider to finish loading
Future<void> waitForProvider(ChangeNotifier provider, {Duration timeout = const Duration(seconds: 5)}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await Future.delayed(const Duration(milliseconds: 50));
    // Check if the provider has stopped loading (implementation specific)
    // For now, just a small delay
    if (stopwatch.elapsed > const Duration(milliseconds: 100)) {
      break;
    }
  }
}
