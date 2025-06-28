import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Settings provider that manages individual setting variables
/// with automatic persistence and change notification.
class SettingsProvider extends ChangeNotifier {
  ClientSettings get clientSettings => GetIt.I.get<ClientSettings>();
  Logger get log => GetIt.I.get<Logger>();

  // Individual setting variables
  bool debugMode = false;
  bool launcherMode = false;

  SettingsProvider() {
    _loadAllSettings();
  }

  /// Load all settings from storage
  Future<void> _loadAllSettings() async {
    await _loadDebugMode();
    await _loadLauncherMode();
  }

  /// Load debug mode setting
  Future<void> _loadDebugMode() async {
    final setting = DebugModeSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    debugMode = loadedSetting.value;
  }

  /// Load launcher mode setting
  Future<void> _loadLauncherMode() async {
    final setting = LauncherModeSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    launcherMode = loadedSetting.value;
  }

  /// Update debug mode setting
  Future<void> updateDebugMode(bool value) async {
    if (debugMode == value) {
      return;
    }

    try {
      debugMode = value;
      notifyListeners();
      final setting = DebugModeSetting(newValue: value);
      await clientSettings.setValue(setting);
    } catch (e) {
      // Revert on error
      debugMode = !value;
      notifyListeners();
      log.e('Failed to update debug mode', error: e);
      rethrow;
    }
  }

  Future<void> updateLauncherMode(bool value) async {
    if (launcherMode == value) {
      return;
    }

    try {
      launcherMode = value;
      notifyListeners();

      final setting = LauncherModeSetting(newValue: value);
      await clientSettings.setValue(setting);
    } catch (e) {
      // Revert on error
      launcherMode = !value;
      notifyListeners();
      log.e('Failed to update launcher mode', error: e);
      rethrow;
    }
  }
}

// Default export for the settings provider
SettingsProvider settingsProvider = SettingsProvider();
