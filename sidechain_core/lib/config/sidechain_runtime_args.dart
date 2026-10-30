import 'dart:io';

import 'package:sidechain_core/utils/file_utils.dart';

/// Runtime switches for a sidechain app, read from `<PREFIX>_*` environment variables.
class SidechainRuntimeArgs {
  final String prefix;

  const SidechainRuntimeArgs(this.prefix);

  Future<Directory> datadir() async {
    final fromEnv = Platform.environment['${prefix}_DATADIR'] ?? '';
    if (fromEnv.isNotEmpty) {
      return Directory(fromEnv);
    }
    return applicationSupportDir();
  }

  bool get consoleLog => Platform.environment['${prefix}_LOG_CONSOLE']?.isNotEmpty ?? false;

  bool get fileLog => Platform.environment['${prefix}_LOG_FILE']?.isNotEmpty ?? false;
}
