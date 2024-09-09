import 'package:drivechain_client/env.dart';
import 'package:drivechain_client/routing/router.dart';
import 'package:drivechain_client/service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Environment.validateAtRuntime();

  final log = Logger();
  final router = AppRouter();
  final prefs = await SharedPreferences.getInstance();

  // Needed for sidesail_ui to work
  GetIt.I.registerLazySingleton<ClientSettings>(
    () => ClientSettings(
      store: Storage(
        preferences: prefs,
      ),
      log: log,
    ),
  );

  return runApp(
    DrivechainService(
      child: SailApp(
        builder: (context) {
          return MaterialApp.router(
            routerDelegate: router.delegate(),
            routeInformationParser: router.defaultRouteParser(),
            title: 'Drivechain',
            theme: ThemeData(
              visualDensity: VisualDensity.compact,
              fontFamily: 'Inter',
              textTheme: GoogleFonts.interTightTextTheme(
                GoogleFonts.sourceCodeProTextTheme(),
              ),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: const Color(0xffFF8000),
              ),
              snackBarTheme:  SnackBarThemeData(
                backgroundColor: const Color.fromARGB(255, 230, 230, 230),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              indicatorColor: const Color(0xffFF8000),
              scaffoldBackgroundColor: const Color.fromARGB(255, 240, 240, 240),
              inputDecorationTheme: InputDecorationTheme(
                isDense: true,
                outlineBorder: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                focusColor: Colors.white,
                fillColor: Colors.white,                
                filled: true,
                hoverColor: Colors.white,
                contentPadding: const EdgeInsets.all(6.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              popupMenuTheme: PopupMenuThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                color: Colors.white,
              ),
            ),
          );
        },
        accentColor: const Color.fromARGB(255, 240, 240, 240),
        log: log,
      ),
    ),
  );
}
