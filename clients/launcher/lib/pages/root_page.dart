import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:launcher/routing/router.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(
      animatePageTransition: false,
      routes: const [
        OverviewRoute(),
      ],
      builder: (context, child, controller) {
        final theme = SailTheme.of(context);

        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colors.background,
                    theme.colors.backgroundSecondary,
                  ],
                ),
              ),
              child: Builder(
                builder: (context) {
                  final tabsRouter = AutoTabsRouter.of(context);
                  return Row(
                    children: [
                      QtTab(
                        icon: Icon(
                          Icons.home,
                          color: tabsRouter.activeIndex == 0 ? theme.colors.primary : theme.colors.text,
                        ),
                        label: 'Overview',
                        active: tabsRouter.activeIndex == 0,
                        onTap: () => tabsRouter.setActiveIndex(0),
                      ),
                      Expanded(child: Container()),
                      const ToggleThemeButton(),
                    ],
                  );
                },
              ),
            ),
          ),
          body: Column(
            children: [
              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey,
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
