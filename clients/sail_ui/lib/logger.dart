import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

LogPrinter _printer() {
  if (!kReleaseMode) {
    return PrettyPrinter(
      printTime: true,
      printEmojis: false,
    );
  }

  return LogfmtPrinter();
}

Future<LogOutput> _logoutput(bool fileLog, bool consoleLog, File? logFile) async {
  if (fileLog) {
    // force file log
  } else if (!kReleaseMode || consoleLog || logFile == null) {
    // NOT in release mode: print everything to console
    return ConsoleOutput();
  }

  // If we're in release, write to file.
  return FileOutput(file: logFile!);
}

Future<Logger> logger(bool fileLog, bool consoleLog, File? logFile) async => Logger(
      level: Level.debug,
      filter: ProductionFilter(),
      printer: _printer(),
      output: await _logoutput(fileLog, consoleLog, logFile),
    );
