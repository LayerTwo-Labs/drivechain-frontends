import 'dart:convert';

enum WidgetSize { bar, half, full }

class HomepageWidgetConfig {
  final String widgetId;

  /// Null means the smallest size the widget has.
  final WidgetSize? size;

  const HomepageWidgetConfig({required this.widgetId, this.size});

  Map<String, dynamic> toMap() {
    return {'widgetId': widgetId, if (size != null) 'size': size!.name};
  }

  factory HomepageWidgetConfig.fromMap(Map<String, dynamic> map) {
    return HomepageWidgetConfig(
      widgetId: map['widgetId'] as String,
      size: WidgetSize.values.asNameMap()[map['size']],
    );
  }
}

class HomepageConfiguration {
  final List<HomepageWidgetConfig> widgets;
  final DateTime lastModified;

  HomepageConfiguration({required this.widgets, DateTime? lastModified})
    : lastModified = lastModified ?? DateTime.now();

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
}
