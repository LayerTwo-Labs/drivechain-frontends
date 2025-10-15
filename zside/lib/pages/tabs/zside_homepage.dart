import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/providers/zside_homepage_provider.dart';
import 'package:zside/widgets/homepage_widget_catalog.dart';

@RoutePage()
class ZSideHomepagePage extends StatelessWidget {
  const ZSideHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ZSideHomepageViewModel>.reactive(
      viewModelBuilder: () => ZSideHomepageViewModel(),
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

class ZSideHomepageViewModel extends BaseViewModel {
  ZSideHomepageProvider get _homepageProvider => GetIt.I.get<ZSideHomepageProvider>();

  HomepageConfiguration get homepageConfiguration => _homepageProvider.configuration;
  Map<String, HomepageWidgetInfo> get widgetCatalog => ZSideWidgetCatalog.getCatalogMap();

  ZSideHomepageViewModel() {
    _homepageProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _homepageProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
