import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:bbc/providers/bbc_homepage_provider.dart';
import 'package:bbc/widgets/homepage_widget_catalog.dart';

@RoutePage()
class BbcConfigureHomepagePage extends StatefulWidget {
  const BbcConfigureHomepagePage({super.key});

  @override
  State<BbcConfigureHomepagePage> createState() => _BbcConfigureHomepagePageState();
}

class _BbcConfigureHomepagePageState extends State<BbcConfigureHomepagePage> {
  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I.get<BbcHomepageProvider>();

    return SailConfigureHomePage(
      widgetCatalog: BbcWidgetCatalog.getCatalogMap(),
      provider: provider,
      backButtonLabel: 'Back to Bbc homepage',
      onHomepageConfigured: () {
        // Optionally navigate back or show additional feedback
      },
    );
  }
}
