import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

// A second app must not replace the bitwindowd that a live app spawned.
void main() {
  late Directory dir;
  late PidFileManager pids;
  late BinaryProvider provider;
  final bitwindow = BitWindow();

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    dir = await Directory.systemTemp.createTemp('owner');
    pids = PidFileManager(pidDir: Directory('${dir.path}/pids'));
    provider = BinaryProvider.test(
      appDir: dir,
      binaries: [bitwindow],
      processManager: ProcessManager(appDir: dir, pidFileManager: pids),
    );
  });

  tearDown(() async {
    await dir.delete(recursive: true);
    await GetIt.I.reset();
  });

  test('reads back the app that spawned a daemon', () async {
    await pids.writeOwnerFile(bitwindow, 4242);

    expect(await pids.readOwnerFile(bitwindow), 4242);
  });

  test('a daemon with no recorded app has no live owner', () async {
    expect(await provider.ownerAlive(bitwindow), isFalse);
  });

  test('another running app is a live owner', () async {
    final other = await Process.start(
      Platform.isWindows ? 'cmd' : 'sleep',
      Platform.isWindows ? ['/c', 'pause'] : ['30'],
    );
    addTearDown(other.kill);
    await pids.writeOwnerFile(bitwindow, other.pid);

    expect(await provider.ownerAlive(bitwindow), isTrue);
  });

  test('a recorded pid that this app now holds is no other owner', () async {
    await pids.writeOwnerFile(bitwindow, pid);

    expect(await provider.ownerAlive(bitwindow), isFalse);
  });

  test('an exited app is no owner', () async {
    final exited = await Process.start(Platform.isWindows ? 'cmd' : 'true', Platform.isWindows ? ['/c', 'exit'] : []);
    await exited.exitCode;
    await pids.writeOwnerFile(bitwindow, exited.pid);

    expect(await provider.ownerAlive(bitwindow), isFalse);
  });
}
