import 'package:meta/meta.dart';

@immutable
class Variable<T> {
  final String key;
  final T? value;

  const Variable(this.key, this.value);
}

class Environment {
  // Define the environment variables here
  static const apiHost = Variable(
    'FAUCET_API_HOST',
    String.fromEnvironment('FAUCET_API_HOST', defaultValue: 'https://api.drivechain.live'),
  );
  static const apiPort = Variable<int>(
    'FAUCET_API_PORT',
    int.fromEnvironment('FAUCET_API_PORT', defaultValue: 0),
  );

  const Environment._();

  static T? _validate<T>(Variable v, [bool Function(T)? validator]) {
    if (v.value == null) {
      return null;
    }
    if (validator != null && !validator(v.value as T)) {
      throw StateError('Invalid value for environment variable: ${v.key}');
    }
    return v.value as T;
  }

  static void validateAtRuntime() {
    _validate<String>(apiHost, (v) => v.isNotEmpty);
    _validate<int>(apiPort);
  }
}

// Helper function to access environment variables
T env<T>(Variable<T> variable) => variable.value as T;
