import 'package:auto_route/auto_route.dart';
import 'package:bitnames/providers/bitnames_homepage_provider.dart';
import 'package:bitnames/widgets/homepage_widget_catalog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class BitnamesConfigureHomepagePage extends StatelessWidget {
  const BitnamesConfigureHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailConfigureHomePage(
      widgetCatalog: BitnamesWidgetCatalog.getCatalogMap(),
      provider: GetIt.I.get<BitnamesHomepageProvider>(),
      backButtonLabel: 'Back to homepage',
    );
  }
}
