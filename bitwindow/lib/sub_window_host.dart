import 'dart:async';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:sidechain_core/utils/hidden_window_timers.dart';

/// The page of a sub-window, and the work that runs while it shows.
typedef SubWindowPage = ({Widget app, Timer? work});

/// Shows the pages of one sub-window engine. A close hides the window, drops
/// its page and pauses its timers, so that the engine can show the next page.
class SubWindowHost {
  SubWindowHost({
    required this.controller,
    required this.timers,
    required this.buildPage,
    required this.announceShown,
    required this.announceHidden,
  });

  final WindowController controller;
  final HiddenWindowTimers timers;
  final SubWindowPage Function(Map<String, dynamic> arguments) buildPage;
  final Future<void> Function() announceShown;
  final Future<void> Function(String windowType) announceHidden;

  final _app = ValueNotifier<Widget?>(null);
  String? _windowType;
  Timer? _work;
  bool _attached = false;

  /// Makes a close of the window hide it.
  Future<void> start() async {
    onWindowHidden.listen((_) => unawaited(_hide()));
    await controller.setHideOnClose(true);
  }

  /// Shows the window with a new page for [arguments].
  Future<void> open(Map<String, dynamic> arguments) async {
    timers.resume();
    final windowTitle = arguments['window_title'] as String?;
    if (windowTitle == null) {
      throw ArgumentError('Missing required arguments for multi-window mode: window_title');
    }
    await controller.setFrame(
      Rect.fromLTWH(
        arguments['window_x'] as double? ?? 100,
        arguments['window_y'] as double? ?? 100,
        arguments['window_width'] as double? ?? 800,
        arguments['window_height'] as double? ?? 600,
      ),
    );
    await controller.setTitle(windowTitle);
    await controller.show();

    final page = buildPage(arguments);
    _windowType = arguments['window_type'] as String;
    _work = page.work;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      timers.runMissed();
      unawaited(announceShown());
    });
    _app.value = KeyedSubtree(key: UniqueKey(), child: page.app);
    if (_attached) {
      SchedulerBinding.instance.scheduleWarmUpFrame();
      return;
    }
    _attached = true;
    // Not empty: a resize of a hidden window waits for a drawn frame of the new size.
    runApp(
      ValueListenableBuilder<Widget?>(
        valueListenable: _app,
        builder: (_, app, _) => app ?? const ColoredBox(color: Color(0xFF000000)),
      ),
    );
  }

  Future<void> _hide() async {
    final windowType = _windowType!;
    _windowType = null;
    _work?.cancel();
    _work = null;
    final dropped = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) => dropped.complete());
    _app.value = null;
    await dropped.future;
    timers.pause();
    await announceHidden(windowType);
  }
}
