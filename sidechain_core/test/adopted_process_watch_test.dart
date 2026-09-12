import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// A pid no process holds. macOS and Linux both keep pids below this.
const _deadPid = 4000000;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  // A poll that reads a pid outlives the test that started it, and it reads
  // the logger through GetIt. A reset between tests makes that read throw.
  setUpAll(() {
    GetIt.instance.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.instance.registerSingleton<LogProvider>(LogProvider());
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('adopted_process_watch');
  });

  ProcessManager manager() {
    final made = ProcessManager(
      appDir: dir,
      pidFileManager: PidFileManager(pidDir: Directory('${dir.path}/pids')),
      adoptedPollInterval: const Duration(milliseconds: 20),
    );
    addTearDown(made.dispose);
    return made;
  }

  test('an adopted process counts as running', () {
    final made = manager();
    final binary = BitWindow();

    made.adopt(binary, pid);

    expect(made.isRunning(binary), isTrue);
    expect(made.runningProcesses[binary.name]!.adopted, isTrue);
  });

  test('the death of an adopted process drops it and tells the listeners', () async {
    final made = manager();
    final binary = BitWindow();
    await made.pidFileManager.writePidFile(binary, _deadPid);

    final died = Completer<void>();
    made.addListener(() {
      if (!made.isRunning(binary) && !died.isCompleted) {
        died.complete();
      }
    });

    made.adopt(binary, _deadPid);
    expect(made.isRunning(binary), isTrue, reason: 'the poll has not run yet');

    await died.future.timeout(const Duration(seconds: 10));

    expect(await made.pidFileManager.readPidFile(binary), isNull);
  });

  test('a live adopted process stays registered', () async {
    final made = manager();
    // The poll reads the process name, so the daemon here is a real process.
    final binary = BitWindow(
      metadata: MetadataConfig(
        downloadConfig: const DownloadConfig(binary: 'sleep', files: {}),
        updateable: false,
        remoteTimestamp: null,
        downloadedTimestamp: null,
        binaryPath: null,
      ),
    );
    final live = await Process.start('/bin/sleep', ['30']);
    addTearDown(() => live.kill());

    made.adopt(binary, live.pid);
    await Future.delayed(const Duration(milliseconds: 120));

    expect(made.isRunning(binary), isTrue);
  }, skip: Platform.isWindows);

  test('a pid the OS gave to another process drops the daemon', () async {
    final made = manager();
    final binary = BitWindow();

    final died = Completer<void>();
    made.addListener(() {
      if (!made.isRunning(binary) && !died.isCompleted) {
        died.complete();
      }
    });

    // This process lives, but it is not the daemon.
    made.adopt(binary, pid);

    await died.future.timeout(const Duration(seconds: 10));
  });

  test('a stopped process leaves no poll behind', () async {
    final made = manager();
    final binary = BitWindow();

    made.adopt(binary, _deadPid);
    await made.kill(binary);
    var notified = 0;
    made.addListener(() => notified++);

    await Future.delayed(const Duration(milliseconds: 120));

    expect(notified, 0, reason: 'the cancelled poll must not report the exit twice');
  });
}
