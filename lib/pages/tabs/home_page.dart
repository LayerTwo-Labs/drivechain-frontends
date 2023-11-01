import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sidesail/routing/router.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return AutoTabsRouter.pageView(
      homeIndex: 1,
      routes: const [
        DashboardTabRoute(),
        WithdrawalBundleTabRoute(),
        BlindMergedMiningTabRoute(),
      ],
      builder: (context, child, _) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: theme.colors.backgroundSecondary,
            unselectedItemColor: theme.colors.text,
            selectedItemColor: theme.colors.orange,
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            items: [
              BottomNavigationBarItem(
                label: 'Dashboard',
                icon: SailSVG.icon(
                  SailSVGAsset.iconDashboardTab,
                  isHighlighted: tabsRouter.activeIndex == 0,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Withdrawal Bundles',
                icon: SailSVG.icon(
                  SailSVGAsset.iconDashboardTab,
                  isHighlighted: tabsRouter.activeIndex == 1,
                ),
              ),
              BottomNavigationBarItem(
                label: 'BMM',
                icon: SailSVG.icon(
                  SailSVGAsset.iconDashboardTab,
                  isHighlighted: tabsRouter.activeIndex == 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
