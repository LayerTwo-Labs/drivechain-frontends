import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/theme/theme_data.dart';
import 'package:sail_ui/widgets/core/scaffold.dart';
import 'package:sail_ui/widgets/loading_indicator.dart';
import 'package:sidesail/config/dependencies.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/providers/process_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/active_sidechains.dart';
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
  Logger get log => GetIt.I.get<Logger>();
  ClientSettings get settings => GetIt.I.get<ClientSettings>();
  ProcessProvider get processProvider => GetIt.I.get<ProcessProvider>();

  SailThemeData? theme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(loadTheme());

    // always attempt to start binaries. If we're already
    // connected (handled in dependencies), the start binary
    // function makes sure to not restart it
    _initBinaries();
  }

  void _initBinaries() async {
    // Mainchain must be started properly before attempting the
    // sidechain
    await initMainchainBinary();
    await initSidechainBinary();
  }

  void rebuildUI() {
    setState(() {
      // This is a workaround to trigger the root widget to rebuild.
      SailApp.sailAppKey = GlobalKey();
    });
  }

  Future<void> restartNodes() async {
    // first shut down old nodes
    await processProvider.shutdown();

    try {
      final newConf = await readRPCConfig(mainchainDatadir(), 'drivechain.conf', null);
      // then boot fresh ones, with the user-preferred network
      mainchain.conf = newConf;
      mainchain.connected = false;
      // now set new node conf, hmm
      await initMainchainBinary();
    } catch (error) {
      // do nothing
      log.e('could not reinit mainchain binary ${error.toString()}');
    }

    try {
      final newConf = await findSidechainConf(_sidechain.rpc.chain);
      // then boot fresh ones, with the user-preferred network
      _sidechain.rpc.conf = newConf;
      _sidechain.rpc.connected = false;
      await initSidechainBinary();
    } catch (error) {
      // do nothing
      log.e('could not reinit sidechain binary ${error.toString()}');
    }
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

  Future<void> initMainchainBinary() async {
    await mainchain.initBinary(
      context,
      mainchain.binary,
      bitcoinCoreBinaryArgs(mainchain.conf),
    );

    log.i('mainchain init: mainchain has done inital block download, proceeding');

    log.d('mainchain init: checking if ${_sidechain.rpc.chain.name} is an active sidechain');
    final activeSidechains = await mainchain.listActiveSidechains();
    final ourSidechain = isCurrentChainActive(activeChains: activeSidechains, currentChain: _sidechain.rpc.chain);
    if (ourSidechain) {
      log.i('mainchain init: ${_sidechain.rpc.chain.name} is active');
      return;
    }

    if (!mainchain.conf.isLocalNetwork) {
      log.w('${_sidechain.rpc.chain.name} chain is not active, and we\'re unable to activate it');
      return;
    }

    log.i(
      'mainchain init: we are NOT an active sidechain, creating proposal ${activeSidechains.map((e) => e.toJson())}',
    );

    await mainchain.createSidechainProposal(_sidechain.rpc.chain.slot, _sidechain.rpc.chain.name);

    const numBlocks = 144;
    log.i('mainchain init: generating $numBlocks blocks to broadcast proposal and give user some balance');
    await mainchain.generate(numBlocks);

    log.i('mainchain init: verifying sidechain is active');
    final chains = await mainchain.listActiveSidechains();
    final isActive = isCurrentChainActive(activeChains: chains, currentChain: _sidechain.rpc.chain);
    if (!isActive) {
      log.e(
        'mainchain init: was not able to activate sidechain ${await mainchain.listActiveSidechains().then((xs) => xs.map((chain) => chain.toJson()))}',
      );
      throw 'Was not able to activate sidechain';
    }

    log.i('mainchain init: successfully activated sidechain');
  }

  Future<void> initSidechainBinary() async {
    return _sidechain.rpc.initBinary(
      context,
      _sidechain.rpc.chain.binary,
      _sidechain.rpc.binaryArgs(mainchain.conf),
    );
  }

  bool get inInitialSetup => theme == null;

  @override
  Widget build(BuildContext context) {
    if (inInitialSetup) {
      return MaterialApp(
        home: Material(
          color: _sidechain.rpc.chain.color,
          child: SailTheme(
            data: SailThemeData.darkTheme(_sidechain.rpc.chain.color),
            child: const SailScaffold(
              body: Center(
                child: SailCircularProgressIndicator(),
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

bool isCurrentChainActive({
  required List<ActiveSidechain> activeChains,
  required Sidechain currentChain,
}) {
  final foundMatch = activeChains.firstWhereOrNull((chain) => chain.title == currentChain.name);
  return foundMatch != null;
}
