import 'dart:io';

class Environment {
  static bool get isInTest =>
      Platform.environment.containsKey('FLUTTER_TEST') || const String.fromEnvironment('FLUTTER_TEST').isNotEmpty;

  /// When true, providers use RPC-backed implementations (Backend*) instead of
  /// file-based ones (Frontend*). Set by initSidechainDependencies when the Go
  /// backend (e.g. thunderd) manages binaries and config.
  static bool backendManagesBinaries = false;
}
