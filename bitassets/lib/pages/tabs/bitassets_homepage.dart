import 'package:auto_route/auto_route.dart';
import 'package:bitassets/providers/bitassets_homepage_provider.dart';
import 'package:bitassets/widgets/homepage_widget_catalog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class BitAssetsHomepagePage extends StatelessWidget {
  const BitAssetsHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BitAssetsHomepageViewModel>.reactive(
      viewModelBuilder: () => BitAssetsHomepageViewModel(),
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

class BitAssetsHomepageViewModel extends BaseViewModel {
  BitAssetsHomepageProvider get _homepageProvider => GetIt.I.get<BitAssetsHomepageProvider>();

  HomepageConfiguration get homepageConfiguration => _homepageProvider.configuration;
  Map<String, HomepageWidgetInfo> get widgetCatalog => BitAssetsWidgetCatalog.getCatalogMap();

  BitAssetsHomepageViewModel() {
    _homepageProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _homepageProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
