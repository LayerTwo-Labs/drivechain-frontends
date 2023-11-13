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
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/providers/proc_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:sidesail/rpc/rpc_config.dart';
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
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  ProcessProvider get processes => GetIt.I.get<ProcessProvider>();
  final settings = GetIt.I.get<ClientSettings>();

  /// Unrecoverable error on startup we can't get past.
  dynamic _initBinariesError;
  String mainchainStartupMessage = 'Checking if mainchain is started';
  String sidechainStartupMessage = 'Checking if sidechain is started';
  bool binariesStarted = false;
  SailThemeData? theme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(loadTheme());
    unawaited(
      initRPCs().then(
        (_) => Future.wait([
          initMainchainBinary(),
          initSidechainBinary(),
          // let the spinner work for at least one second, to avoid flickering
          Future.delayed(const Duration(seconds: 1)),
        ])
            .then(
              (_) => setState(() {
                binariesStarted = true;
              }),
            )
            .onError(
              (error, stackTrace) => setState(() {
                _initBinariesError = error.toString();
              }),
            ),
      ),
    );
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
        return SailThemeData.lightTheme(_sidechain.rpc.chain.color);
      case SailThemeValues.dark:
        return SailThemeData.darkTheme(_sidechain.rpc.chain.color);
      default:
        throw Exception('Could not get theme');
    }
  }

  Future<void> initRPCs() async {
    // Not ideal, but fuck it
    if (RuntimeArgs.isInTest) {
      return;
    }

    final mainchainFut = readRpcConfig(mainchainDatadir(), 'drivechain.conf', null).then(
      (conf) async {
        log.d('read mainchain RPC configuration');
        mainchain.conf = conf;
        final (connected, connectionError) = await mainchain.testConnection();

        if (!connected) {
          log.w('mainchain NOT connected: $connectionError');
        } else {
          log.d('mainchain connected');
        }
      },
    );

    final sidechainFut = readRpcConfig(
      _sidechain.rpc.chain.type.datadir(),
      _sidechain.rpc.chain.type.confFile(),
      _sidechain.rpc.chain,
    ).then((conf) async {
      log.d('read sidechain RPC configuration');
      _sidechain.rpc.conf = conf;

      final (connected, connectionError) = await _sidechain.rpc.testConnection();
      if (!connected) {
        log.w('sidechain NOT connected: $connectionError');
      } else {
        log.d('sidechain connected');
      }
    });

    await Future.wait([mainchainFut, sidechainFut]);
  }

  Future<void> initMainchainBinary() async {
    return _initBinary('drivechaind', mainchain, (msg) {
      setState(
        () {
          mainchainStartupMessage = msg;
        },
      );
    });
  }

  Future<void> initSidechainBinary() async {
    return _initBinary(_sidechain.rpc.chain.binary, _sidechain.rpc, (msg) {
      setState(
        () {
          sidechainStartupMessage = msg;
        },
      );
    });
  }

  Future<void> _initBinary(String binary, RPCConnection conn, void Function(String) updateMsg) async {
    log.d('init binaries: checking $binary connection');

    // First, let the RPC connection check finish.
    await conn.initDone;

    // If we managed to connect, we're finished here!
    if (conn.connected) {
      updateMsg("'$binary' is already running");
      log.d('init binaries: $binary is already running, not doing anything');
      return;
    }

    // We have to start the mainchain
    final tempDir = await Directory.systemTemp.createTemp(binary);
    final tempLogFile = await File('${tempDir.path}/$binary.debug.log').create(recursive: true);

    if (!context.mounted) {
      return;
    }

    // TODO: update this when adding other nodes with different args
    final args = [
      '-debuglogfile=${tempLogFile.path}',
      '-regtest',
    ];

    log.d('init binaries: starting $binary $args');

    try {
      final pid = await processes.start(context, binary, args);
      log.d('init binaries: started $binary with PID $pid');
      updateMsg("Started '$binary', waiting for successful RPC connection");
    } catch (err) {
      throw 'unable to start $binary: $err';
    }

    // Add timeout?
    log.i('init binaries: waiting for $binary connection');
    await waitForBoolToBeTrue(() async {
      final (connected, _) = await conn.testConnection();
      return connected;
    });

    log.i('init binaries: $binary connected');
  }

  Future<void> loadTheme([SailThemeValues? themeToLoad]) async {
    themeToLoad ??= (await settings.getValue(ThemeSetting())).value;
    if (themeToLoad == SailThemeValues.platform) {
      // ignore: deprecated_member_use
      themeToLoad = WidgetsBinding.instance.window.platformBrightness == Brightness.light
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
          SailText.primary20('Sidechain starting up: $sidechainStartupMessage'),
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
          color: _sidechain.rpc.chain.color,
          child: SailTheme(
            data: SailThemeData.lightTheme(_sidechain.rpc.chain.color),
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
