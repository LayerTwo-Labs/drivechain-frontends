import 'dart:io';

import 'package:bitwindow/services/daemon_warm_up.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('daemon_warm_up_test');
  });

  tearDown(() => dir.delete(recursive: true));

  File script(String name, String body) {
    final file = File('${dir.path}/$name')..writeAsStringSync('#!/bin/sh\n$body\n');
    Process.runSync('chmod', ['+x', file.path]);
    return file;
  }

  test('runs each staged boot daemon with --version', () async {
    final warmUp = DaemonWarmUp(enabled: true);
    for (final name in ['bitwindowd', 'drivechaind']) {
      warmUp.onStaged(name, script(name, 'echo "\$@" > "\$0.args"'));
    }

    await warmUp.done();

    expect(File('${dir.path}/bitwindowd.args').readAsStringSync(), '--version\n');
    expect(File('${dir.path}/drivechaind.args').readAsStringSync(), '--version\n');
  });

  test('runs no other binary', () async {
    final warmUp = DaemonWarmUp(enabled: true);
    warmUp.onStaged('hwi-daemon', script('hwi-daemon', 'touch "\$0.ran"'));

    await warmUp.done();

    expect(File('${dir.path}/hwi-daemon.ran').existsSync(), isFalse);
  });

  test('runs nothing when disabled', () async {
    final warmUp = DaemonWarmUp(enabled: false);
    warmUp.onStaged('drivechaind', script('drivechaind', 'touch "\$0.ran"'));

    await warmUp.done();

    expect(File('${dir.path}/drivechaind.ran').existsSync(), isFalse);
  });

  test('throws when a daemon exits with an error', () async {
    final warmUp = DaemonWarmUp(enabled: true);
    warmUp.onStaged('drivechaind', script('drivechaind', 'exit 3'));

    await expectLater(warmUp.done(), throwsA(isA<ProcessException>().having((e) => e.errorCode, 'errorCode', 3)));
  });
}
