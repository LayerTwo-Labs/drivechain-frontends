import 'dart:async';

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
  bool useTestSidechains = false;
  SailFontValues font = SailFontValues.inter;

  // Private constructor
  SettingsProvider._create();

  // Async factory
  static Future<SettingsProvider> create() async {
    final instance = SettingsProvider._create();
    unawaited(instance._loadAllSettings()); // unawaited to make bootup faster
    return instance;
  }

  /// Load all settings from storage
  Future<void> _loadAllSettings() async {
    await _loadDebugMode();
    await _loadUseTestSidechains();
    await _loadFont();
  }

  /// Load debug mode setting
  Future<void> _loadDebugMode() async {
    final setting = DebugModeSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    debugMode = loadedSetting.value;
    notifyListeners();
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

  /// Load use test sidechains setting
  Future<void> _loadUseTestSidechains() async {
    final setting = UseTestSidechainsSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    useTestSidechains = loadedSetting.value;
    notifyListeners();
  }

  /// Update use test sidechains setting
  Future<void> updateUseTestSidechains(bool value) async {
    if (useTestSidechains == value) {
      return;
    }

    try {
      useTestSidechains = value;
      notifyListeners();
      final setting = UseTestSidechainsSetting(newValue: value);
      await clientSettings.setValue(setting);

      // delete all binaries so we can redownload the correct ones
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      final wipeOperations = binaryProvider.binaries
          .where((binary) => binary.chainLayer == 2)
          .map((binary) => binary.wipeAsset(binDir(binaryProvider.appDir.path)));
      await Future.wait(wipeOperations);
    } catch (e) {
      // Revert on error
      useTestSidechains = !value;
      notifyListeners();
      log.e('Failed to update use test sidechains', error: e);
      rethrow;
    }
  }

  /// Load font setting
  Future<void> _loadFont() async {
    final setting = FontSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    font = loadedSetting.value;
    notifyListeners();
  }

  /// Update font setting
  Future<void> updateFont(SailFontValues value) async {
    if (font == value) {
      return;
    }

    try {
      font = value;
      notifyListeners();
      final setting = FontSetting(newValue: value);
      await clientSettings.setValue(setting);
    } catch (e) {
      // Revert on error
      font = font == SailFontValues.inter ? SailFontValues.sourceCodePro : SailFontValues.inter;
      notifyListeners();
      log.e('Failed to update font', error: e);
      rethrow;
    }
  }
}
