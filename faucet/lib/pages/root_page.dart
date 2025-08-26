import 'package:auto_route/auto_route.dart';
import 'package:faucet/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(
      animatePageTransition: false,
      routes: [FaucetRoute(), ExplorerRoute()],
      builder: (context, child, controller) {
        final theme = SailTheme.of(context);

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: TopNav(
            routes: [
              TopNavRoute(label: 'Faucet'),
              TopNavRoute(label: 'Explorer'),
              TopNavRoute(label: 'Info', onTap: () => launchUrl(Uri.parse('https://drivechain.info'))),
              TopNavRoute(label: 'Dev', onTap: () => launchUrl(Uri.parse('https://www.drivechain.info/dev.txt'))),
            ],
          ),
          body: child,
        );
      },
    );
  }
}
