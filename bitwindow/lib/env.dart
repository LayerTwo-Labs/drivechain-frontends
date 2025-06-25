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
  static bool isInTest = Platform.environment['FLUTTER_TEST']?.isNotEmpty ?? const bool.fromEnvironment('FLUTTER_TEST');

  // Define the environment variables here
  static const bitwindowdHost = Variable(
    'BITWINDOWD_HOST',
    String.fromEnvironment('BITWINDOWD_HOST', defaultValue: '127.0.0.1'),
  );
  static const bitwindowdPort = Variable(
    'BITWINDOWD_PORT',
    int.fromEnvironment('BITWINDOWD_PORT', defaultValue: 8080),
  );

  static Future<Directory> datadir() async {
    final fromEnv = Platform.environment['BITWINDOWD_DATADIR'] ?? const String.fromEnvironment('BITWINDOWD_DATADIR');
    if (fromEnv.isNotEmpty) {
      final dir = Directory(fromEnv);
      return dir;
    }

    return await getApplicationSupportDirectory();
  }

  static bool consoleLog = Platform.environment['BITWINDOWD_LOG_CONSOLE']?.isNotEmpty ?? false;
  static bool fileLog = Platform.environment['BITWINDOWD_LOG_FILE']?.isNotEmpty ?? false;

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
    _validate<String>(bitwindowdHost, (v) => v.isNotEmpty);
    _validate<int>(bitwindowdPort, (v) => v > 0 && v < 65536);
    // Add more validations for other variables if needed
  }
}

// Helper function to access environment variables
T env<T>(Variable<T> variable) => variable.value;
