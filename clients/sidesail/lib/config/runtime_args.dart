import 'dart:io';

import 'package:path_provider/path_provider.dart';

// A class where you should put runtime arguments
// The build-time variables can only be looked up with
// const methods. Otherwise it'll be like they were never there!
abstract class RuntimeArgs {
  static bool isInTest = Platform.environment['FLUTTER_TEST']?.isNotEmpty ?? const bool.fromEnvironment('FLUTTER_TEST');

  /// Datadir for the current flavor of sidesail
  static Future<Directory> datadir() async {
    final fromEnv = Platform.environment['SIDESAIL_DATADIR'] ?? const String.fromEnvironment('SIDESAIL_DATADIR');
    if (fromEnv.isNotEmpty) {
      final dir = Directory(fromEnv);
      return dir;
    }

    final dir = await getApplicationSupportDirectory();
    return Directory([dir.path, chain].join(Platform.pathSeparator));
  }

  // use like flutter run --dart-define=SIDESAIL_CHAIN=ethereum
  // or flutter build apk --dart-define=SIDESAIL_CHAIN=ethereum
  static final String _chain = Platform.environment['SIDESAIL_CHAIN'] ?? const String.fromEnvironment('SIDESAIL_CHAIN');
  static String chain = _chain.isNotEmpty ? _chain : 'zcash';

  static bool consoleLog = Platform.environment['SIDESAIL_LOG_CONSOLE']?.isNotEmpty ?? false;

  static bool fileLog = Platform.environment['SIDESAIL_LOG_FILE']?.isNotEmpty ?? false;

  static bool swappableChains = Platform.environment['SIDESAIL_SWAPPABLE_CHAINS']?.isNotEmpty ?? false;

  static final String _network =
      Platform.environment['SIDESAIL_NETWORK'] ?? const String.fromEnvironment('SIDESAIL_NETWORK');

  static String? network = _network.isNotEmpty ? _network : null;
}
