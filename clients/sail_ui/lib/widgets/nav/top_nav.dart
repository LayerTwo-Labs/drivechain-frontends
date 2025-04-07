import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final List<TopNavRoute> routes;

  const TopNav({
    super.key,
    required this.routes,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: Builder(
        builder: (context) {
          final tabsRouter = AutoTabsRouter.of(context);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SailRow(
                  leadingSpacing: true,
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ...routes.asMap().entries.map(
                          (entry) => QtTab(
                            label: entry.value.label,
                            active: tabsRouter.activeIndex == entry.key,
                            onTap: () {
                              if (entry.value.onTap != null) {
                                entry.value.onTap!();
                              } else {
                                tabsRouter.setActiveIndex(entry.key);
                              }
                            },
                          ),
                        ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.colors.divider,
              ),
            ],
          );
        },
      ),
    );
  }
}

class TopNavRoute {
  final String label;
  final VoidCallback? onTap;

  const TopNavRoute({
    required this.label,
    this.onTap,
  });
}

class QtTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const QtTab({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: SailText.primary13(
            label,
            color: active ? theme.colors.activeNavText : theme.colors.inactiveNavText,
            bold: true,
          ),
        ),
      ),
    );
  }
}
