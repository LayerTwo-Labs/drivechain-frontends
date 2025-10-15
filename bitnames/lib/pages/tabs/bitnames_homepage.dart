import 'package:auto_route/auto_route.dart';
import 'package:bitnames/providers/bitnames_homepage_provider.dart';
import 'package:bitnames/widgets/homepage_widget_catalog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class BitnamesHomepagePage extends StatelessWidget {
  const BitnamesHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BitnamesHomepageViewModel>.reactive(
      viewModelBuilder: () => BitnamesHomepageViewModel(),
      builder: (context, model, child) {
        return QtPage(
          child: HomepageBuilder(
            configuration: model.homepageConfiguration,
            widgetCatalog: model.widgetCatalog,
            isPreview: false,
          ),
        );
      },
    );
  }
}

class BitnamesHomepageViewModel extends BaseViewModel {
  BitnamesHomepageProvider get _homepageProvider => GetIt.I.get<BitnamesHomepageProvider>();

  HomepageConfiguration get homepageConfiguration => _homepageProvider.configuration;
  Map<String, HomepageWidgetInfo> get widgetCatalog => BitnamesWidgetCatalog.getCatalogMap();

  BitnamesHomepageViewModel() {
    _homepageProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _homepageProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
