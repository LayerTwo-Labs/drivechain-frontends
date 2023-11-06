import 'dart:io';

// A class where you should put runtime arguments
abstract class RuntimeArgs {
  static bool get isInTest =>
      Platform.environment.containsKey('FLUTTER_TEST') || const String.fromEnvironment('FLUTTER_TEST').isNotEmpty;

  // use like flutter run --dart-define=CHAIN=ethereum
  // or flutter build apk --dart-define=CHAIN=ethereum
  static const String chain = String.fromEnvironment(
    'CHAIN',
    defaultValue: 'testchain',
  );
}
