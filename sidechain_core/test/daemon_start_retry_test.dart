import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  // The scheduled restart outlives the test that started it, and it reads the
  // logger through GetIt. A reset between tests makes that read throw.
  setUpAll(() {
    GetIt.instance.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.instance.registerSingleton<LogProvider>(LogProvider());
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('daemon_start_retry');
  });

  BinaryProvider provider(Binary binary) {
    final made = BinaryProvider.test(
      appDir: dir,
      binaries: [binary],
      processManager: ProcessManager(
        appDir: dir,
        pidFileManager: PidFileManager(pidDir: Directory('${dir.path}/pids')),
      ),
    );
    addTearDown(made.dispose);
    return made;
  }

  test('a daemon that never comes up gets another try', () async {
    final binary = BitWindow();
    final made = provider(binary);

    // The binary is absent from the temp directory, so every spawn fails the
    // way a held port fails: the process never comes up.
    await expectLater(made.start(binary), throwsA(anything));
    expect(binary.startupLogs.length, 1);

    await Future.delayed(const Duration(milliseconds: 2500));

    expect(binary.startupLogs.length, greaterThan(1), reason: 'the app must not keep a dead backend');
  });

  test('a disposed provider stops its process manager', () {
    final manager = ProcessManager(
      appDir: dir,
      pidFileManager: PidFileManager(pidDir: Directory('${dir.path}/pids')),
    );
    BinaryProvider.test(appDir: dir, binaries: [BitWindow()], processManager: manager).dispose();

    // A live poll on a disposed provider reports an exit nobody listens to.
    expect(() => manager.addListener(() {}), throwsFlutterError);
  });

  test('a stop keeps the daemon down', () async {
    final binary = BitWindow();
    final made = provider(binary);

    await expectLater(made.start(binary), throwsA(anything));
    await made.stop(binary);

    await Future.delayed(const Duration(milliseconds: 2500));

    expect(binary.startupLogs.length, 1, reason: 'the user asked for the daemon to stay down');
  });
}
