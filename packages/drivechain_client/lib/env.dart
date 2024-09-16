import 'package:meta/meta.dart';

@immutable
class Variable<T> {
  final String key;
  final T value;

  const Variable(this.key, this.value);
}

class Environment {
  // Define the environment variables here
  static const drivechainHost = Variable(
    'DRIVECHAIN_HOST',
    String.fromEnvironment('DRIVECHAIN_HOST', defaultValue: 'localhost'),
  );
  static const drivechainPort = Variable(
    'DRIVECHAIN_PORT',
    int.fromEnvironment('DRIVECHAIN_PORT', defaultValue: 8080),
  );

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
