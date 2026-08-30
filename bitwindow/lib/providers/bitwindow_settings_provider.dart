import 'dart:convert';

import 'package:bitwindow/models/settings.dart';
import 'package:bitwindow/settings/bitwindow_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class BitwindowSettingsProvider extends ChangeNotifier {
  /// Homepage state used to live under the key sidechain_core's global
  /// BitwindowSettings owns, and each write clobbered the other.
  static const _legacyKey = 'bitwindow_settings';

  final ClientSettings _clientSettings = GetIt.I.get<ClientSettings>();

  Settings _settings = Settings();
  bool _isLoading = false;

  Settings get settings => _settings;
  bool get isLoading => _isLoading;

  BitwindowSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _migrateLegacySettings();
      final settingValue = BitwindowSettingsValue();
      final loaded = await _clientSettings.getValue(settingValue);
      _settings = loaded.value;
    } catch (e) {
      _settings = Settings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salvage homepage state written under [_legacyKey] before it got its own
  /// key. The old blob is left alone: it may be the global BitwindowSettings.
  Future<void> _migrateLegacySettings() async {
    final settingValue = BitwindowSettingsValue();
    try {
      if (await _clientSettings.store.getString(settingValue.key) != null) {
        return;
      }

      final legacy = await _clientSettings.store.getString(_legacyKey);
      if (legacy == null) {
        return;
      }

      final decoded = json.decode(legacy);
      if (decoded is! Map<String, dynamic> ||
          (!decoded.containsKey('hasConfiguredHomepage') && !decoded.containsKey('configureHomeButtonPressCount'))) {
        return;
      }

      await _clientSettings.setValue(BitwindowSettingsValue(newValue: Settings.fromMap(decoded)));
    } catch (e) {
      // A missing key throws on some platforms, and a corrupt blob is not worth salvaging.
    }
  }

  Future<void> incrementConfigureButtonPressCount() async {
    _settings = _settings.copyWith(
      configureHomeButtonPressCount: _settings.configureHomeButtonPressCount + 1,
    );
    await _saveSettings();
  }

  Future<void> markHomepageAsConfigured() async {
    if (!_settings.hasConfiguredHomepage) {
      _settings = _settings.copyWith(hasConfiguredHomepage: true);
      await _saveSettings();
    }
  }

  Future<void> _saveSettings() async {
    final settingValue = BitwindowSettingsValue(newValue: _settings);
    await _clientSettings.setValue(settingValue);
    notifyListeners();
  }
}
