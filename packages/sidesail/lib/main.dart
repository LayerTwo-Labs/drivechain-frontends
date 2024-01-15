import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sidesail/app.dart';
import 'package:sidesail/config/dependencies.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/sail_settings/font_settings.dart';

Future<void> start() async {
  WidgetsFlutterBinding.ensureInitialized();

  String appName;
  Sidechain chain;
  // Sanity check we're getting a supported chain.
  switch (RuntimeArgs.chain.toLowerCase()) {
    case '': // default to testchain
    case 'testchain':
      chain = TestSidechain();
      appName = chain.name;
      break;

    case 'ethereum':
    case 'ethside':
      chain = EthereumSidechain();
      appName = chain.name;
      break;

    case 'zcash':
    case 'zside':
      chain = ZCashSidechain();
      appName = chain.name;
      break;

    default:
      // Just throw an error here. We used to initialize
      // the app with an error message, but we won't be able
      // to do that successfully because initializing deps
      // crashes as well.
      throw 'unsupported chain: ${RuntimeArgs.chain}';
  }

  await initDependencies(chain);

  ClientSettings clientSettings = GetIt.I.get<ClientSettings>();
  final font = (await clientSettings.getValue(FontSetting())).value;

  runApp(
    SailApp(
      // the initial route is defined in routing/router.dart
      builder: (context, router) => MaterialApp.router(
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        title: appName,
        theme: ThemeData(
          fontFamily: font == SailFontValues.sourceCodePro ? 'SourceCodePro' : 'Inter',
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xffFF8000)),
        ),
      ),
    ),
  );
}

void main() {
  // the application is launched function because some startup things
  // are async
  start();
}
