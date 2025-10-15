import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/providers/zside_homepage_provider.dart';
import 'package:zside/widgets/homepage_widget_catalog.dart';

@RoutePage()
class ZSideConfigureHomepagePage extends StatelessWidget {
  const ZSideConfigureHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailConfigureHomePage(
      widgetCatalog: ZSideWidgetCatalog.getCatalogMap(),
      provider: GetIt.I.get<ZSideHomepageProvider>(),
      backButtonLabel: 'Back to homepage',
    );
  }
}
