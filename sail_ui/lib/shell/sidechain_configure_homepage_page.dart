import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/sidechain_homepage_provider.dart';
import 'package:sail_ui/shell/sidechain_module.dart';

@RoutePage()
class SidechainConfigureHomepagePage extends StatelessWidget {
  const SidechainConfigureHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = GetIt.I.get<SidechainHomepageProvider>();
    final module = GetIt.I.get<SidechainModule>();

    return SailConfigureHomePage(
      widgetCatalog: provider.getWidgetCatalog(),
      provider: provider,
      backButtonLabel: 'Back to ${module.appName} homepage',
      onHomepageConfigured: () {},
    );
  }
}
