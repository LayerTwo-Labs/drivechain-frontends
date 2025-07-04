class Environment {
  static const isInTest = bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);

  static const baseUrl = String.fromEnvironment('FAUCET_BASE_URL', defaultValue: 'https://drivechain.live/api');
}
