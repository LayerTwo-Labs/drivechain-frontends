import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/sidechain_module.dart';

/// The saved homepage layout of one chain, under `<registryKey>_homepage_configuration`.
class SidechainHomepageSetting extends SettingValue<HomepageConfiguration> {
  final SidechainModule module;

  SidechainHomepageSetting(this.module, {super.newValue});

  @override
  String get key => '${module.chain.registryKey}_homepage_configuration';

  @override
  HomepageConfiguration defaultValue() => defaultHomepage(module);

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
    return SidechainHomepageSetting(module, newValue: value);
  }
}

HomepageConfiguration defaultHomepage(SidechainModule module) {
  return HomepageConfiguration(
    widgets: [for (final id in module.defaultHomepageWidgets) HomepageWidgetConfig(widgetId: id)],
  );
}

class SidechainHomepageProvider extends HomepageProvider {
  final SidechainModule module;
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();

  @override
  HomepageConfiguration configuration;
  @override
  HomepageConfiguration tempConfiguration;
  @override
  bool isLoading = false;
  @override
  bool hasUnsavedChanges = false;

  late final Future<void> loaded;

  SidechainHomepageProvider(this.module)
    : configuration = defaultHomepage(module),
      tempConfiguration = defaultHomepage(module) {
    loaded = _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    isLoading = true;
    notifyListeners();

    try {
      final loadedSetting = await _settings.getValue(SidechainHomepageSetting(module));
      configuration = loadedSetting.value;
      tempConfiguration = configuration;
    } catch (e) {
      configuration = defaultHomepage(module);
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
      await _settings.setValue(SidechainHomepageSetting(module, newValue: tempConfiguration));
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
    return module.widgetCatalog;
  }
}
