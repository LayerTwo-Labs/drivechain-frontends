import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/shared_log_tail.dart';

void main() {
  late File file;
  late List<String> printed;

  SharedLogTail tailOf(File file) => SharedLogTail(
    file: file,
    source: 'orchestrator',
    onLine: printed.add,
  );

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('shared_log_tail_test');
    addTearDown(() => dir.delete(recursive: true));
    file = File('${dir.path}/bitwindow.log');
    printed = [];
  });

  test('holds the tail back when bitwindowd already prints those lines', () {
    expect(orchestratorLogsToStdout({'ORCHESTRATORD_STDOUT': '1'}), isTrue);
    expect(orchestratorLogsToStdout({'ORCHESTRATORD_STDOUT': 'true'}), isTrue);
    expect(orchestratorLogsToStdout({'ORCHESTRATORD_STDOUT': 'TRUE'}), isFalse);
    expect(orchestratorLogsToStdout({'ORCHESTRATORD_STDOUT': '0'}), isFalse);
    expect(orchestratorLogsToStdout({}), isFalse);
  });

  test('prints the lines of the chosen source only', () async {
    await file.writeAsString('');
    final tail = tailOf(file);
    await tail.start();

    await file.writeAsString(
      '[orchestrator]  starting orchestratord\n[bitwindowd]    listening\n',
      mode: FileMode.append,
    );
    await tail.readNow();

    expect(printed, ['[orchestrator]  starting orchestratord']);
  });

  // orchestratord writes the reason it refuses to start to its raw stderr,
  // before its logger exists. That line reaches the file with no tag.
  test('prints a line that carries no tag', () async {
    await file.writeAsString('');
    final tail = tailOf(file);
    await tail.start();

    await file.writeAsString(
      'error: RPC address localhost:30400 is already in use\n'
      '[bitwindowd]    listening on localhost:30301\n'
      '\n',
      mode: FileMode.append,
    );
    await tail.readNow();

    expect(printed, ['error: RPC address localhost:30400 is already in use']);
  });

  test('prints a panic line that starts with a bracket', () async {
    await file.writeAsString('');
    final tail = tailOf(file);
    await tail.start();

    await file.writeAsString('[signal SIGSEGV: segmentation violation]\n', mode: FileMode.append);
    await tail.readNow();

    expect(printed, ['[signal SIGSEGV: segmentation violation]']);
  });

  test('skips what the earlier run wrote', () async {
    await file.writeAsString('[orchestrator]  the run before\n');
    final tail = tailOf(file);
    await tail.start();

    await file.writeAsString('[orchestrator]  this run\n', mode: FileMode.append);
    await tail.readNow();

    expect(printed, ['[orchestrator]  this run']);
  });

  test('holds a part line until the newline arrives', () async {
    await file.writeAsString('');
    final tail = tailOf(file);
    await tail.start();

    await file.writeAsString('[orchestrator]  half', mode: FileMode.append);
    await tail.readNow();
    expect(printed, isEmpty);

    await file.writeAsString(' a line\n', mode: FileMode.append);
    await tail.readNow();
    expect(printed, ['[orchestrator]  half a line']);
  });

  test('reads from the top again after the file is emptied', () async {
    await file.writeAsString('[orchestrator]  first\n');
    final tail = tailOf(file);
    await tail.start();

    await file.writeAsString('');
    await tail.readNow();

    await file.writeAsString('[orchestrator]  after the cut\n', mode: FileMode.append);
    await tail.readNow();

    expect(printed, ['[orchestrator]  after the cut']);
  });

  test('stop reads the last lines and cancels the timer', () async {
    await file.writeAsString('');
    final tail = tailOf(file);
    await tail.start();

    await file.writeAsString('[orchestrator]  last\n', mode: FileMode.append);
    await tail.stop();

    expect(printed, ['[orchestrator]  last']);
  });
}
