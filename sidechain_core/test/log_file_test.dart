import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pbenum.dart';
import 'package:sidechain_core/logger.dart';
import 'package:sidechain_core/utils/log_file.dart';

void main() {
  test('prepareLogFile creates the directory and keeps a small file', () async {
    final tmp = await Directory.systemTemp.createTemp('log_file_test');
    addTearDown(() => tmp.delete(recursive: true));

    final dir = Directory('${tmp.path}/app');
    final first = await prepareLogFile(dir, 'bitwindow.log');
    await first.writeAsString('one line\n');

    final second = await prepareLogFile(dir, 'bitwindow.log');
    expect(await second.readAsString(), 'one line\n');
  });

  test('prepareLogFile empties a file that grew past the cap', () async {
    final tmp = await Directory.systemTemp.createTemp('log_file_test');
    addTearDown(() => tmp.delete(recursive: true));

    final file = File('${tmp.path}/bitwindow.log');
    await file.writeAsString('x' * 100);

    final prepared = await prepareLogFile(tmp, 'bitwindow.log', maxBytes: 50);
    expect(await prepared.length(), 0);
  });

  test('SharedFileOutput appends tagged lines and keeps what is already there', () async {
    final tmp = await Directory.systemTemp.createTemp('log_file_test');
    addTearDown(() => tmp.delete(recursive: true));

    final file = File('${tmp.path}/bitwindow.log');
    await file.writeAsString('[orchestrator]  earlier line\n');

    final output = SharedFileOutput(file: file, source: 'frontend');
    output.output(_event(['first', 'second']));
    await output.destroy();

    expect(await file.readAsLines(), [
      '[orchestrator]  earlier line',
      '[frontend]      first',
      '[frontend]      second',
    ]);
  });

  test('only bitwindowd writes to the shared log file itself', () {
    expect(writesToSharedLog(BinaryType.BINARY_TYPE_BITWINDOWD), isTrue);
    expect(writesToSharedLog(BinaryType.BINARY_TYPE_BITCOIND), isFalse);
    expect(writesToSharedLog(BinaryType.BINARY_TYPE_ENFORCER), isFalse);
    expect(writesToSharedLog(BinaryType.BINARY_TYPE_THUNDER), isFalse);
  });

  test('every source tag takes the same width', () {
    expect(logSourceTag('frontend').length, logSourceTag('orchestrator').length);
    expect(logSourceTag('bitwindowd').length, logSourceTag('orchestrator').length);
  });
}

OutputEvent _event(List<String> lines) {
  return OutputEvent(LogEvent(Level.info, lines.join('\n')), lines);
}
