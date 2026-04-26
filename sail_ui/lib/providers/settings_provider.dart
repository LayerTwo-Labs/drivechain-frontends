import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Settings provider that manages individual setting variables
/// with automatic persistence and change notification.
class SettingsProvider extends ChangeNotifier {
  ClientSettings get clientSettings => GetIt.I.get<ClientSettings>();
  BitwindowClientSettings get bitwindowClientSettings => GetIt.I.get<BitwindowClientSettings>();
  Logger get log => GetIt.I.get<Logger>();

  // Individual setting variables
  bool debugMode = false;
  bool useTestSidechains = false;
  BitwindowSettings bitwindowSettings = BitwindowSettings();
  SailFontValues font = SailFontValues.inter;
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
    await _loadUseTestSidechains();
    await _loadBitwindowSettings();
    await _loadFont();
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

  /// Load use test sidechains setting. The orchestrator owns the source of
  /// truth (it has to so that orchestratord launches the right binary even
  /// without a Flutter UI running) — ClientSettings is just a UI-side cache
  /// so first paint doesn't have to await an RPC.
  Future<void> _loadUseTestSidechains() async {
    // Cache first so the toggle doesn't flicker on first paint.
    final setting = UseTestSidechainsSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    useTestSidechains = loadedSetting.value;
    notifyListeners();

    // Reconcile against the orchestrator. If GetIt isn't ready (early bootstrap
    // path on tests / fresh installs) we keep the cached value.
    if (!GetIt.I.isRegistered<OrchestratorRPC>()) {
      return;
    }
    try {
      final resp = await GetIt.I.get<OrchestratorRPC>().wallet.getTestSidechains();
      if (useTestSidechains != resp.enabled) {
        useTestSidechains = resp.enabled;
        notifyListeners();
        // Push back to the cache so a future startup with no orchestrator
        // (e.g. headless tooling) sees the right initial value.
        await clientSettings.setValue(UseTestSidechainsSetting(newValue: resp.enabled));
      }
    } catch (e) {
      log.d('Could not reconcile test-sidechains with orchestrator: $e');
    }
  }

  /// Update use test sidechains setting. The orchestrator handles stop +
  /// wipe + persistence; we just mirror the result into the local cache.
  Future<void> updateUseTestSidechains(bool value) async {
    if (useTestSidechains == value) {
      return;
    }

    final previous = useTestSidechains;
    try {
      useTestSidechains = value;
      notifyListeners();

      await GetIt.I.get<OrchestratorRPC>().wallet.setTestSidechains(value);

      // Cache the new value so headless boots get it for free.
      await clientSettings.setValue(UseTestSidechainsSetting(newValue: value));
    } catch (e) {
      // Revert on error
      useTestSidechains = previous;
      notifyListeners();
      log.e('Failed to update use test sidechains', error: e);
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
}
