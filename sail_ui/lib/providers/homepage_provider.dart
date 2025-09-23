import 'package:flutter/foundation.dart';
import 'package:sail_ui/models/homepage_configuration.dart';
import 'package:sail_ui/widgets/homepage/homepage_widget_info.dart';

abstract class HomepageProvider extends ChangeNotifier {
  HomepageConfiguration get configuration;
  HomepageConfiguration get tempConfiguration;
  bool get isLoading;
  bool get hasUnsavedChanges;

  Future<void> saveConfiguration();
  void addWidget(String widgetId);
  void removeWidget(int index);
  void reorderWidgets(int oldIndex, int newIndex);
  void undoChanges();
  Map<String, HomepageWidgetInfo> getWidgetCatalog();
}
