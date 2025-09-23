import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thunder/providers/thunder_homepage_provider.dart';
import 'package:thunder/widgets/thunder_widget_catalog.dart';

@RoutePage()
class ThunderConfigureHomepagePage extends StatefulWidget {
  const ThunderConfigureHomepagePage({super.key});

  @override
  State<ThunderConfigureHomepagePage> createState() => _ThunderConfigureHomepagePageState();
}

class _ThunderConfigureHomepagePageState extends State<ThunderConfigureHomepagePage> {
  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I.get<ThunderHomepageProvider>();

    return SailConfigureHomePage(
      widgetCatalog: ThunderWidgetCatalog.getCatalogMap(),
      provider: provider,
      backButtonLabel: 'Back to Thunder homepage',
      onHomepageConfigured: () {
        // Optionally navigate back or show additional feedback
      },
    );
  }
}
