import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// Settings provider that manages individual setting variables
/// with automatic persistence and change notification.
class SettingsProvider extends ChangeNotifier {
  ClientSettings get clientSettings => GetIt.I.get<ClientSettings>();
  BitwindowClientSettings get bitwindowClientSettings => GetIt.I.get<BitwindowClientSettings>();
  Logger get log => GetIt.I.get<Logger>();

  // Individual setting variables
  bool debugMode = false;
  BitwindowSettings bitwindowSettings = BitwindowSettings();
  SailFontValues font = SailFontValues.inter;
  double fontScale = 1.0;
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;

  // Convenience getters for individual bitwindow settings
  // Note: blocks directory is managed by BitcoinConfProvider

  // Private constructor
  SettingsProvider._create();

  // Async factory
  static Future<SettingsProvider> create() async {
    final instance = SettingsProvider._create();
    await instance._loadAllSettings(); // Wait for settings to load to ensure correct initial state
    return instance;
  }

  /// Load all settings from storage
  Future<void> _loadAllSettings() async {
    await _loadDebugMode();
    await _loadBitwindowSettings();
    await _loadFont();
    await _loadFontScale();
    await _loadBitcoinUnit();
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

  /// Load bitwindow settings
  Future<void> _loadBitwindowSettings() async {
    try {
      final setting = BitwindowSettingValue();
      final loadedSetting = await bitwindowClientSettings.getValue(setting);
      bitwindowSettings = loadedSetting.value;
    } catch (e) {
      // If loading fails, use default settings
      log.d('Failed to load bitwindow settings, using defaults: $e');
      bitwindowSettings = BitwindowSettings();
    }
    notifyListeners();
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
      font = font == SailFontValues.inter ? SailFontValues.ibmMono : SailFontValues.inter;
      notifyListeners();
      log.e('Failed to update font', error: e);
      rethrow;
    }
  }

  /// Load font scale setting
  Future<void> _loadFontScale() async {
    final setting = FontScaleSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    fontScale = loadedSetting.value;
    notifyListeners();
  }

  /// Serializes font scale writes. Dragging the slider fires a change per snap
  /// point, and unordered writes let a stale value win.
  Future<void> _fontScaleWrites = Future<void>.value();

  /// Update font scale setting
  Future<void> updateFontScale(double value) async {
    final snapped = nearestSailFontScale(value);
    if (fontScale == snapped) {
      return;
    }

    final previous = fontScale;
    fontScale = snapped;
    notifyListeners();

    final write = _fontScaleWrites.then((_) async {
      if (fontScale != snapped) {
        return; // superseded mid-drag
      }
      try {
        await clientSettings.setValue(FontScaleSetting(newValue: snapped));
      } catch (e) {
        if (fontScale == snapped) {
          fontScale = previous;
          notifyListeners();
        }
        log.e('Failed to update font scale', error: e);
        rethrow;
      }
    });

    // Keep the chain usable after a failed write, but still surface it here.
    _fontScaleWrites = write.catchError((_) {});
    return write;
  }

  /// Load bitcoin unit setting
  Future<void> _loadBitcoinUnit() async {
    final setting = BitcoinUnitSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    bitcoinUnit = loadedSetting.value;
    notifyListeners();
  }

  /// Update bitcoin unit setting
  Future<void> updateBitcoinUnit(BitcoinUnit value) async {
    if (bitcoinUnit == value) {
      return;
    }

    try {
      bitcoinUnit = value;
      notifyListeners();
      final setting = BitcoinUnitSetting(newValue: value);
      await clientSettings.setValue(setting);
    } catch (e) {
      // Revert on error
      bitcoinUnit = bitcoinUnit == BitcoinUnit.btc ? BitcoinUnit.sats : BitcoinUnit.btc;
      notifyListeners();
      log.e('Failed to update bitcoin unit', error: e);
      rethrow;
    }
  }

  /// Update paranoid mode setting (locks chains_config.json from auto-updates)
  Future<void> updateParanoidMode(bool value) async {
    if (bitwindowSettings.paranoidMode == value) {
      return;
    }

    final old = bitwindowSettings;
    try {
      bitwindowSettings = bitwindowSettings.copyWith(paranoidMode: value);
      notifyListeners();
      final setting = BitwindowSettingValue(newValue: bitwindowSettings);
      await bitwindowClientSettings.setValue(setting);
    } catch (e) {
      bitwindowSettings = old;
      notifyListeners();
      log.e('Failed to update paranoid mode', error: e);
      rethrow;
    }
  }

  /// Update the global theme style. Written to BitwindowSettings so every
  /// client (bitwindow + all sidechains) follows it; applied live here.
  Future<void> updateThemeStyle(SailThemeStyle style) async {
    if (bitwindowSettings.themeStyle == style.id) {
      return;
    }

    final old = bitwindowSettings;
    try {
      bitwindowSettings = bitwindowSettings.copyWith(themeStyle: style.id);
      notifyListeners();
      final setting = BitwindowSettingValue(newValue: bitwindowSettings);
      await bitwindowClientSettings.setValue(setting);
    } catch (e) {
      bitwindowSettings = old;
      notifyListeners();
      log.e('Failed to update theme style', error: e);
      rethrow;
    }
  }
}
