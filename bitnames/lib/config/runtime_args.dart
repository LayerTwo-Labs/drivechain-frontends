import 'dart:io';

import 'package:path_provider/path_provider.dart';

// A class where you should put runtime arguments
// The build-time variables can only be looked up with
// const methods. Otherwise it'll be like they were never there!
abstract class RuntimeArgs {
  static bool isInTest = Platform.environment['FLUTTER_TEST']?.isNotEmpty ?? const bool.fromEnvironment('FLUTTER_TEST');

  static Future<Directory> datadir() async {
    final fromEnv = Platform.environment['THUNDER_DATADIR'] ?? const String.fromEnvironment('THUNDER_DATADIR');
    if (fromEnv.isNotEmpty) {
      final dir = Directory(fromEnv);
      return dir;
    }

    return await getApplicationSupportDirectory();
  }

  static bool consoleLog = Platform.environment['THUNDER_LOG_CONSOLE']?.isNotEmpty ?? false;

  static bool fileLog = Platform.environment['THUNDER_LOG_FILE']?.isNotEmpty ?? false;

  static final String _network =
      Platform.environment['THUNDER_NETWORK'] ?? const String.fromEnvironment('THUNDER_NETWORK');

  static String? network = _network.isNotEmpty ? _network : null;
}
