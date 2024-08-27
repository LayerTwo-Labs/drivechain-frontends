import 'package:auto_route/auto_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:drivechain_client/routing/router.dart';
import 'package:drivechain_client/util/color.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

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
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.darken(0.1)
                  ],
                ),
              ),
              child: Builder(
                builder: (context) {
                  final tabsRouter = AutoTabsRouter.of(context);
                  return Row(
                    children: [
                      QtTab(
                        icon: const Icon(Icons.home),
                        label: 'Overview',
                        active: tabsRouter.activeIndex == 0,
                        onTap: () => tabsRouter.setActiveIndex(0),
                      ),
                      QtTab(
                        icon: const Icon(Icons.send),
                        label: 'Send',
                        active: tabsRouter.activeIndex == 1,
                        onTap: () => tabsRouter.setActiveIndex(1),
                      ),
                      QtTab(
                        icon: const Icon(Icons.qr_code),
                        label: 'Receive',
                        active: tabsRouter.activeIndex == 2,
                        onTap: () => tabsRouter.setActiveIndex(2),
                      ),
                      QtTab(
                        icon: const Icon(Icons.list),
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
                              icon: const Icon(Icons.link),
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

// TODO: Move this to sail_ui if wanted
class QtTab extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool active;
  final VoidCallback onTap;

  const QtTab({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? Colors.grey.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 2),
              SailText.primary12(label),
            ],
          ),
        ),
      ),
    );
  }
}
