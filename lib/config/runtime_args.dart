import 'dart:io';

import 'package:path_provider/path_provider.dart';

// A class where you should put runtime arguments
abstract class RuntimeArgs {
  static bool get isInTest =>
      Platform.environment.containsKey('FLUTTER_TEST') || const String.fromEnvironment('FLUTTER_TEST').isNotEmpty;

  /// Datadir for the current flavor of sidesail
  static Future<Directory> datadir() async {
    final dir = await getApplicationSupportDirectory();
    return Directory([dir.path, Platform.pathSeparator, chain].join(''));
  }

  // use like flutter run --dart-define=CHAIN=ethereum
  // or flutter build apk --dart-define=CHAIN=ethereum
  static const String chain = String.fromEnvironment(
    'CHAIN',
    defaultValue: 'testchain',
  );
  static const bool withoutSwappableChains = bool.fromEnvironment(
    'NO_SWAPPABLE_CHAINS',
    defaultValue: true,
  );
}
