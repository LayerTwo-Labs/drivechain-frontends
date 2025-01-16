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
  static Future<Directory> datadir() async {
    final fromEnv = Platform.environment['LAUNCHER_DATADIR'] ?? const String.fromEnvironment('LAUNCHER_DATADIR');
    if (fromEnv.isNotEmpty) {
      final dir = Directory(fromEnv);
      return dir;
    }

    return await getApplicationSupportDirectory();
  }

  const Environment._();
}

// Helper function to access environment variables
T env<T>(Variable<T> variable) => variable.value;