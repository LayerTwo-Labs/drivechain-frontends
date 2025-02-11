import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/dependencies.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/active_sidechains.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/storage/sail_settings/font_settings.dart';

Future<void> start() async {
  WidgetsFlutterBinding.ensureInitialized();

  Sidechain chain = Sidechain.fromString(RuntimeArgs.chain) ?? TestSidechain();

  await initDependencies(chain);

  MainchainRPC mainchain = GetIt.I.get<MainchainRPC>();
  SidechainContainer sidechain = GetIt.I.get<SidechainContainer>();
  AppRouter router = GetIt.I.get<AppRouter>();
  Logger log = GetIt.I.get<Logger>();

  ClientSettings clientSettings = GetIt.I.get<ClientSettings>();
  final font = (await clientSettings.getValue(FontSetting())).value;

  runApp(
    SailApp(
      dense: false,
      // the initial route is defined in routing/router.dart
      builder: (context) => MaterialApp.router(
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        title: chain.name,
        theme: ThemeData(
          fontFamily: font == SailFontValues.sourceCodePro ? 'SourceCodePro' : 'Inter',
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xffFF8000)),
        ),
      ),
      initMethod: (context) async {
        // Mainchain must be started properly before attempting the
        // sidechain
        await initMainchainBinary(log, mainchain, sidechain);
        // ignore: use_build_context_synchronously
        await initSidechainBinary(log, mainchain, sidechain);
      },
      accentColor: sidechain.rpc.chain.color,
      log: log,
    ),
  );
}

Future<void> initMainchainBinary(
  Logger log,
  MainchainRPC mainchain,
  SidechainContainer sidechain,
) async {
  await mainchain.initBinary();
}

Future<void> initSidechainBinary(
  Logger log,
  MainchainRPC mainchain,
  SidechainContainer sidechain,
) async {
  log.i('sidechain init: waiting for initial block download to finish');
  await mainchain.waitForIBD();
  log.i('sidechain init: initial block download finished');

  return sidechain.rpc.initBinary();
}

bool isCurrentChainActive({
  required List<ActiveSidechain> activeChains,
  required Binary currentChain,
}) {
  final foundMatch = activeChains.firstWhereOrNull((chain) => chain.title == currentChain.name);
  return foundMatch != null;
}

void main() {
  // the application is launched function because some startup things
  // are async
  start();
}
