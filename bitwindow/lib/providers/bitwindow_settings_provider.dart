import 'package:bitwindow/models/settings.dart';
import 'package:bitwindow/settings/bitwindow_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class BitwindowSettingsProvider extends ChangeNotifier {
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
