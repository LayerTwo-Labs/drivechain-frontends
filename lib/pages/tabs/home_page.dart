import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/routing/router.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return AutoTabsRouter.builder(
      homeIndex: 1,
      routes: const [
        DashboardTabRoute(),
        WithdrawalBundleTabRoute(),
        BlindMergedMiningTabRoute(),
        SettingsTabRoute(),
      ],
      builder: (context, children, _) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          backgroundColor: theme.colors.background,
          body: WithSideNav(child: children[tabsRouter.activeIndex]),
        );
      },
    );
  }
}

class WithSideNav extends StatelessWidget {
  final Widget child;

  const WithSideNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);
    final theme = SailTheme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 221,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding15,
              vertical: SailStyleValues.padding20,
            ),
            child: Column(
              children: [
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SailText.primary12('SBTC'), // coin name goes here
                    ),
                    SailScaleButton(
                      onPressed: () {
                        // not implemented yet!
                      },
                      child: SailRow(
                        spacing: SailStyleValues.padding05,
                        children: [
                          SailText.primary12('sample-sidechain'), // sidechain name goes here
                          SailSVG.icon(SailSVGAsset.iconDropdown, width: 5.5),
                        ],
                      ),
                    ),
                  ],
                ),
                const SailSpacing(SailStyleValues.padding50),
                NavEntry(
                  title: 'Dashboard',
                  icon: SailSVGAsset.iconDashboardTab,
                  selected: tabsRouter.activeIndex == 0,
                  onPressed: () {
                    tabsRouter.setActiveIndex(0);
                  },
                ),
                NavEntry(
                  title: 'Withdrawal bundles',
                  icon: SailSVGAsset.iconWithdrawalBundleTab,
                  selected: tabsRouter.activeIndex == 1,
                  onPressed: () {
                    tabsRouter.setActiveIndex(1);
                  },
                ),
                NavEntry(
                  title: 'Blind-merged-mining',
                  icon: SailSVGAsset.iconBMMTab,
                  selected: tabsRouter.activeIndex == 2,
                  onPressed: () {
                    tabsRouter.setActiveIndex(2);
                  },
                ),
                NavEntry(
                  title: 'Settings',
                  icon: SailSVGAsset.iconBMMTab,
                  selected: tabsRouter.activeIndex == 3,
                  onPressed: () {
                    tabsRouter.setActiveIndex(3);
                  },
                ),
              ],
            ),
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: theme.colors.divider,
        ),
        Expanded(child: child),
      ],
    );
  }
}

class NavEntry extends StatelessWidget {
  final String title;
  final SailSVGAsset icon;

  final bool selected;
  final VoidCallback onPressed;

  const NavEntry({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailScaleButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? theme.colors.actionHeader : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SailStyleValues.padding08,
            vertical: SailStyleValues.padding05,
          ),
          child: SailRow(
            spacing: SailStyleValues.padding10,
            children: [
              SailSVG.icon(icon, width: 16),
              SailText.primary12(title, bold: true),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}
