import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/dependencies.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/active_sidechains.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
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
        await initMainchainBinary(context, log, mainchain, sidechain);
        // ignore: use_build_context_synchronously
        await initSidechainBinary(context, log, mainchain, sidechain);
      },
      accentColor: sidechain.rpc.chain.color,
      log: log,
    ),
  );
}

Future<void> initMainchainBinary(
  BuildContext context,
  Logger log,
  MainchainRPC mainchain,
  SidechainContainer sidechain,
) async {
  await mainchain.initBinary(
    context,
    mainchain.binary,
    bitcoinCoreBinaryArgs(mainchain.conf),
  );
  await mainchain.waitForIBD();

  log.d('mainchain init: checking if ${sidechain.rpc.chain.name} is an active sidechain');
  final activeSidechains = await mainchain.listActiveSidechains();
  final ourSidechain = isCurrentChainActive(activeChains: activeSidechains, currentChain: sidechain.rpc.chain);
  if (ourSidechain) {
    log.i('mainchain init: ${sidechain.rpc.chain.name} is active');
    return;
  }

  if (!mainchain.conf.isLocalNetwork) {
    log.w('${sidechain.rpc.chain.name} chain is not active, and we\'re unable to activate it');
    return;
  }

  log.i(
    'mainchain init: we are NOT an active sidechain, creating proposal ${activeSidechains.map((e) => e.toJson())}',
  );

  await mainchain.createSidechainProposal(sidechain.rpc.chain.slot, sidechain.rpc.chain.name);

  const numBlocks = 144;
  log.i('mainchain init: generating $numBlocks blocks to broadcast proposal and give user some balance');
  await mainchain.generate(numBlocks);

  log.i('mainchain init: verifying sidechain is active');
  final chains = await mainchain.listActiveSidechains();
  final isActive = isCurrentChainActive(activeChains: chains, currentChain: sidechain.rpc.chain);
  if (!isActive) {
    log.e(
      'mainchain init: was not able to activate sidechain ${await mainchain.listActiveSidechains().then((xs) => xs.map((chain) => chain.toJson()))}',
    );
    throw 'Was not able to activate sidechain';
  }

  log.i('mainchain init: successfully activated sidechain');
}

Future<void> initSidechainBinary(
  BuildContext context,
  Logger log,
  MainchainRPC mainchain,
  SidechainContainer sidechain,
) async {
  log.i('sidechain init: waiting for initial block download to finish');
  await mainchain.waitForIBD();
  log.i('sidechain init: initial block download finished');

  if (!context.mounted) {
    return;
  }
  return sidechain.rpc.initBinary(
    // ignore: use_build_context_synchronously
    context,
    sidechain.rpc.chain.binary,
    sidechain.rpc.binaryArgs(mainchain.conf),
  );
}

bool isCurrentChainActive({
  required List<ActiveSidechain> activeChains,
  required Sidechain currentChain,
}) {
  final foundMatch = activeChains.firstWhereOrNull((chain) => chain.title == currentChain.name);
  return foundMatch != null;
}

void main() {
  // the application is launched function because some startup things
  // are async
  start();
}
