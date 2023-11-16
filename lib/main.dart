import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sidesail/app.dart';
import 'package:sidesail/config/dependencies.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';

const appName = 'SideSail';

Future<void> start() async {
  WidgetsFlutterBinding.ensureInitialized();

  Sidechain chain;
  // Sanity check we're getting a supported chain.
  switch (RuntimeArgs.chain) {
    case '': // default to testchain
    case 'testchain':
      chain = TestSidechain();
      break;

    case 'ethereum':
      chain = EthereumSidechain();
      break;

    case 'zcash':
      chain = ZCashSidechain();
      break;

    default:
      return runApp(
        SailApp(
          builder: (context, router) => const Center(
            child: Text(
              'Unsupported CHAIN parameter: ${RuntimeArgs.chain}',
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
      );
  }

  await initDependencies(chain);
  runApp(
    SailApp(
      // the initial route is defined in routing/router.dart
      builder: (context, router) => MaterialApp.router(
        routerDelegate: router.delegate(),
        routeInformationParser: router.defaultRouteParser(),
        title: appName,
        theme: ThemeData(
          fontFamily: 'SourceCodePro',
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
