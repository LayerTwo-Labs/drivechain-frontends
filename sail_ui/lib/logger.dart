import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

LogPrinter _consolePrinter() {
  if (!kReleaseMode) {
    return PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      printEmojis: false,
    );
  }
  return LogfmtPrinter();
}

Future<LogOutput> _logoutput(File? logFile) async {
  List<LogOutput> outputs = [];

  if (logFile != null) {
    outputs.add(
      FileOutput(
        file: logFile,
        overrideExisting: true,
      ),
    );
  }

  if (logFile == null || kDebugMode) {
    outputs.add(ConsoleOutput());
  }

  return MultiOutput(outputs);
}

Future<Logger> logger(bool fileLog, bool consoleLog, File? logFile) async => Logger(
      level: Level.debug,
      filter: ProductionFilter(),
      printer: logFile != null ? LogfmtPrinter() : _consolePrinter(), // Use LogfmtPrinter for file output
      output: await _logoutput(logFile),
    );
