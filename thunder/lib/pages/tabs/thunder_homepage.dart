import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:thunder/providers/thunder_homepage_provider.dart';
import 'package:thunder/widgets/thunder_widget_catalog.dart';

@RoutePage()
class ThunderHomepagePage extends StatelessWidget {
  const ThunderHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ThunderHomepageViewModel(),
      builder: (context, model, child) {
        final config = model.homepageConfiguration;
        final catalog = model.getWidgetCatalog();

        try {
          return QtPage(
            child: HomepageBuilder(
              configuration: config,
              widgetCatalog: catalog,
              isPreview: false,
            ),
          );
        } catch (e) {
          return QtPage(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SailText.primary20('Error in HomepageBuilder'),
                  SailText.secondary15('Error: $e'),
                  SailText.secondary15('Config widgets: ${config.widgets.length}'),
                  SailText.secondary15('Catalog widgets: ${catalog.length}'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class ThunderHomepageViewModel extends BaseViewModel {
  ThunderHomepageProvider get _homepageProvider => GetIt.I.get<ThunderHomepageProvider>();

  HomepageConfiguration get homepageConfiguration => _homepageProvider.configuration;

  Map<String, HomepageWidgetInfo> getWidgetCatalog() {
    return ThunderWidgetCatalog.getCatalogMap();
  }

  ThunderHomepageViewModel() {
    _homepageProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _homepageProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
