import 'package:bitwindow/models/homepage_configuration.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class HomepageConfigurationSetting extends SettingValue<HomepageConfiguration> {
  @override
  String get key => 'homepage_configuration';

  HomepageConfigurationSetting({super.newValue});

  @override
  HomepageConfiguration defaultValue() => HomepageConfiguration.defaultConfiguration;

  @override
  HomepageConfiguration? fromJson(String jsonString) {
    try {
      return HomepageConfiguration.fromJson(jsonString);
    } catch (e) {
      return null;
    }
  }

  @override
  String toJson() {
    return value.toJson();
  }

  @override
  SettingValue<HomepageConfiguration> withValue([HomepageConfiguration? value]) {
    return HomepageConfigurationSetting(newValue: value);
  }
}

class HomepageProvider extends ChangeNotifier {
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();
  
  HomepageConfiguration _configuration = HomepageConfiguration.defaultConfiguration;
  HomepageConfiguration _tempConfiguration = HomepageConfiguration.defaultConfiguration;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  HomepageConfiguration get configuration => _configuration;
  HomepageConfiguration get tempConfiguration => _tempConfiguration;
  bool get isLoading => _isLoading;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  HomepageProvider() {
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    _isLoading = true;
    notifyListeners();

    try {
      final setting = HomepageConfigurationSetting();
      final loadedSetting = await _settings.getValue(setting);
      _configuration = loadedSetting.value;
      _tempConfiguration = _configuration;
    } catch (e) {
      _configuration = HomepageConfiguration.defaultConfiguration;
      _tempConfiguration = _configuration;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveConfiguration() async {
    _isLoading = true;
    notifyListeners();

    try {
      final setting = HomepageConfigurationSetting(newValue: _tempConfiguration);
      await _settings.setValue(setting);
      _configuration = _tempConfiguration;
      _hasUnsavedChanges = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void cancelChanges() {
    _tempConfiguration = _configuration;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  void addWidget(String widgetId) {
    _tempConfiguration = _tempConfiguration.addWidget(widgetId);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void removeWidget(int index) {
    _tempConfiguration = _tempConfiguration.removeWidget(index);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void reorderWidgets(int oldIndex, int newIndex) {
    _tempConfiguration = _tempConfiguration.reorderWidgets(oldIndex, newIndex);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateWidgetSettings(int index, Map<String, dynamic> settings) {
    _tempConfiguration = _tempConfiguration.updateWidgetSettings(index, settings);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void undoChanges() {
    _tempConfiguration = _configuration;
    _hasUnsavedChanges = false;
    notifyListeners();
  }
}