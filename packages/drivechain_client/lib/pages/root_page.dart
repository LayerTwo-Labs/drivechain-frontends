import 'package:auto_route/auto_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:drivechain_client/routing/router.dart';
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
      routes: const [
        OverviewRoute(),
        SendRoute(),
        ReceiveRoute(),
        TransactionsRoute(),
        SidechainsRoute(),
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
                      QtTab(
                        icon: Icon(
                          Icons.send,
                          color: tabsRouter.activeIndex == 1 ? theme.colors.primary : theme.colors.text,
                        ),
                        label: 'Send',
                        active: tabsRouter.activeIndex == 1,
                        onTap: () => tabsRouter.setActiveIndex(1),
                      ),
                      QtTab(
                        icon: Icon(
                          Icons.qr_code,
                          color: tabsRouter.activeIndex == 2 ? theme.colors.primary : theme.colors.text,
                        ),
                        label: 'Receive',
                        active: tabsRouter.activeIndex == 2,
                        onTap: () => tabsRouter.setActiveIndex(2),
                      ),
                      QtTab(
                        icon: Icon(
                          Icons.list,
                          color: tabsRouter.activeIndex == 3 ? theme.colors.primary : theme.colors.text,
                        ),
                        label: 'Transactions',
                        active: tabsRouter.activeIndex == 3,
                        onTap: () => tabsRouter.setActiveIndex(3),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: DottedBorder(
                          strokeWidth: 0.5,
                          // only left and right border
                          customPath: (size) => Path()
                            ..moveTo(0, 0)
                            ..lineTo(0, size.height)
                            ..moveTo(size.width, size.height)
                            ..lineTo(size.width, 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: QtTab(
                              icon: Icon(
                                Icons.link,
                                color: tabsRouter.activeIndex == 4 ? theme.colors.primary : theme.colors.text,
                              ),
                              label: 'Sidechains',
                              active: tabsRouter.activeIndex == 4,
                              onTap: () => tabsRouter.setActiveIndex(4),
                            ),
                          ),
                        ),
                      ),
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
