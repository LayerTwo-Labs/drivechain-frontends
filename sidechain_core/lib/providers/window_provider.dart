// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

// WindowProvider lets you
// 1. Open new windows with predefined pages
// 2. Send messages between all different instances of windows
// 3. Close opened sub-windows, or close other sub-windows from a specific sub-window
//
// Example usage:
// await windowProvider.createWindow(windowType: BitWindowTypes.debug);
// await windowProvider.createWindow(windowType: BitWindowTypes.deniability);
// await windowProvider.createWindow(windowType: BitWindowTypes.blockExplorer);
class WindowProvider extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  final File logFile;
  final Directory appDir;

  List<WindowInfo> windows = [];

  /// A started hidden engine that the next [open] shows.
  WindowController? _spare;
  bool _spareStarting = false;

  /// Engines of closed sub-windows, oldest first. Each one can show any page.
  final List<_HiddenWindow> _hidden = [];

  int get windowCount => windows.length;
  bool get hasWindows => windows.isNotEmpty;

  WindowProvider._create({required this.logFile, required this.appDir});

  /// False where the app owns no OS windows, so [open] shows the window in the app.
  @visibleForTesting
  bool desktopWindows = hasDesktopWindow;

  /// Shows a window as a page in the app. [open] calls it where there are no desktop windows.
  Future<void> Function(SailWindow windowType, Map<String, dynamic> arguments)? openInApp;

  // Async factory
  static Future<WindowProvider> newInstance(
    File logFile,
    Directory appDir, {
    bool isMainWindow = false,
  }) async {
    final instance = WindowProvider._create(logFile: logFile, appDir: appDir);
    await instance._initialize(isMainWindow: isMainWindow);
    return instance;
  }

  /// Initialize the window provider
  Future<void> _initialize({required bool isMainWindow}) async {
    // Only the main window registers the handler in unidirectional mode
    // Sub-windows can invoke methods but don't register
    if (isMainWindow && hasDesktopWindow) {
      const channel = WindowMethodChannel(
        _windowChannel,
        mode: ChannelMode.unidirectional,
      );
      await channel.setMethodCallHandler(_handleMethodCall);
    }
  }

  /// Create a new window with the specified window type
  Future<WindowInfo?> open(SailWindow windowType, {Map<String, dynamic> arguments = const {}}) async {
    if (!desktopWindows) {
      final opener = openInApp;
      if (opener == null) {
        throw StateError('no in-app page for window ${windowType.identifier}');
      }
      await opener(windowType, arguments);
      return null;
    }
    try {
      final screen = PlatformDispatcher.instance.displays.first;
      final physicalSize = screen.size;
      final devicePixelRatio = screen.devicePixelRatio;
      final actualScreenSize = Size(
        physicalSize.width / devicePixelRatio,
        physicalSize.height / devicePixelRatio,
      );

      var windowPosition = windowType.defaultPosition ?? const Offset(100, 100);
      var windowSize = windowType.defaultSize ?? const Size(800, 600);

      // Calculate proportional sizes
      if (windowSize.width == double.maxFinite) {
        windowSize = Size(actualScreenSize.width, windowSize.height);
      } else if (windowSize.width > actualScreenSize.width) {
        final proportion = windowSize.width / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          windowSize = Size(
            actualScreenSize.width * proportion,
            windowSize.height,
          );
        } else {
          windowSize = Size(actualScreenSize.width, windowSize.height);
        }
      }

      if (windowSize.height == double.maxFinite) {
        windowSize = Size(windowSize.width, actualScreenSize.height);
      } else if (windowSize.height > actualScreenSize.height) {
        final proportion = windowSize.height / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          windowSize = Size(
            windowSize.width,
            actualScreenSize.height * proportion,
          );
        } else {
          windowSize = Size(windowSize.width, actualScreenSize.height);
        }
      }

      if (windowPosition.dx > actualScreenSize.width) {
        final proportion = windowPosition.dx / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          windowPosition = Offset(
            actualScreenSize.width * proportion,
            windowPosition.dy,
          );
        } else {
          windowPosition = Offset(actualScreenSize.width, windowPosition.dy);
        }
      }

      if (windowPosition.dy > actualScreenSize.height) {
        final proportion = windowPosition.dy / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          windowPosition = Offset(
            windowPosition.dx,
            actualScreenSize.height * proportion,
          );
        } else {
          windowPosition = Offset(windowPosition.dx, actualScreenSize.height);
        }
      }

      final windowConfig = {
        'window_type': windowType.identifier,
        'window_title': windowType.name,
        'application_dir': appDir.path,
        'log_file': logFile.path,
        'window_x': windowPosition.dx,
        'window_y': windowPosition.dy,
        'window_width': windowSize.width,
        'window_height': windowSize.height,
        ...arguments,
      };

      final title = windowType.name;
      log.i('Creating window: $title with type: ${windowType.identifier}');

      final pooled = _takeHidden(windowType.identifier) ?? _spare;
      if (pooled == _spare) {
        _spare = null;
      }
      final WindowController windowController;
      if (pooled != null) {
        await pooled.invokeMethod(openSpareMethod, jsonEncode(windowConfig));
        windowController = pooled;
      } else {
        windowController = await WindowController.create(
          WindowConfiguration(
            hiddenAtLaunch: true,
            arguments: jsonEncode(windowConfig),
          ),
        );
      }

      // Window will set its own position/size/title in runMultiWindow()

      final windowInfo = WindowInfo(
        id: windowController.windowId,
        windowType: windowType,
        controller: windowController,
        createdAt: DateTime.now(),
      );

      windows.add(windowInfo);
      notifyListeners();

      return windowInfo;
    } catch (e) {
      log.e('could not create window: $e', error: e);
      return null;
    }
  }

  /// Takes the engine of a closed [type] window, else the oldest closed one.
  WindowController? _takeHidden(String type) {
    if (_hidden.isEmpty) {
      return null;
    }
    final same = _hidden.lastIndexWhere((w) => w.type == type);
    return _hidden.removeAt(same == -1 ? 0 : same).controller;
  }

  /// Starts a hidden engine for the next [open], unless one is up or on its way.
  Future<void> startSpare() async {
    if (defaultTargetPlatform != TargetPlatform.macOS || _spare != null || _spareStarting || _hidden.isNotEmpty) {
      return;
    }
    _spareStarting = true;
    try {
      await WindowController.create(
        WindowConfiguration(
          arguments: jsonEncode({'spare': true, 'application_dir': appDir.path, 'log_file': logFile.path}),
        ),
      );
    } catch (e) {
      _spareStarting = false;
      rethrow;
    }
  }

  Future<bool> close(String windowId) async {
    try {
      final windowInfo = windows.firstWhere((w) => w.id == windowId);

      await windowInfo.controller.close();
      windows.removeWhere((w) => w.id == windowId);
      notifyListeners();

      return true;
    } catch (e) {
      log.e('could not close window $windowId: $e', error: e);
      return false;
    }
  }

  Future<void> closeAll() async {
    final windowsToClose = List<WindowInfo>.from(windows);
    for (final window in windowsToClose) {
      await close(window.id);
    }
  }

  Future<bool> focus(String windowId) async {
    try {
      final windowInfo = windows.firstWhere((w) => w.id == windowId);
      await windowInfo.controller.show();
      return true;
    } catch (e) {
      log.e('could not focus window $windowId: $e', error: e);
      return false;
    }
  }

  Future<dynamic> sendMessageTo(
    String windowId,
    String method,
    dynamic arguments,
  ) async {
    try {
      const channel = WindowMethodChannel(
        _windowChannel,
        mode: ChannelMode.unidirectional,
      );
      final response = await channel.invokeMethod(method, arguments);
      return response;
    } catch (e) {
      log.e('could not send message to window $windowId: $e', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessageToAll(
    String method,
    dynamic arguments,
  ) async {
    final responses = <String, dynamic>{};
    for (final window in windows) {
      try {
        final response = await sendMessageTo(window.id, method, arguments);
        responses[window.id] = response;
      } catch (e) {
        responses[window.id] = {'error': e.toString()};
      }
    }
    return responses;
  }

  Future<dynamic> sendMessageToMain(String method, dynamic arguments) async {
    try {
      const channel = WindowMethodChannel(
        _windowChannel,
        mode: ChannelMode.unidirectional,
      );
      final response = await channel.invokeMethod(method, arguments);
      return response;
    } catch (e) {
      log.e('could not send message to main window: $e', error: e);
      rethrow;
    }
  }

  /// Handle incoming method calls from other windows
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == processLogsMethod) {
      final arguments = call.arguments as Map<Object?, Object?>;
      final since = (arguments['since'] as Map<Object?, Object?>).cast<int, int>();
      final only = arguments['binary_type'] as int?;
      return GetIt.I.get<LogProvider>().entriesSince(since, only: only == null ? null : BinaryType.valueOf(only));
    }

    if (call.method == spareReadyMethod) {
      _spare = WindowController.fromWindowId(call.arguments as String);
      _spareStarting = false;
      return null;
    }
    if (call.method == windowShownMethod) {
      return startSpare();
    }
    if (call.method == windowHiddenMethod) {
      final arguments = (call.arguments as Map<Object?, Object?>).cast<String, String>();
      final id = arguments['id']!;
      windows.removeWhere((w) => w.id == id);
      _hidden.add(_HiddenWindow(WindowController.fromWindowId(id), arguments['type']!));
      notifyListeners();
      return null;
    }

    // In v3, the fromWindowId needs to be passed in the arguments if needed
    final arguments = call.arguments as Map<String, dynamic>?;
    final fromWindowId = arguments?['fromWindowId'] as String?;

    switch (call.method) {
      case 'window_closed':
        if (fromWindowId != null) {
          _handleWindowClosed(fromWindowId);
        }
        return 'Window close notification received';
      case 'window_focused':
        if (fromWindowId != null) {
          _handleWindowFocused(fromWindowId);
        }
        return 'Window focus notification received';
      case 'data_request':
        return _handleDataRequest(call.arguments);
      case 'status_update':
        if (fromWindowId != null) {
          _handleStatusUpdate(fromWindowId, call.arguments);
        }
        return 'Status update received';
      default:
        log.w('Unknown method call: ${call.method}');
        return null;
    }
  }

  void _handleWindowClosed(String windowId) {
    windows.removeWhere((w) => w.id == windowId);
    notifyListeners();
  }

  void _handleWindowFocused(String windowId) {}

  dynamic _handleDataRequest(dynamic arguments) {
    return {
      'status': 'data_available',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void _handleStatusUpdate(String fromWindowId, dynamic arguments) {}

  WindowInfo? getByID(String windowId) {
    try {
      return windows.firstWhere((w) => w.id == windowId);
    } catch (e) {
      return null;
    }
  }
}

const _windowChannel = 'sail_ui_window_channel';

const processLogsMethod = 'process_logs';

/// True for the arguments of a hidden engine that waits for a sub-window.
bool isSpareWindowArguments(String arguments) =>
    arguments.isNotEmpty && (jsonDecode(arguments) as Map<String, dynamic>)['spare'] == true;

/// A spare or hidden engine shows the sub-window of the given arguments.
const openSpareMethod = 'open_spare';

/// A sub-window tells the main window that it hid on close and can show a new page.
const windowHiddenMethod = 'window_hidden';

/// Tells the main window that the engine [windowId] hid its [type] window.
Future<void> announceHiddenWindow(String windowId, String type) => const WindowMethodChannel(
  _windowChannel,
  mode: ChannelMode.unidirectional,
).invokeMethod(windowHiddenMethod, {'id': windowId, 'type': type});

/// A spare engine tells the main window that it can take a sub-window.
const spareReadyMethod = 'spare_ready';

/// A sub-window tells the main window that it drew its first frame.
const windowShownMethod = 'window_shown';

/// Tells the main window that the spare engine [windowId] is ready.
Future<void> announceSpareWindow(String windowId) => const WindowMethodChannel(
  _windowChannel,
  mode: ChannelMode.unidirectional,
).invokeMethod(spareReadyMethod, windowId);

/// Copies the process output the main window holds into [target] of a sub-window.
class ProcessLogRelay {
  final WindowProvider windows;
  final LogProvider target;
  final Map<int, int> _next;
  bool _pulling = false;

  final BinaryType? only;

  /// Relays that share [cursors] copy each entry one time.
  ProcessLogRelay(this.windows, this.target, {this.only, Map<int, int>? cursors}) : _next = cursors ?? {};

  Future<void> pull() async {
    if (_pulling) {
      return;
    }
    _pulling = true;
    try {
      final reply = await windows.sendMessageToMain(processLogsMethod, {
        'since': _next,
        'binary_type': ?only?.value,
      });
      _next.addAll(target.addEntriesSince(reply as Map<Object?, Object?>));
    } finally {
      _pulling = false;
    }
  }

  Timer start({Duration interval = const Duration(seconds: 1)}) {
    unawaited(_pullLogged());
    return Timer.periodic(interval, (_) => unawaited(_pullLogged()));
  }

  Future<void> _pullLogged() => pull().catchError((Object e) {
    windows.log.w('could not copy process logs from the main window: $e');
  });
}

/// WindowType lets you create different types of pages that can be opened in a subwindow.
/// Once created, you can easily open/close/manage a specific window.
class SailWindow {
  /// Get the display name for this window type
  String name;

  /// Get the default size for this window type
  Size? defaultSize;

  /// Get the default position for this window type
  Offset? defaultPosition;

  /// Get the unique identifier for this window type
  String identifier;

  SailWindow({
    required this.name,
    this.defaultSize,
    this.defaultPosition,
    required this.identifier,
  });
}

class _HiddenWindow {
  final WindowController controller;
  final String type;

  _HiddenWindow(this.controller, this.type);
}

/// Class representing a window with its properties
class WindowInfo {
  final String id;
  final SailWindow windowType;
  final WindowController controller;
  final DateTime createdAt;

  WindowInfo({
    required this.id,
    required this.windowType,
    required this.controller,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'WindowInfo(id: $id, title: ${windowType.name}, windowType: ${windowType.identifier})';
  }
}
