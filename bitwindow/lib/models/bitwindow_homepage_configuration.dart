import 'package:sail_ui/sail_ui.dart';

class BitwindowHomepageConfiguration {
  static HomepageConfiguration get defaultConfiguration {
    return HomepageConfiguration(
      widgets: [
        HomepageWidgetConfig(widgetId: 'fireplace_stats'),
        HomepageWidgetConfig(widgetId: 'coin_news_large'),
        HomepageWidgetConfig(widgetId: 'latest_transactions'),
        HomepageWidgetConfig(widgetId: 'latest_blocks'),
      ],
    );
  }
}
