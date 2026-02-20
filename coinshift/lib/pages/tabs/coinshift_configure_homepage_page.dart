import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:coinshift/providers/coinshift_homepage_provider.dart';
import 'package:coinshift/widgets/homepage_widget_catalog.dart';

@RoutePage()
class CoinShiftConfigureHomepagePage extends StatefulWidget {
  const CoinShiftConfigureHomepagePage({super.key});

  @override
  State<CoinShiftConfigureHomepagePage> createState() => _CoinShiftConfigureHomepagePageState();
}

class _CoinShiftConfigureHomepagePageState extends State<CoinShiftConfigureHomepagePage> {
  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I.get<CoinShiftHomepageProvider>();

    return SailConfigureHomePage(
      widgetCatalog: CoinShiftWidgetCatalog.getCatalogMap(),
      provider: provider,
      backButtonLabel: 'Back to CoinShift homepage',
      onHomepageConfigured: () {
        // Optionally navigate back or show additional feedback
      },
    );
  }
}
