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

  @override
  HomepageConfiguration configuration = ThunderHomepageConfiguration.defaultConfiguration;
  @override
  HomepageConfiguration tempConfiguration = ThunderHomepageConfiguration.defaultConfiguration;
  @override
  bool isLoading = false;
  @override
  bool hasUnsavedChanges = false;

  ThunderHomepageProvider() {
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    isLoading = true;
    notifyListeners();

    try {
      final setting = ThunderHomepageConfigurationSetting();
      final loadedSetting = await _settings.getValue(setting);
      configuration = loadedSetting.value;
      tempConfiguration = configuration;
    } catch (e) {
      configuration = ThunderHomepageConfiguration.defaultConfiguration;
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
      final setting = ThunderHomepageConfigurationSetting(newValue: tempConfiguration);
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
    return ThunderWidgetCatalog.getCatalogMap();
  }
}
