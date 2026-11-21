import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _LocalBitWindow extends BitWindow {
  final String executable;

  _LocalBitWindow(this.executable);

  @override
  Future<File> resolveBinaryPath(Directory appDir) async => File(executable);
}

class _LocalDrivechaind extends Drivechaind {
  final String executable;

  _LocalDrivechaind(this.executable);

  @override
  Future<File> resolveBinaryPath(Directory appDir) async => File(executable);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  setUpAll(() {
    GetIt.instance.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.instance.registerSingleton<LogProvider>(LogProvider());
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('process_start_up_check');
  });

  ProcessManager manager(Map<BinaryType, Future<bool> Function()> upChecks) {
    final made = ProcessManager(
      appDir: dir,
      pidFileManager: PidFileManager(pidDir: Directory('${dir.path}/pids')),
      upChecks: upChecks,
    );
    addTearDown(made.dispose);
    return made;
  }

  Future<File> script(String body) async {
    final file = File('${dir.path}/daemon.sh');
    await file.writeAsString('#!/bin/sh\n$body\n');
    return file;
  }

  test('a start returns when the up check passes', () async {
    final made = manager({BinaryType.BINARY_TYPE_BITWINDOWD: () async => true});
    final binary = _LocalBitWindow((await script('sleep 30')).path);
    addTearDown(() => made.kill(binary));

    final elapsed = Stopwatch()..start();
    await made.start(binary, [], () async {});

    expect(elapsed.elapsed, lessThan(startCheckWindow), reason: 'the start waited out the full window');
    expect(made.isRunning(binary), isTrue);
  }, skip: Platform.isWindows);

  test('a start with no up check waits out the window', () async {
    final made = manager({});
    final binary = _LocalBitWindow((await script('sleep 30')).path);
    addTearDown(() => made.kill(binary));

    final elapsed = Stopwatch()..start();
    await made.start(binary, [], () async {});

    expect(elapsed.elapsed, greaterThanOrEqualTo(startCheckWindow));
  }, skip: Platform.isWindows);

  test('an early exit fails the start before the up check passes', () async {
    final made = manager({BinaryType.BINARY_TYPE_BITWINDOWD: () async => false});
    final binary = _LocalBitWindow((await script('exit 3')).path);

    await expectLater(made.start(binary, [], () async {}), throwsA(contains('exited with code 3')));
  }, skip: Platform.isWindows);

  test('a drivechaind start returns once the orchestrator port listens', () async {
    ServerSocket? server;
    try {
      server = await ServerSocket.bind(OrchestratorEndpoint.host, OrchestratorEndpoint.port);
    } on SocketException {
      // A drivechaind of this machine already serves the port.
    }
    addTearDown(() => server?.close());
    final made = manager({});
    final binary = _LocalDrivechaind((await script('sleep 30')).path);
    addTearDown(() => made.kill(binary));

    final elapsed = Stopwatch()..start();
    await made.start(binary, [], () async {});

    expect(elapsed.elapsed, lessThan(startCheckWindow), reason: 'the start waited out the full window');
  }, skip: Platform.isWindows);

  test('the TCP up check passes only for a port that listens', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    expect(await tcpUpCheck('127.0.0.1', port)(), isTrue);

    await server.close();
    expect(await tcpUpCheck('127.0.0.1', port)(), isFalse);
  });
}
