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

  @override
  HomepageConfiguration configuration = BitAssetsHomepageConfiguration.defaultConfiguration;
  @override
  HomepageConfiguration tempConfiguration = BitAssetsHomepageConfiguration.defaultConfiguration;
  @override
  bool isLoading = false;
  @override
  bool hasUnsavedChanges = false;

  BitAssetsHomepageProvider() {
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    isLoading = true;
    notifyListeners();

    try {
      final setting = BitAssetsHomepageConfigurationSetting();
      final loadedSetting = await _settings.getValue(setting);
      configuration = loadedSetting.value;
      tempConfiguration = configuration;
    } catch (e) {
      configuration = BitAssetsHomepageConfiguration.defaultConfiguration;
      tempConfiguration = configuration;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> saveConfiguration() async {
    isLoading = true;
    notifyListeners();

    try {
      final setting = BitAssetsHomepageConfigurationSetting(newValue: tempConfiguration);
      await _settings.setValue(setting);
      configuration = tempConfiguration;
      hasUnsavedChanges = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void addWidget(String widgetId) {
    tempConfiguration = tempConfiguration.addWidget(widgetId);
    hasUnsavedChanges = true;
    notifyListeners();
  }

  @override
  void removeWidget(int index) {
    tempConfiguration = tempConfiguration.removeWidget(index);
    hasUnsavedChanges = true;
    notifyListeners();
  }

  @override
  void reorderWidgets(int oldIndex, int newIndex) {
    tempConfiguration = tempConfiguration.reorderWidgets(oldIndex, newIndex);
    hasUnsavedChanges = true;
    notifyListeners();
  }

  @override
  void undoChanges() {
    tempConfiguration = configuration;
    hasUnsavedChanges = false;
    notifyListeners();
  }

  @override
  Map<String, HomepageWidgetInfo> getWidgetCatalog() {
    return BitAssetsWidgetCatalog.getCatalogMap();
  }
}
