import 'package:auto_route/auto_route.dart';
import 'package:bitassets/providers/bitassets_homepage_provider.dart';
import 'package:bitassets/widgets/homepage_widget_catalog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class BitAssetsConfigureHomepagePage extends StatelessWidget {
  const BitAssetsConfigureHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailConfigureHomePage(
      widgetCatalog: BitAssetsWidgetCatalog.getCatalogMap(),
      provider: GetIt.I.get<BitAssetsHomepageProvider>(),
      backButtonLabel: 'Back to homepage',
    );
  }
}
