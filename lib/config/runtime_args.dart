import 'dart:io';

// A class where you should put runtime arguments
abstract class RuntimeArgs {
  static bool get isInTest =>
      Platform.environment.containsKey('FLUTTER_TEST') || const String.fromEnvironment('FLUTTER_TEST').isNotEmpty;
}
