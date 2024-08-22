import 'package:drivechain_client/routing/router.dart';
import 'package:drivechain_client/service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:logger/logger.dart';

void main() {
  final log = Logger();
  final router = AppRouter();

  runApp(
    DrivechainService(
      child: SailApp(
        builder: (context) {
          return MaterialApp.router(
            routerDelegate: router.delegate(),
            routeInformationParser: router.defaultRouteParser(),
            title: "Drivechain",
            theme: ThemeData(
              textTheme: GoogleFonts.interTextTheme(),
              colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xffFF8000)),
            ),
          );
        },
        initMethod: (_) => Future.value(),
        accentColor: const Color(0xff000000),
        log: log,
      ),
    ),
  );
}
