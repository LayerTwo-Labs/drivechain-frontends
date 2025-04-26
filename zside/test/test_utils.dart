import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/routing/router.dart';

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
            title: 'ZSide',
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
}
