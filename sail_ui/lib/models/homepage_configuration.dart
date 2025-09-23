import 'dart:convert';

enum WidgetSize { full, half }

class HomepageWidgetConfig {
  final String widgetId;
  final Map<String, dynamic> settings;

  HomepageWidgetConfig({
    required this.widgetId,
    this.settings = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'widgetId': widgetId,
      'settings': settings,
    };
  }

  factory HomepageWidgetConfig.fromMap(Map<String, dynamic> map) {
    return HomepageWidgetConfig(
      widgetId: map['widgetId'] as String,
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  HomepageWidgetConfig copyWith({
    String? widgetId,
    Map<String, dynamic>? settings,
  }) {
    return HomepageWidgetConfig(
      widgetId: widgetId ?? this.widgetId,
      settings: settings ?? this.settings,
    );
  }
}

class HomepageConfiguration {
  final List<HomepageWidgetConfig> widgets;
  final DateTime lastModified;

  HomepageConfiguration({
    required this.widgets,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'widgets': widgets.map((w) => w.toMap()).toList(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory HomepageConfiguration.fromMap(Map<String, dynamic> map) {
    return HomepageConfiguration(
      widgets: (map['widgets'] as List<dynamic>)
          .map((item) => HomepageWidgetConfig.fromMap(item as Map<String, dynamic>))
          .toList(),
      lastModified: DateTime.parse(map['lastModified'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory HomepageConfiguration.fromJson(String source) {
    return HomepageConfiguration.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  HomepageConfiguration copyWith({
    List<HomepageWidgetConfig>? widgets,
    DateTime? lastModified,
  }) {
    return HomepageConfiguration(
      widgets: widgets ?? this.widgets,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  HomepageConfiguration addWidget(String widgetId) {
    return copyWith(
      widgets: [
        ...widgets,
        HomepageWidgetConfig(widgetId: widgetId),
      ],
      lastModified: DateTime.now(),
    );
  }

  HomepageConfiguration removeWidget(int index) {
    final newWidgets = List<HomepageWidgetConfig>.from(widgets);
    newWidgets.removeAt(index);
    return copyWith(
      widgets: newWidgets,
      lastModified: DateTime.now(),
    );
  }

  HomepageConfiguration reorderWidgets(int oldIndex, int newIndex) {
    final newWidgets = List<HomepageWidgetConfig>.from(widgets);
    final widget = newWidgets.removeAt(oldIndex);
    newWidgets.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, widget);
    return copyWith(
      widgets: newWidgets,
      lastModified: DateTime.now(),
    );
  }

  HomepageConfiguration updateWidgetSettings(int index, Map<String, dynamic> settings) {
    final newWidgets = List<HomepageWidgetConfig>.from(widgets);
    newWidgets[index] = newWidgets[index].copyWith(settings: settings);
    return copyWith(
      widgets: newWidgets,
      lastModified: DateTime.now(),
    );
  }
}
