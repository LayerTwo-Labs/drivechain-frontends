import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/providers/truthcoin_homepage_provider.dart';
import 'package:truthcoin/widgets/homepage_widget_catalog.dart';

@RoutePage()
class TruthcoinConfigureHomepagePage extends StatefulWidget {
  const TruthcoinConfigureHomepagePage({super.key});

  @override
  State<TruthcoinConfigureHomepagePage> createState() => _TruthcoinConfigureHomepagePageState();
}

class _TruthcoinConfigureHomepagePageState extends State<TruthcoinConfigureHomepagePage> {
  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I.get<TruthcoinHomepageProvider>();

    return SailConfigureHomePage(
      widgetCatalog: TruthcoinWidgetCatalog.getCatalogMap(),
      provider: provider,
      backButtonLabel: 'Back to Truthcoin homepage',
      onHomepageConfigured: () {
        // Optionally navigate back or show additional feedback
      },
    );
  }
}
