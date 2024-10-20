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

Future<LogOutput> _logoutput(File? logFile) async {
  List<LogOutput> outputs = [];

  if (logFile != null) {
    outputs.add(FileOutput(file: logFile));
  }

  if (logFile == null || kDebugMode) {
    // always print to console in debug mode
    outputs.add(ConsoleOutput());
  }

  return MultiOutput(outputs);
}

Future<Logger> logger(bool fileLog, bool consoleLog, File? logFile) async => Logger(
      level: Level.debug,
      filter: ProductionFilter(),
      printer: _printer(),
      output: await _logoutput(logFile),
    );
