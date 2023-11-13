import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/theme/theme_data.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sail_ui/widgets/core/scaffold.dart';
import 'package:sail_ui/widgets/loading_indicator.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/providers/proc_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/sail_settings/theme_settings.dart';

class SailApp extends StatefulWidget {
  // This key is used to programmatically trigger a rebuild of the MyApp widget.
  static GlobalKey<SailAppState> sailAppKey = GlobalKey();

  final Widget Function(BuildContext context, AppRouter router) builder;

  SailApp({
    required this.builder,
  }) : super(key: sailAppKey);

  @override
  State<SailApp> createState() => SailAppState();

  static SailAppState of(BuildContext context) {
    final SailAppState? result = context.findAncestorStateOfType<SailAppState>();
    if (result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'SailAppState.of() called with a context that does not contain a SailApp.',
      ),
    ]);
  }
}

class SailAppState extends State<SailApp> with WidgetsBindingObserver {
  AppRouter get router => GetIt.I.get<AppRouter>();
  SidechainRPC get _sidechain => GetIt.I.get<SidechainRPC>();
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  ProcessProvider get processes => GetIt.I.get<ProcessProvider>();
  final settings = GetIt.I.get<ClientSettings>();

  /// Unrecoverable error on startup we can't get past.
  dynamic _initBinariesError;
  String mainchainStartupMessage = "Checking if 'drivechaind' is started";
  bool binariesStarted = false;
  SailThemeData? theme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(loadTheme());
    unawaited(initBinaries());
  }

  void rebuildUI() {
    setState(() {
      // This is a workaround to trigger the root widget to rebuild.
      SailApp.sailAppKey = GlobalKey();
    });
  }

  SailThemeData _themeDataFromTheme(SailThemeValues theme) {
    switch (theme) {
      case SailThemeValues.light:
        return SailThemeData.lightTheme(_sidechain.chain.color);
      case SailThemeValues.dark:
        return SailThemeData.darkTheme(_sidechain.chain.color);
      default:
        throw Exception('Could not get theme');
    }
  }

  Future<void> initBinaries() async {
    log.d('init binaries: checking mainchain connection');

    // First, let the mainchain connection check finish.
    await mainchain.initDone;

    // If we managed to connect, we're finished here!
    if (mainchain.connected) {
      log.d('init binaries: mainchain is already running, not doing anything');
      setState(() {
        binariesStarted = true;
      });
      return;
    }

    // We have to start the mainchain
    final tempDir = await Directory.systemTemp.createTemp('drivechaind');
    final tempLogFile = await File('${tempDir.path}/drivechaind.debug.log').create(recursive: true);

    if (!context.mounted) {
      return;
    }

    final args = [
      '-debuglogfile=${tempLogFile.path}',
      '-regtest',
    ];

    log.d('init binaries: starting drivechaind $args');

    try {
      final pid = await processes.start(context, 'drivechaind', args);
      log.d('init binaries: started drivechaind with PID $pid');
      setState(() {
        mainchainStartupMessage = "Started 'drivechaind', waiting for successful RPC connection";
      });
    } catch (err) {
      log.w('init binaries: unable to start drivechaind', error: err);
      return setState(() {
        _initBinariesError = err;
      });
    }

    // Add timeout?
    log.i('init binaries: waiting for mainchain connection');
    await waitForBoolToBeTrue(() async {
      final (connected, _) = await mainchain.testConnection();
      return connected;
    });

    log.i('init binaries: mainchain connected');
    return setState(() {
      binariesStarted = true;
    });
  }

  Future<void> loadTheme([SailThemeValues? themeToLoad]) async {
    themeToLoad ??= (await settings.getValue(ThemeSetting())).value;
    if (themeToLoad == SailThemeValues.platform) {
      // ignore: deprecated_member_use
      themeToLoad = WidgetsBinding.instance.window.platformBrightness == Brightness.light //
          ? SailThemeValues.light
          : SailThemeValues.dark;
    }

    theme = _themeDataFromTheme(themeToLoad);

    setState(() {});
    await settings.setValue(ThemeSetting(newValue: themeToLoad));
  }

  bool get inInitialSetup => theme == null || !binariesStarted;

  Widget loadingIndicator() {
    if (!binariesStarted) {
      return SailColumn(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: SailStyleValues.padding25,
        children: [
          SailText.primary20('Mainchain starting up: $mainchainStartupMessage'),
          const SailCircularProgressIndicator(),
        ],
      );
    }
    return const SailCircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    if (inInitialSetup) {
      return MaterialApp(
        home: Material(
          color: _sidechain.chain.color,
          child: SailTheme(
            data: SailThemeData.lightTheme(_sidechain.chain.color),
            child: SailScaffold(
              body: Center(
                // TODO: better error message with troubleshooting tips here
                child: _initBinariesError != null
                    ? SailText.primary24('Ran into unrecoverable error on startup: $_initBinariesError')
                    : loadingIndicator(),
              ),
            ),
          ),
        ),
      );
    }

    return SailTheme(
      data: theme!,
      child: widget.builder(context, router),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

Future<void> waitForBoolToBeTrue(
  Future<bool> Function() boolGetter, {
  Duration pollInterval = const Duration(milliseconds: 100),
}) async {
  bool result = await boolGetter();
  if (!result) {
    await Future.delayed(pollInterval);
    await waitForBoolToBeTrue(boolGetter, pollInterval: pollInterval);
  }
}
