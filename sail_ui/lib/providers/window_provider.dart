import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';

// Extension to add window control methods to WindowController
extension WindowControllerExtension on WindowController {
  Future<void> doCustomInitialize() async {
    return await setWindowMethodHandler((call) async {
      switch (call.method) {
        case 'window_set_frame':
          final args = call.arguments as Map<String, dynamic>;
          final x = args['x'] as double;
          final y = args['y'] as double;
          final width = args['width'] as double;
          final height = args['height'] as double;
          await windowManager.setPosition(Offset(x, y));
          await windowManager.setSize(Size(width, height));
          return;
        case 'window_set_title':
          final title = call.arguments as String;
          return await windowManager.setTitle(title);
        case 'window_show':
          return await windowManager.show();
        case 'window_close':
          return await windowManager.close();
        default:
          throw MissingPluginException('Not implemented: ${call.method}');
      }
    });
  }

  Future<void> setFrame(Rect frame) {
    return invokeMethod(
      'sail_ui_window_channel',
      MethodCall('window_set_frame', {
        'x': frame.left,
        'y': frame.top,
        'width': frame.width,
        'height': frame.height,
      }),
    );
  }

  Future<void> setTitle(String title) {
    return invokeMethod('sail_ui_window_channel', MethodCall('window_set_title', title));
  }

  Future<void> show() {
    return invokeMethod('sail_ui_window_channel', MethodCall('window_show'));
  }

  Future<void> close() {
    return invokeMethod('sail_ui_window_channel', MethodCall('window_close'));
  }
}

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

  int get windowCount => windows.length;
  bool get hasWindows => windows.isNotEmpty;

  WindowProvider._create({required this.logFile, required this.appDir});

  // Async factory
  static Future<WindowProvider> newInstance(File logFile, Directory appDir, {bool isMainWindow = false}) async {
    final instance = WindowProvider._create(logFile: logFile, appDir: appDir);
    await instance._initialize(isMainWindow: isMainWindow);
    return instance;
  }

  /// Initialize the window provider
  Future<void> _initialize({required bool isMainWindow}) async {
    // Only the main window registers the handler in unidirectional mode
    // Sub-windows can invoke methods but don't register
    if (isMainWindow) {
      const channel = WindowMethodChannel('sail_ui_window_channel', mode: ChannelMode.unidirectional);
      await channel.setMethodCallHandler(_handleMethodCall);
    }
  }

  /// Create a new window with the specified window type
  Future<WindowInfo?> open(SailWindow windowType) async {
    try {
      final screen = PlatformDispatcher.instance.displays.first;
      final physicalSize = screen.size;
      final devicePixelRatio = screen.devicePixelRatio;
      final actualScreenSize = Size(physicalSize.width / devicePixelRatio, physicalSize.height / devicePixelRatio);

      var windowPosition = windowType.defaultPosition ?? const Offset(100, 100);
      var windowSize = windowType.defaultSize ?? const Size(800, 600);

      // Calculate proportional sizes
      if (windowSize.width == double.maxFinite) {
        windowSize = Size(actualScreenSize.width, windowSize.height);
      } else if (windowSize.width > actualScreenSize.width) {
        final proportion = windowSize.width / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          windowSize = Size(actualScreenSize.width * proportion, windowSize.height);
        } else {
          windowSize = Size(actualScreenSize.width, windowSize.height);
        }
      }

      if (windowSize.height == double.maxFinite) {
        windowSize = Size(windowSize.width, actualScreenSize.height);
      } else if (windowSize.height > actualScreenSize.height) {
        final proportion = windowSize.height / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          windowSize = Size(windowSize.width, actualScreenSize.height * proportion);
        } else {
          windowSize = Size(windowSize.width, actualScreenSize.height);
        }
      }

      if (windowPosition.dx > actualScreenSize.width) {
        final proportion = windowPosition.dx / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          windowPosition = Offset(actualScreenSize.width * proportion, windowPosition.dy);
        } else {
          windowPosition = Offset(actualScreenSize.width, windowPosition.dy);
        }
      }

      if (windowPosition.dy > actualScreenSize.height) {
        final proportion = windowPosition.dy / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          windowPosition = Offset(windowPosition.dx, actualScreenSize.height * proportion);
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
      };

      final title = windowType.name;
      log.i('Creating window: $title with type: ${windowType.identifier}');

      final windowController = await WindowController.create(
        WindowConfiguration(
          hiddenAtLaunch: true,
          arguments: jsonEncode(windowConfig),
        ),
      );

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

  Future<dynamic> sendMessageTo(String windowId, String method, dynamic arguments) async {
    try {
      const channel = WindowMethodChannel('sail_ui_window_channel', mode: ChannelMode.unidirectional);
      final response = await channel.invokeMethod(method, arguments);
      return response;
    } catch (e) {
      log.e('could not send message to window $windowId: $e', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessageToAll(String method, dynamic arguments) async {
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
      const channel = WindowMethodChannel('sail_ui_window_channel', mode: ChannelMode.unidirectional);
      final response = await channel.invokeMethod(method, arguments);
      return response;
    } catch (e) {
      log.e('could not send message to main window: $e', error: e);
      rethrow;
    }
  }

  /// Handle incoming method calls from other windows
  Future<dynamic> _handleMethodCall(MethodCall call) async {
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
    return {'status': 'data_available', 'timestamp': DateTime.now().toIso8601String()};
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

  SailWindow({required this.name, this.defaultSize, this.defaultPosition, required this.identifier});
}

/// Class representing a window with its properties
class WindowInfo {
  final String id;
  final SailWindow windowType;
  final WindowController controller;
  final DateTime createdAt;

  WindowInfo({required this.id, required this.windowType, required this.controller, required this.createdAt});

  @override
  String toString() {
    return 'WindowInfo(id: $id, title: ${windowType.name}, windowType: ${windowType.identifier})';
  }
}

SailApp buildSailWindowApp(Logger log, String windowTitle, Widget child, Color accentColor) {
  return SailApp(
    log: log,
    dense: true,
    builder: (context) => MaterialApp(
      theme: ThemeData(visualDensity: VisualDensity.compact, fontFamily: 'Inter'),
      home: Scaffold(
        backgroundColor: SailTheme.of(context).colors.background,
        body: Column(
          children: [
            Container(
              height: 26,
              color: Colors.grey[200],
              alignment: Alignment.centerLeft,
              child: Center(child: SailText.primary13(windowTitle)),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    ),
    accentColor: accentColor,
  );
}
