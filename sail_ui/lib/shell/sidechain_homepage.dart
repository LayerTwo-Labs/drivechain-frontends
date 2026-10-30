import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainHomepagePage extends StatelessWidget {
  const SidechainHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => SidechainHomepageViewModel(),
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

class SidechainHomepageViewModel extends BaseViewModel {
  HomepageProvider get _homepageProvider => GetIt.I.get<HomepageProvider>();

  HomepageConfiguration get homepageConfiguration => _homepageProvider.configuration;

  Map<String, HomepageWidgetInfo> getWidgetCatalog() {
    return _homepageProvider.getWidgetCatalog();
  }

  SidechainHomepageViewModel() {
    _homepageProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _homepageProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
