import 'dart:io';

class Environment {
  static bool get isInTest =>
      Platform.environment.containsKey('FLUTTER_TEST') || const String.fromEnvironment('FLUTTER_TEST').isNotEmpty;
}
