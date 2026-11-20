import 'dart:async';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:sidechain_core/utils/hidden_window_timers.dart';

/// The page of a sub-window, and the work that runs while it shows.
typedef SubWindowPage = ({Widget app, Timer? work});

/// Shows the pages of one sub-window engine. A close hides the window, drops
/// its page and pauses its timers, so that the engine can show the next page.
class SubWindowHost with WidgetsBindingObserver {
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
  final _ticking = ValueNotifier<bool>(false);
  String? _windowType;
  Timer? _work;
  bool _attached = false;
  Widget? _pending;
  Completer<void>? _drawn;

  /// Makes a close of the window hide it.
  Future<void> start() async {
    onWindowHidden.listen((_) => unawaited(_hide()));
    WidgetsBinding.instance.addObserver(this);
    await controller.setHideOnClose(true);
  }

  @override
  void didChangeMetrics() {
    // A resize blocks until a frame of the new size draws, so draw the page in it.
    final page = _pending;
    if (page != null) {
      _pending = null;
      _draw(page);
    }
  }

  /// Shows the window with a new page for [arguments].
  Future<void> open(Map<String, dynamic> arguments) async {
    timers.resume();
    final windowTitle = arguments['window_title'] as String?;
    if (windowTitle == null) {
      throw ArgumentError('Missing required arguments for multi-window mode: window_title');
    }
    final frame = Rect.fromLTWH(
      arguments['window_x'] as double? ?? 100,
      arguments['window_y'] as double? ?? 100,
      arguments['window_width'] as double? ?? 800,
      arguments['window_height'] as double? ?? 600,
    );
    unawaited(controller.setTitle(windowTitle));
    final page = buildPage(arguments);
    _windowType = arguments['window_type'] as String;
    _work = page.work;
    final app = KeyedSubtree(key: UniqueKey(), child: page.app);
    final drawn = _drawn = Completer<void>();
    if (_attached) {
      _pending = app;
      await controller.setFrame(frame);
      final unchanged = _pending;
      if (unchanged != null) {
        _pending = null;
        _draw(unchanged);
      }
    } else {
      // A window that never drew resizes at once.
      await controller.setFrame(frame);
      _attached = true;
      _app.value = app;
      SchedulerBinding.instance.addPostFrameCallback((_) => drawn.complete());
      runApp(
        ValueListenableBuilder<bool>(
          valueListenable: _ticking,
          builder: (_, ticking, _) => TickerMode(
            enabled: ticking,
            child: ValueListenableBuilder<Widget?>(
              valueListenable: _app,
              builder: (_, app, _) => app ?? const SizedBox(),
            ),
          ),
        ),
      );
    }
    // The page draws while the window is hidden, so the window shows with it.
    await drawn.future;
    await controller.show();
    _ticking.value = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      timers.runMissed();
      unawaited(announceShown());
    });
    SchedulerBinding.instance.scheduleFrame();
  }

  void _draw(Widget app) {
    final drawn = _drawn!;
    _app.value = app;
    SchedulerBinding.instance.addPostFrameCallback((_) => drawn.complete());
    SchedulerBinding.instance.scheduleWarmUpFrame();
  }

  Future<void> _hide() async {
    final windowType = _windowType!;
    _windowType = null;
    _work?.cancel();
    _work = null;
    _ticking.value = false;
    final dropped = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) => dropped.complete());
    _app.value = null;
    await dropped.future;
    timers.pause();
    await announceHidden(windowType);
  }
}
