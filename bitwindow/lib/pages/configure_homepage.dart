import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/homepage_provider.dart' as bitwindow;
import 'package:bitwindow/widgets/homepage_widget_catalog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class ConfigureHomePage extends StatelessWidget {
  const ConfigureHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SailConfigureHomePage(
      widgetCatalog: HomepageWidgetCatalog.getCatalogMap(),
      provider: GetIt.I.get<bitwindow.BitwindowHomepageProvider>(),
      backButtonLabel: 'Back to homepage',
    );
  }
}
