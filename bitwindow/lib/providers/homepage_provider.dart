import 'package:bitwindow/models/bitwindow_homepage_configuration.dart';
import 'package:bitwindow/widgets/homepage_widget_catalog.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class HomepageConfigurationSetting extends SettingValue<HomepageConfiguration> {
  @override
  String get key => 'homepage_configuration';

  HomepageConfigurationSetting({super.newValue});

  @override
  HomepageConfiguration defaultValue() => BitwindowHomepageConfiguration.defaultConfiguration;

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

const _largeWidgetIds = {
  'coin_news_large': 'coin_news',
  'hacker_coin_news_large': 'hacker_coin_news',
};

/// Turns each saved large news widget into its widget at full width. Null when nothing changes.
HomepageConfiguration? migrateLargeNewsWidgets(HomepageConfiguration configuration) {
  if (!configuration.widgets.any((w) => _largeWidgetIds.containsKey(w.widgetId))) {
    return null;
  }
  final widgets = <HomepageWidgetConfig>[];
  for (final widget in configuration.widgets) {
    final id = _largeWidgetIds[widget.widgetId];
    final next = id == null ? widget : HomepageWidgetConfig(widgetId: id, size: WidgetSize.full);
    if (widgets.any((w) => w.widgetId == next.widgetId)) {
      continue;
    }
    widgets.add(next);
  }
  return HomepageConfiguration(widgets: widgets);
}

class BitwindowHomepageProvider extends HomepageProvider {
  BitwindowHomepageProvider() : super(BitwindowHomepageConfiguration.defaultConfiguration);

  ClientSettings get _settings => GetIt.I.get<ClientSettings>();

  @override
  Map<String, HomepageWidgetInfo> get catalog => HomepageWidgetCatalog.getCatalogMap();

  @override
  Future<HomepageConfiguration> read() async {
    final saved = (await _settings.getValue(HomepageConfigurationSetting())).value;
    final migrated = migrateLargeNewsWidgets(saved);
    if (migrated == null) {
      return saved;
    }
    await write(migrated);
    return migrated;
  }

  @override
  Future<void> write(HomepageConfiguration configuration) async {
    await _settings.setValue(HomepageConfigurationSetting(newValue: configuration));
  }
}
