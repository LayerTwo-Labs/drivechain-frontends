import 'package:auto_route/auto_route.dart';
import 'package:faucet/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(
      animatePageTransition: false,
      routes: [
        FaucetRoute(),
        ExplorerRoute(),
      ],
      builder: (context, child, controller) {
        final theme = SailTheme.of(context);

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: TopNav(
            leadingPadding: false,
            routes: [
              TopNavRoute(
                label: 'Faucet',
              ),
              TopNavRoute(
                label: 'Explorer',
              ),
            ],
          ),
          body: child,
        );
      },
    );
  }
}
