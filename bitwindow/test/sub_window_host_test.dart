import 'dart:async';

import 'package:bitwindow/sub_window_host.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/hidden_window_timers.dart';

const _windows = MethodChannel('mixin.one/desktop_multi_window');

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  void tap() => setState(() => taps++);

  @override
  Widget build(BuildContext context) => Text('taps $taps', textDirection: TextDirection.ltr);
}

void main() {
  testWidgets('a close drops the page and pauses the timers, and the next open builds a new page', (tester) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    final calls = <String>[];
    messenger.setMockMethodCallHandler(_windows, (call) async {
      calls.add(call.method);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(_windows, null));
    final timers = HiddenWindowTimers();
    final hidden = <String>[];
    var shown = 0;
    final work = <Timer>[];
    final host = SubWindowHost(
      controller: WindowController.fromWindowId('w1'),
      timers: timers,
      buildPage: (arguments) {
        work.add(Timer(const Duration(days: 1), () {}));
        return (app: const _Counter(), work: work.last);
      },
      announceShown: () async => shown++,
      announceHidden: (windowType) async => hidden.add(windowType),
    );
    final arguments = {'window_type': 'hash_calculator', 'window_title': 'Hash Calculator'};

    await host.start();
    await host.open(arguments);
    await tester.pump();
    expect(find.text('taps 0'), findsOneWidget);
    expect(shown, 1);
    expect(calls, ['window_set_hide_on_close', 'window_set_frame', 'window_set_title', 'window_show']);
    tester.state<_CounterState>(find.byType(_Counter))
      ..tap()
      ..tap()
      ..tap();
    await tester.pump();
    expect(find.text('taps 3'), findsOneWidget);

    await messenger.handlePlatformMessage(
      _windows.name,
      _windows.codec.encodeMethodCall(const MethodCall('onWindowHidden', {})),
      (_) {},
    );
    await tester.pump();
    expect(find.byType(_Counter), findsNothing);
    expect(timers.paused, isTrue);
    expect(hidden, ['hash_calculator']);

    await host.open(arguments);
    await tester.pump();
    expect(find.text('taps 0'), findsOneWidget);
    expect(timers.paused, isFalse);
    expect(shown, 2);
    expect(work.first.isActive, isFalse);
    expect(work.last.isActive, isTrue);
    work.last.cancel();
  });
}
