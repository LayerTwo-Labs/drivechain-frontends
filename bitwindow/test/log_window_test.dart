import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/log_window.dart';
import 'package:bitwindow/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const multiWindowChannel = MethodChannel('mixin.one/desktop_multi_window');
  final createdWindows = <Map<String, dynamic>>[];

  setUp(() async {
    await GetIt.I.reset();
    createdWindows.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      multiWindowChannel,
      (call) async {
        if (call.method != 'createWindow') {
          return null;
        }
        final configuration = Map<String, dynamic>.from(call.arguments as Map);
        createdWindows.add(jsonDecode(configuration['arguments'] as String) as Map<String, dynamic>);
        return '${createdWindows.length}';
      },
    );
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<WindowProvider>(
      await WindowProvider.newInstance(File('/data/bitwindow.log'), Directory('/data')),
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      multiWindowChannel,
      null,
    );
  });

  test('a daemon log opens in its own window with that daemon log', () async {
    await openLogWindow('Bitcoin Core', '/data/bitcoin/debug.log', BinaryType.BINARY_TYPE_BITCOIND);

    expect(createdWindows, hasLength(1));
    final window = createdWindows.single;
    expect(window['window_type'], SubWindowTypes.logsId);
    expect(window['window_title'], 'Bitcoin Core');

    final logWindow = LogWindowArguments.fromWindowArguments(window, bitwindowLogPath: '/data/bitwindow.log');
    expect(logWindow.title, 'Bitcoin Core');
    expect(logWindow.logPath, '/data/bitcoin/debug.log');
    expect(logWindow.binaryType, BinaryType.BINARY_TYPE_BITCOIND);
  });

  test('the menu log window shows the bitwindow log', () async {
    await GetIt.I.get<WindowProvider>().open(SubWindowTypes.logs);

    final logWindow = LogWindowArguments.fromWindowArguments(
      createdWindows.single,
      bitwindowLogPath: '/data/bitwindow.log',
    );
    expect(logWindow.title, 'Bitwindow Logs');
    expect(logWindow.logPath, '/data/bitwindow.log');
    expect(logWindow.binaryType, isNull);
  });

  group('process output in a log window', () {
    const windowChannels = MethodChannel('mixin.one/desktop_multi_window/channels');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    setUp(() async {
      await GetIt.I.reset();
      messenger.setMockMethodCallHandler(windowChannels, (call) async {
        if (call.method != 'invokeMethod') {
          return null;
        }
        final request = call.arguments as Map<Object?, Object?>;
        final reply = Completer<ByteData?>();
        await messenger.handlePlatformMessage(
          windowChannels.name,
          windowChannels.codec.encodeMethodCall(MethodCall('methodCall', request)),
          reply.complete,
        );
        return windowChannels.codec.decodeEnvelope((await reply.future)!);
      });
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
      GetIt.I.registerSingleton<LogProvider>(LogProvider());
      GetIt.I.registerSingleton<WindowProvider>(
        await WindowProvider.newInstance(File('/data/bitwindow.log'), Directory('/data'), isMainWindow: true),
      );
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(windowChannels, null);
    });

    FullProcessLogEntry bitwindowd(String message, {bool isStderr = false}) => FullProcessLogEntry(
      timestamp: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      message: message,
      isStderr: isStderr,
      binaryType: BinaryType.BINARY_TYPE_BITWINDOWD,
    );

    test('the bitwindowd window shows the output the main window captured', () async {
      final mainLogs = GetIt.I.get<LogProvider>();
      mainLogs.addStartupMarker(BinaryType.BINARY_TYPE_BITWINDOWD, 'bitwindowd');
      mainLogs.addLog(bitwindowd('listening on :2122'));

      mainLogs.addLog(
        FullProcessLogEntry(
          timestamp: DateTime.now(),
          message: 'bitcoind line',
          isStderr: false,
          binaryType: BinaryType.BINARY_TYPE_BITCOIND,
        ),
      );

      final windowLogs = LogProvider();
      final relay = ProcessLogRelay(
        GetIt.I.get<WindowProvider>(),
        windowLogs,
        only: BinaryType.BINARY_TYPE_BITWINDOWD,
      );
      await relay.pull();

      mainLogs.addLog(bitwindowd('panic: boom', isStderr: true));
      await relay.pull();
      await relay.pull();

      final lines = windowLogs.getLogsForBinary(BinaryType.BINARY_TYPE_BITWINDOWD);
      expect(lines.map((e) => e.message).skip(1), ['listening on :2122', 'panic: boom']);
      expect(lines.first.isStartupMarker, isTrue);
      expect(lines.last.isStderr, isTrue);
      expect(lines[1].timestamp, DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(windowLogs.hasLogsForBinary(BinaryType.BINARY_TYPE_BITCOIND), isFalse);
    });

    test('a relay behind the eviction gets the entries the main window still holds', () {
      final mainLogs = GetIt.I.get<LogProvider>();
      for (var i = 0; i < 12; i++) {
        mainLogs.addLog(bitwindowd('$i${'x' * 1000000}'));
      }
      final held = mainLogs.getLogsForBinary(BinaryType.BINARY_TYPE_BITWINDOWD);
      expect(held.length, lessThan(12));

      final batch = mainLogs.entriesSince({})[BinaryType.BINARY_TYPE_BITWINDOWD.value]!;
      expect(batch['next'], 12);
      expect((batch['entries'] as List).map((e) => (e as List)[1]), held.map((e) => e.message));
    });
  });
}
