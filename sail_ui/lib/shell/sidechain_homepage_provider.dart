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

  SidechainHomepageProvider(this.module) : super(defaultHomepage(module));

  ClientSettings get _settings => GetIt.I.get<ClientSettings>();

  @override
  Map<String, HomepageWidgetInfo> get catalog => module.widgetCatalog;

  @override
  Future<HomepageConfiguration> read() async {
    final loaded = await _settings.getValue(SidechainHomepageSetting(module));
    return loaded.value;
  }

  @override
  Future<void> write(HomepageConfiguration configuration) async {
    await _settings.setValue(SidechainHomepageSetting(module, newValue: configuration));
  }
}
