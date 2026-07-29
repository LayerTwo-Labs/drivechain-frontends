import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('bitwindow/daemon_job');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('binds a daemon by pid on Windows', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });

    final bound = await DaemonJob.bind(4242);

    if (!Platform.isWindows) {
      expect(bound, isFalse, reason: 'no job object off Windows');
      expect(calls, isEmpty);
      return;
    }

    expect(bound, isTrue);
    expect(calls, hasLength(1));
    expect(calls.single.method, 'bind');
    expect(calls.single.arguments, {'pid': 4242});
  });

  // A runner without the channel — every sidechain app — must not break daemon
  // startup, so a missing implementation is a false, never a throw.
  test('a runner without the channel returns false instead of throwing', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw MissingPluginException('no implementation');
    });

    await expectLater(DaemonJob.bind(1), completion(isFalse));
  });
}
