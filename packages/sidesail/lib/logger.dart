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
  // NOT in release mode: print everything to console
  if (!kReleaseMode || RuntimeArgs.consoleLog) {
    return ConsoleOutput();
  }

  final datadir = await RuntimeArgs.datadir();
  await datadir.create(recursive: true);

  // If we're in release, just write to file.
  final logFile = File('${datadir.path}${Platform.pathSeparator}debug.log');
  return FileOutput(file: logFile);
}

Future<Logger> logger() async => Logger(
      level: Level.debug,
      filter: ProductionFilter(),
      printer: _printer(),
      output: await _logoutput(),
    );
