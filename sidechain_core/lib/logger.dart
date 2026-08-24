import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Width of the source tag, so the merged log file lines up in a column.
const _sourceTagWidth = 15;

String logSourceTag(String source) => '[$source]'.padRight(_sourceTagWidth);

LogPrinter _consolePrinter() {
  if (kReleaseMode) {
    return LogfmtPrinter();
  }
  return PrettyPrinter(
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    noBoxingByDefault: true,
    printEmojis: false,
  );
}

/// Appends to a log file that other processes also append to. Each event goes
/// out as one write, so the lines of the other writers stay whole.
class SharedFileOutput extends LogOutput {
  SharedFileOutput({required File file, required String source})
    : _file = file.openSync(mode: FileMode.writeOnlyAppend),
      _tag = logSourceTag(source);

  final RandomAccessFile _file;
  final String _tag;

  @override
  void output(OutputEvent event) {
    final buffer = StringBuffer();
    for (final line in event.lines) {
      buffer.writeln('$_tag $line');
    }
    try {
      _file.writeFromSync(utf8.encode(buffer.toString()));
    } catch (error) {
      stderr.writeln('could not write to the log file: $error');
    }
  }

  @override
  Future<void> destroy() async {
    await _file.close();
  }
}

Future<LogOutput> _logoutput(File? logFile, String source) async {
  List<LogOutput> outputs = [];

  if (logFile != null) {
    outputs.add(SharedFileOutput(file: logFile, source: source));
  }

  if (logFile == null || kDebugMode) {
    outputs.add(ConsoleOutput());
  }

  return MultiOutput(outputs);
}

Future<Logger> logger(
  bool fileLog,
  bool consoleLog,
  File? logFile, {
  String source = 'frontend',
}) async => Logger(
  level: Level.debug,
  filter: ProductionFilter(),
  printer: _consolePrinter(),
  output: await _logoutput(logFile, source),
);
