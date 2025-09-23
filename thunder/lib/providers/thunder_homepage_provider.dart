import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thunder/widgets/thunder_widget_catalog.dart';

class ThunderHomepageConfigurationSetting extends SettingValue<HomepageConfiguration> {
  @override
  String get key => 'thunder_homepage_configuration';

  ThunderHomepageConfigurationSetting({super.newValue});

  @override
  HomepageConfiguration defaultValue() => ThunderHomepageConfiguration.defaultConfiguration;

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
    return ThunderHomepageConfigurationSetting(newValue: value);
  }
}

class ThunderHomepageConfiguration {
  static HomepageConfiguration get defaultConfiguration {
    return HomepageConfiguration(
      widgets: [
        HomepageWidgetConfig(widgetId: 'balance_card'),
        HomepageWidgetConfig(widgetId: 'receive_card'),
        HomepageWidgetConfig(widgetId: 'send_card'),
        HomepageWidgetConfig(widgetId: 'utxo_table'),
      ],
    );
  }
}

class ThunderHomepageProvider extends HomepageProvider {
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();

  HomepageConfiguration _configuration = ThunderHomepageConfiguration.defaultConfiguration;
  HomepageConfiguration _tempConfiguration = ThunderHomepageConfiguration.defaultConfiguration;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  HomepageConfiguration get configuration => _configuration;
  @override
  HomepageConfiguration get tempConfiguration => _tempConfiguration;
  @override
  bool get isLoading => _isLoading;
  @override
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  ThunderHomepageProvider() {
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    _isLoading = true;
    notifyListeners();

    try {
      final setting = ThunderHomepageConfigurationSetting();
      final loadedSetting = await _settings.getValue(setting);
      _configuration = loadedSetting.value;
      _tempConfiguration = _configuration;
    } catch (e) {
      _configuration = ThunderHomepageConfiguration.defaultConfiguration;
      _tempConfiguration = _configuration;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> saveConfiguration() async {
    _isLoading = true;
    notifyListeners();

    try {
      final setting = ThunderHomepageConfigurationSetting(newValue: _tempConfiguration);
      await _settings.setValue(setting);
      _configuration = _tempConfiguration;
      _hasUnsavedChanges = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void addWidget(String widgetId) {
    _tempConfiguration = _tempConfiguration.addWidget(widgetId);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  @override
  void removeWidget(int index) {
    _tempConfiguration = _tempConfiguration.removeWidget(index);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  @override
  void reorderWidgets(int oldIndex, int newIndex) {
    _tempConfiguration = _tempConfiguration.reorderWidgets(oldIndex, newIndex);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  @override
  void undoChanges() {
    _tempConfiguration = _configuration;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  @override
  Map<String, HomepageWidgetInfo> getWidgetCatalog() {
    return ThunderWidgetCatalog.getCatalogMap();
  }
}
