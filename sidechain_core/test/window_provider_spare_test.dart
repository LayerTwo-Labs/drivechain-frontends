import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/providers/window_provider.dart';

const _windows = MethodChannel('mixin.one/desktop_multi_window');
const _channels = MethodChannel('mixin.one/desktop_multi_window/channels');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<String> created;
  late List<(String, String)> invoked;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    created = [];
    invoked = [];
    messenger.setMockMethodCallHandler(_windows, (call) async {
      if (call.method != 'createWindow') {
        return null;
      }
      final arguments = (call.arguments as Map)['arguments'] as String;
      created.add(arguments);
      return 'window-${created.length}';
    });
    messenger.setMockMethodCallHandler(_channels, (call) async {
      if (call.method == 'invokeMethod') {
        final arguments = call.arguments as Map;
        invoked.add((arguments['channel'] as String, arguments['method'] as String));
      }
      return null;
    });
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(_windows, null);
    messenger.setMockMethodCallHandler(_channels, null);
    await GetIt.I.reset();
  });

  Future<void> fromSubWindow(String method, Object? arguments) async {
    await messenger.handlePlatformMessage(
      _channels.name,
      _channels.codec.encodeMethodCall(
        MethodCall('methodCall', {'channel': 'sail_ui_window_channel', 'method': method, 'arguments': arguments}),
      ),
      (_) {},
    );
  }

  test('an open shows the ready spare engine, and the next open starts a new engine', () async {
    final dir = Directory.systemTemp;
    final windows = await WindowProvider.newInstance(File('${dir.path}/log'), dir, isMainWindow: true);
    final type = SailWindow(name: 'Hash Calculator', identifier: 'hash_calculator');

    await windows.startSpare();
    expect(created, hasLength(1));
    expect(isSpareWindowArguments(created.single), isTrue);
    await fromSubWindow(spareReadyMethod, 'window-1');

    final first = await windows.open(type);
    expect(first!.id, 'window-1');
    expect(created, hasLength(1));
    expect(invoked, [('mixin.one/window_controller/window-1', openSpareMethod)]);

    final second = await windows.open(type);
    expect(second!.id, 'window-2');
    expect((jsonDecode(created.last) as Map)['window_type'], 'hash_calculator');

    await fromSubWindow(windowShownMethod, null);
    expect(created, hasLength(3));
    expect(isSpareWindowArguments(created.last), isTrue);
  });
}
