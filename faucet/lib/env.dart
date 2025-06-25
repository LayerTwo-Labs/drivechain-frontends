import 'dart:io';

class Environment {
  static bool isInTest = Platform.environment['FLUTTER_TEST']?.isNotEmpty ?? const bool.fromEnvironment('FLUTTER_TEST');

  static const baseUrl = String.fromEnvironment('FAUCET_BASE_URL', defaultValue: 'https://drivechain.live/api');
}
