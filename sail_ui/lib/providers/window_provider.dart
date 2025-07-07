import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

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

  WindowProvider._create({
    required this.logFile,
    required this.appDir,
  });

  // Async factory
  static Future<WindowProvider> newInstance(
    File logFile,
    Directory appDir,
  ) async {
    final instance = WindowProvider._create(
      logFile: logFile,
      appDir: appDir,
    );
    await instance._initialize();
    return instance;
  }

  /// Initialize the window provider
  Future<void> _initialize() async {
    // Set up method handler for receiving messages from other windows
    DesktopMultiWindow.setMethodHandler(_handleMethodCall);
  }

  /// Create a new window with the specified window type
  Future<WindowInfo?> open(
    SailWindow windowType,
  ) async {
    try {
      final windowConfig = {
        'window_type': windowType.identifier,
        'window_title': windowType.name,
        'application_dir': appDir.path,
        'log_file': logFile.path,
      };

      final title = windowType.name;
      log.i('Creating window: $title with type: ${windowType.identifier}');

      final windowController = await DesktopMultiWindow.createWindow(
        jsonEncode(windowConfig),
      );

      final screen = PlatformDispatcher.instance.displays.first;
      // Get the actual physical size (accounting for display scaling)
      final physicalSize = screen.size;
      final devicePixelRatio = screen.devicePixelRatio;
      final actualScreenSize = Size(
        physicalSize.width / devicePixelRatio,
        physicalSize.height / devicePixelRatio,
      );

      var windowPosition = windowType.defaultPosition ?? const Offset(100, 100);
      var windowSize = windowType.defaultSize ?? const Size(800, 600);

      // If set to some proportion of maxFinite, USE THAT PROPORTION relative to the actualScreenSize
      // For example if defaultSize == maxFinite / 2, then windowSize = actualScreenSize / 2
      // If defaultSize == maxFinite, then windowSize = actualScreenSize
      if (windowSize.width == double.maxFinite) {
        windowSize = Size(actualScreenSize.width, windowSize.height);
      } else if (windowSize.width > actualScreenSize.width) {
        // Check if it's a proportion of maxFinite
        final proportion = windowSize.width / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          final newWidth = actualScreenSize.width * proportion;
          windowSize = Size(newWidth, windowSize.height);
        } else {
          windowSize = Size(actualScreenSize.width, windowSize.height);
        }
      }

      if (windowSize.height == double.maxFinite) {
        windowSize = Size(windowSize.width, actualScreenSize.height);
      } else if (windowSize.height > actualScreenSize.height) {
        // Check if it's a proportion of maxFinite
        final proportion = windowSize.height / double.maxFinite;
        if (proportion > 0 && proportion <= 1) {
          final newHeight = actualScreenSize.height * proportion;
          windowSize = Size(windowSize.width, newHeight);
        } else {
          windowSize = Size(windowSize.width, actualScreenSize.height);
        }
      }

      // now do the exact same for window offset/position!
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

      await windowController.setFrame(windowPosition & windowSize);
      await windowController.setTitle(title);
      await windowController.show();

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

  Future<bool> close(int windowId) async {
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

  Future<bool> focus(int windowId) async {
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
    int windowId,
    String method,
    dynamic arguments,
  ) async {
    try {
      final response = await DesktopMultiWindow.invokeMethod(
        windowId,
        method,
        arguments,
      );
      return response;
    } catch (e) {
      log.e('could not send message to window $windowId: $e', error: e);
      rethrow;
    }
  }

  Future<Map<int, dynamic>> sendMessageToAll(
    String method,
    dynamic arguments,
  ) async {
    final responses = <int, dynamic>{};
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

  Future<dynamic> sendMessageToMain(
    String method,
    dynamic arguments,
  ) async {
    try {
      final response = await DesktopMultiWindow.invokeMethod(0, method, arguments);
      return response;
    } catch (e) {
      log.e('could not send message to main window: $e', error: e);
      rethrow;
    }
  }

  /// Handle incoming method calls from other windows
  Future<dynamic> _handleMethodCall(MethodCall call, int fromWindowId) async {
    switch (call.method) {
      case 'window_closed':
        _handleWindowClosed(fromWindowId);
        return 'Window close notification received';
      case 'window_focused':
        _handleWindowFocused(fromWindowId);
        return 'Window focus notification received';
      case 'data_request':
        return _handleDataRequest(call.arguments);
      case 'status_update':
        _handleStatusUpdate(fromWindowId, call.arguments);
        return 'Status update received';
      default:
        log.w('Unknown method call: ${call.method}');
        return null;
    }
  }

  void _handleWindowClosed(int windowId) {
    windows.removeWhere((w) => w.id == windowId);
    notifyListeners();
  }

  void _handleWindowFocused(int windowId) {}

  dynamic _handleDataRequest(dynamic arguments) {
    return {'status': 'data_available', 'timestamp': DateTime.now().toIso8601String()};
  }

  void _handleStatusUpdate(int fromWindowId, dynamic arguments) {}

  WindowInfo? getByID(int windowId) {
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

  SailWindow({
    required this.name,
    this.defaultSize,
    this.defaultPosition,
    required this.identifier,
  });
}

/// Class representing a window with its properties
class WindowInfo {
  final int id;
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

SailApp buildSailWindowApp(Logger log, String windowTitle, Widget child, Color accentColor) {
  return SailApp(
    log: log,
    dense: true,
    builder: (context) => MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
        fontFamily: 'Inter',
      ),
      home: Scaffold(
        backgroundColor: SailTheme.of(context).colors.background,
        body: Column(
          children: [
            Container(
              height: 26,
              color: Colors.grey[200],
              alignment: Alignment.centerLeft,
              child: Center(
                child: SailText.primary13(
                  windowTitle,
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    ),
    accentColor: accentColor,
  );
}
