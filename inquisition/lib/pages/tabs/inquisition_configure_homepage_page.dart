import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:inquisition/providers/inquisition_homepage_provider.dart';
import 'package:inquisition/widgets/homepage_widget_catalog.dart';

@RoutePage()
class InquisitionConfigureHomepagePage extends StatefulWidget {
  const InquisitionConfigureHomepagePage({super.key});

  @override
  State<InquisitionConfigureHomepagePage> createState() => _InquisitionConfigureHomepagePageState();
}

class _InquisitionConfigureHomepagePageState extends State<InquisitionConfigureHomepagePage> {
  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I.get<InquisitionHomepageProvider>();

    return SailConfigureHomePage(
      widgetCatalog: InquisitionWidgetCatalog.getCatalogMap(),
      provider: provider,
      backButtonLabel: 'Back to Inquisition homepage',
      onHomepageConfigured: () {
        // Optionally navigate back or show additional feedback
      },
    );
  }
}
