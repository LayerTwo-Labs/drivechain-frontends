import 'package:bitassets/widgets/homepage_widget_catalog.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class BitAssetsHomepageConfigurationSetting extends SettingValue<HomepageConfiguration> {
  @override
  String get key => 'bitassets_homepage_configuration';

  BitAssetsHomepageConfigurationSetting({super.newValue});

  @override
  HomepageConfiguration defaultValue() => BitAssetsHomepageConfiguration.defaultConfiguration;

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
    return BitAssetsHomepageConfigurationSetting(newValue: value);
  }
}

class BitAssetsHomepageConfiguration {
  static HomepageConfiguration get defaultConfiguration {
    return HomepageConfiguration(
      widgets: [
        HomepageWidgetConfig(widgetId: 'balance_card'),
        HomepageWidgetConfig(widgetId: 'receive_card'),
        HomepageWidgetConfig(widgetId: 'send_card'),
        HomepageWidgetConfig(widgetId: 'bitassets_table'),
      ],
    );
  }
}

class BitAssetsHomepageProvider extends HomepageProvider {
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();

  HomepageConfiguration _configuration = BitAssetsHomepageConfiguration.defaultConfiguration;
  HomepageConfiguration _tempConfiguration = BitAssetsHomepageConfiguration.defaultConfiguration;
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

  BitAssetsHomepageProvider() {
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    _isLoading = true;
    notifyListeners();

    try {
      final setting = BitAssetsHomepageConfigurationSetting();
      final loadedSetting = await _settings.getValue(setting);
      _configuration = loadedSetting.value;
      _tempConfiguration = _configuration;
    } catch (e) {
      _configuration = BitAssetsHomepageConfiguration.defaultConfiguration;
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
      final setting = BitAssetsHomepageConfigurationSetting(newValue: _tempConfiguration);
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
    return BitAssetsWidgetCatalog.getCatalogMap();
  }
}
