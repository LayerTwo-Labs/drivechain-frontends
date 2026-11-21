import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _FakeNative implements BackendNative {
  final starts = <Map<String, dynamic>>[];
  String? startError;
  bool running = false;
  bool stopExits = true;
  String? exitError;
  int stops = 0;

  @override
  String? start(String config) {
    starts.add(jsonDecode(config) as Map<String, dynamic>);
    if (startError != null) {
      return startError;
    }
    running = true;
    exitError = null;
    return null;
  }

  @override
  void stop() {
    stops++;
    if (stopExits) {
      running = false;
    }
  }

  @override
  String status() => jsonEncode({'running': running, 'error': ?exitError});

  void crash(String error) {
    running = false;
    exitError = error;
  }
}

const _fast = Duration(milliseconds: 10);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackendStatus', () {
    test('reads a running backend', () {
      final status = BackendStatus.fromJson('{"running":true}');
      expect(status.running, isTrue);
      expect(status.error, isNull);
    });

    test('reads the exit error', () {
      final status = BackendStatus.fromJson('{"running":false,"error":"listen refused"}');
      expect(status.running, isFalse);
      expect(status.error, 'listen refused');
    });
  });

  group('InProcessBackend', () {
    late _FakeNative native;
    late InProcessBackend backend;

    setUp(() {
      native = _FakeNative();
      backend = InProcessBackend(native, pollEvery: _fast, stopTimeout: const Duration(milliseconds: 200));
      addTearDown(backend.dispose);
    });

    test('a start passes the flags and the environment as one JSON config', () async {
      await backend.start(BitWindow(), ['--owner-pid=7'], {'BITWINDOW_HOME': '/data'});

      expect(native.starts.single, {
        'args': ['--owner-pid=7'],
        'env': {'BITWINDOW_HOME': '/data'},
      });
      expect(backend.isRunning(BitWindow()), isTrue);
    });

    test('a start error reaches the caller', () async {
      native.startError = 'bitwindowd already runs in this process';

      await expectLater(
        backend.start(BitWindow(), [], {}),
        throwsA(isA<StateError>().having((e) => e.message, 'message', contains('already runs'))),
      );
      expect(backend.isRunning(BitWindow()), isFalse);
    });

    test('only bitwindowd runs in process', () async {
      await expectLater(backend.start(Drivechaind(), [], {}), throwsUnsupportedError);
      expect(native.starts, isEmpty);
    });

    test('an exit of the backend reaches the listeners with its error', () async {
      await backend.start(BitWindow(), [], {});
      var notified = 0;
      backend.addListener(() => notified++);

      native.crash('drivechaind: listen tcp: address in use');
      await Future.delayed(_fast * 5);

      expect(backend.isRunning(BitWindow()), isFalse);
      expect(backend.exitError, 'drivechaind: listen tcp: address in use');
      expect(notified, 1);
    });

    test('a stop waits until the backend is gone', () async {
      await backend.start(BitWindow(), [], {});

      await backend.stop(BitWindow());

      expect(native.stops, 1);
      expect(backend.isRunning(BitWindow()), isFalse);
    });

    test('a stop of a backend that does not go fails', () async {
      native.stopExits = false;
      await backend.start(BitWindow(), [], {});

      await expectLater(backend.stop(BitWindow()), throwsStateError);
    });

    test('a stop reports the error the backend ended with', () async {
      await backend.start(BitWindow(), [], {});
      native.stopExits = false;
      final stopping = backend.stop(BitWindow());
      native.crash('close RPC server: boom');

      await expectLater(stopping, throwsA(isA<StateError>().having((e) => e.message, 'message', contains('boom'))));
    });
  });

  group('BinaryProvider with an in-process backend', () {
    late Directory dir;

    setUpAll(() {
      GetIt.instance.registerSingleton<Logger>(Logger(level: Level.off));
      GetIt.instance.registerSingleton<LogProvider>(LogProvider());
    });

    tearDownAll(() async {
      await GetIt.instance.reset();
    });

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('in_process_backend');
      addTearDown(() => dir.delete(recursive: true));
    });

    test('starts and stops bitwindowd in the app process', () async {
      final native = _FakeNative();
      final binary = BitWindow(extraBootArgs: ['--log.level=debug']);
      final provider = BinaryProvider.test(
        appDir: dir,
        binaries: [binary],
        inProcess: InProcessBackend(native, pollEvery: _fast),
      );
      addTearDown(provider.dispose);

      await provider.start(binary);
      expect(native.starts.single['args'], ['--log.level=debug']);
      expect(provider.isConnected(binary), isTrue);
      expect(provider.isAdopted(binary), isFalse);
      expect(await provider.ownerAlive(binary), isFalse);

      await provider.stop(binary);
      expect(native.stops, 1);
      expect(provider.isConnected(binary), isFalse);
    });

    test('a backend that exits gets another start', () async {
      final native = _FakeNative();
      final binary = BitWindow();
      final provider = BinaryProvider.test(
        appDir: dir,
        binaries: [binary],
        inProcess: InProcessBackend(native, pollEvery: _fast),
      );
      addTearDown(provider.dispose);

      await provider.start(binary);
      native.crash('drivechaind exited');
      await Future.delayed(const Duration(milliseconds: 2500));

      expect(native.starts, hasLength(2), reason: 'the app must not keep a dead backend');
      expect(provider.isConnected(binary), isTrue);
    });
  });
}
