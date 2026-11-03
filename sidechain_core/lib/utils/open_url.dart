import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sidechain_core/utils/file_utils.dart';

typedef ProcessRunner = Future<ProcessResult> Function(String executable, List<String> arguments);

@visibleForTesting
ProcessRunner openUrlProcessRunner = Process.run;

class OpenUrlException implements Exception {
  final String message;

  const OpenUrlException(this.message);

  @override
  String toString() => message;
}

/// The command that opens [uri] in the default handler of [os].
(String, List<String>) openUrlCommand(OS os, Uri uri) => switch (os) {
  OS.macos => ('open', [uri.toString()]),
  OS.linux => ('xdg-open', [uri.toString()]),
  OS.windows => ('rundll32', ['url.dll,FileProtocolHandler', uri.toString()]),
};

/// Opens [uri] in the default browser or file handler.
/// Throws [OpenUrlException] when [uri] has no scheme or the command fails.
Future<void> openUrl(Uri uri) async {
  if (!uri.hasScheme) {
    throw OpenUrlException('cannot open "$uri": the link has no scheme');
  }
  final (executable, arguments) = openUrlCommand(getOS(), uri);
  final result = await openUrlProcessRunner(executable, arguments);
  if (result.exitCode != 0) {
    throw OpenUrlException('$executable could not open "$uri" (exit code ${result.exitCode}): ${result.stderr}');
  }
}
