import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:inquisition/providers/inquisition_homepage_provider.dart';
import 'package:inquisition/widgets/homepage_widget_catalog.dart';

@RoutePage()
class InquisitionHomepagePage extends StatelessWidget {
  const InquisitionHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => InquisitionHomepageViewModel(),
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

class InquisitionHomepageViewModel extends BaseViewModel {
  InquisitionHomepageProvider get _homepageProvider => GetIt.I.get<InquisitionHomepageProvider>();

  HomepageConfiguration get homepageConfiguration => _homepageProvider.configuration;

  Map<String, HomepageWidgetInfo> getWidgetCatalog() {
    return InquisitionWidgetCatalog.getCatalogMap();
  }

  InquisitionHomepageViewModel() {
    _homepageProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _homepageProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
