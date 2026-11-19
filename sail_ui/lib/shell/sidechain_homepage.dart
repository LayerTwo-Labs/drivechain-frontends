import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/sidechain_homepage_provider.dart';

@RoutePage()
class SidechainHomepagePage extends StatelessWidget {
  const SidechainHomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(child: HomepageView(provider: GetIt.I.get<SidechainHomepageProvider>()));
  }
}
