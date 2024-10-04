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

Future<LogOutput> _logoutput(bool fileLog, bool consoleLog, Directory? datadir) async {
  if (fileLog) {
    // force file log
  } else if (!kReleaseMode || consoleLog || datadir == null) {
    // NOT in release mode: print everything to console
    return ConsoleOutput();
  }

  await datadir!.create(recursive: true);

  // If we're in release, just write to file.
  final path = [datadir.path, 'debug.log'].join(Platform.pathSeparator);
  final logFile = File(path);
  return FileOutput(file: logFile);
}

Future<Logger> logger(bool fileLog, bool consoleLog, Directory? datadir) async => Logger(
      level: Level.debug,
      filter: ProductionFilter(),
      printer: _printer(),
      output: await _logoutput(fileLog, consoleLog, datadir),
    );
