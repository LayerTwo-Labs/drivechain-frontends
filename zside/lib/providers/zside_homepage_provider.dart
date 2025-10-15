import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/widgets/homepage_widget_catalog.dart';

class ZSideHomepageConfigurationSetting extends SettingValue<HomepageConfiguration> {
  @override
  String get key => 'zside_homepage_configuration';

  ZSideHomepageConfigurationSetting({super.newValue});

  @override
  HomepageConfiguration defaultValue() => ZSideHomepageConfiguration.defaultConfiguration;

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
    return ZSideHomepageConfigurationSetting(newValue: value);
  }
}

class ZSideHomepageConfiguration {
  static HomepageConfiguration get defaultConfiguration {
    return HomepageConfiguration(
      widgets: [
        HomepageWidgetConfig(widgetId: 'balance_card'),
        HomepageWidgetConfig(widgetId: 'transparent_receive_card'),
        HomepageWidgetConfig(widgetId: 'shielded_receive_card'),
        HomepageWidgetConfig(widgetId: 'send_card'),
        HomepageWidgetConfig(widgetId: 'transactions_table'),
      ],
    );
  }
}

class ZSideHomepageProvider extends HomepageProvider {
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();

  HomepageConfiguration _configuration = ZSideHomepageConfiguration.defaultConfiguration;
  HomepageConfiguration _tempConfiguration = ZSideHomepageConfiguration.defaultConfiguration;
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

  ZSideHomepageProvider() {
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    _isLoading = true;
    notifyListeners();

    try {
      final setting = ZSideHomepageConfigurationSetting();
      final loadedSetting = await _settings.getValue(setting);
      _configuration = loadedSetting.value;
      _tempConfiguration = _configuration;
    } catch (e) {
      _configuration = ZSideHomepageConfiguration.defaultConfiguration;
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
      final setting = ZSideHomepageConfigurationSetting(newValue: _tempConfiguration);
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
    return ZSideWidgetCatalog.getCatalogMap();
  }
}
