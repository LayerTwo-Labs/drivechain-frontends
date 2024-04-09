import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sidesail/config/runtime_args.dart';

LogPrinter _printer() {
  if (!kReleaseMode) {
    return PrettyPrinter(
      printTime: true,
      printEmojis: false,
    );
  }

  return LogfmtPrinter();
}

Future<LogOutput> _logoutput() async {
  if (RuntimeArgs.fileLog) {
    // force file log
  } else if (!kReleaseMode || RuntimeArgs.consoleLog) {
    // NOT in release mode: print everything to console
    return ConsoleOutput();
  }

  final datadir = await RuntimeArgs.datadir();
  await datadir.create(recursive: true);

  // If we're in release, just write to file.
  final path = [datadir.path, 'debug.log'].join(Platform.pathSeparator);
  final logFile = File(path);
  return FileOutput(file: logFile);
}

Future<Logger> logger() async => Logger(
      level: Level.debug,
      filter: ProductionFilter(),
      printer: _printer(),
      output: await _logoutput(),
    );
