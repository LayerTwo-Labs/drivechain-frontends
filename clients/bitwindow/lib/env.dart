import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

@immutable
class Variable<T> {
  final String key;
  final T value;

  const Variable(this.key, this.value);
}

class Environment {
  // Define the environment variables here
  static const drivechainHost = Variable(
    'BITWINDOW_HOST',
    String.fromEnvironment('BITWINDOW_HOST', defaultValue: 'localhost'),
  );
  static const drivechainPort = Variable(
    'BITWINDOW_PORT',
    int.fromEnvironment('BITWINDOW_PORT', defaultValue: 8080),
  );

  static Future<Directory> datadir() async {
    final fromEnv = Platform.environment['BITWINDOW_DATADIR'] ?? const String.fromEnvironment('BITWINDOW_DATADIR');
    if (fromEnv.isNotEmpty) {
      final dir = Directory(fromEnv);
      return dir;
    }

    return await getApplicationSupportDirectory();
  }

  static bool consoleLog = Platform.environment['BITWINDOW_LOG_CONSOLE']?.isNotEmpty ?? false;
  static bool fileLog = Platform.environment['BITWINDOW_LOG_FILE']?.isNotEmpty ?? false;

  const Environment._();

  static T _validate<T>(Variable v, [bool Function(T)? validator]) {
    if (v.value == null) {
      throw StateError('Missing required environment variable: ${v.key}');
    }
    if (validator != null && !validator(v.value)) {
      throw StateError('Invalid value for environment variable: ${v.key}');
    }
    return v.value;
  }

  static void validateAtRuntime() {
    _validate<String>(drivechainHost, (v) => v.isNotEmpty);
    _validate<int>(drivechainPort, (v) => v > 0 && v < 65536);
    // Add more validations for other variables if needed
  }
}

// Helper function to access environment variables
T env<T>(Variable<T> variable) => variable.value;
