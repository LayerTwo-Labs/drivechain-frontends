import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:photon/widgets/homepage_widget_catalog.dart';

class PhotonHomepageConfigurationSetting extends SettingValue<HomepageConfiguration> {
  @override
  String get key => 'photon_homepage_configuration';

  PhotonHomepageConfigurationSetting({super.newValue});

  @override
  HomepageConfiguration defaultValue() => PhotonHomepageConfiguration.defaultConfiguration;

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
    return PhotonHomepageConfigurationSetting(newValue: value);
  }
}

class PhotonHomepageConfiguration {
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

class PhotonHomepageProvider extends HomepageProvider {
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();

  @override
  HomepageConfiguration configuration = PhotonHomepageConfiguration.defaultConfiguration;
  @override
  HomepageConfiguration tempConfiguration = PhotonHomepageConfiguration.defaultConfiguration;
  @override
  bool isLoading = false;
  @override
  bool hasUnsavedChanges = false;

  PhotonHomepageProvider() {
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    isLoading = true;
    notifyListeners();

    try {
      final setting = PhotonHomepageConfigurationSetting();
      final loadedSetting = await _settings.getValue(setting);
      configuration = loadedSetting.value;
      tempConfiguration = configuration;
    } catch (e) {
      configuration = PhotonHomepageConfiguration.defaultConfiguration;
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
      final setting = PhotonHomepageConfigurationSetting(newValue: tempConfiguration);
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
    return PhotonWidgetCatalog.getCatalogMap();
  }
}
