import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/providers/config_provider.dart';
import 'package:launcher/providers/download_provider.dart';
import 'package:launcher/providers/quotes_provider.dart';
import 'package:launcher/providers/resource_downloader.dart';
import 'package:provider/provider.dart';
import 'package:launcher/routing/router.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final log = Logger();
  final router = AppRouter();
  await initDependencies(log);

  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    minimumSize: Size(600, 700),
    titleBarStyle: TitleBarStyle.normal,
    title: 'Drivechain Launcher',
  );

  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    }),
  );

  return runApp(
    ChangeNotifierProvider(
      create: (_) => GetIt.I.get<QuotesProvider>(),
      child: SailApp(
        dense: true,
        builder: (context) {
          return MaterialApp.router(
          routerDelegate: router.delegate(),
          routeInformationParser: router.defaultRouteParser(),
          title: 'Drivechain Launcher',
          builder: (context, child) => child ?? const SizedBox(),
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            fontFamily: 'Inter',
          ),
        );
      },
      accentColor: const Color.fromARGB(255, 255, 153, 0),
      log: log,
    )),
  );
}

Future<void> initDependencies(Logger log) async {
  final prefs = await SharedPreferences.getInstance();

  // Register the logger
  GetIt.I.registerLazySingleton<Logger>(() => log);

  // Needed for sidesail_ui to work
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: Storage(
        preferences: prefs,
      ),
      log: log,
    ),
  );

  // Register configuration service
  final configProvider = ConfigProvider();
  GetIt.I.registerSingleton<ConfigProvider>(
    configProvider,
  );
  await configProvider.initialize();

  // Register resource downloader
  GetIt.I.registerSingleton<ResourceDownloader>(
    ResourceDownloader(),
  );

  // Register download manager
  final downloadProvider = DownloadProvider();
  GetIt.I.registerSingleton<DownloadProvider>(
    downloadProvider,
  );
  await downloadProvider.initialize();

  // Register quotes provider
  GetIt.I.registerSingleton<QuotesProvider>(
    QuotesProvider(prefs),
  );
}
