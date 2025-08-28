import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class TopNav extends StatefulWidget implements PreferredSizeWidget {
  final List<TopNavRoute> routes;
  final bool leadingPadding;
  final Widget? endWidget;

  const TopNav({super.key, required this.routes, this.leadingPadding = false, this.endWidget});

  @override
  Size get preferredSize => const Size.fromHeight(35);

  @override
  State<TopNav> createState() => _TopNavState();
}

class _TopNavState extends State<TopNav> {
  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return PreferredSize(
      preferredSize: const Size.fromHeight(35),
      child: Builder(
        builder: (context) {
          final tabsRouter = AutoTabsRouter.of(context);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: widget.leadingPadding ? 48 : 0),
                child: SailRow(
                  leadingSpacing: true,
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.routes.asMap().entries.map(
                      (entry) => DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: tabsRouter.activeIndex == (entry.value.optionalKey ?? entry.key)
                                  ? Colors.orange
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 6),
                          child: QtTab(
                            label: entry.value.label,
                            icon: entry.value.icon,
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
                      ),
                    ),
                    if (widget.endWidget != null) Expanded(child: Container()),
                    if (widget.endWidget != null) widget.endWidget!,
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: theme.colors.divider),
            ],
          );
        },
      ),
    );
  }
}

class TopNavRoute {
  final String? label;
  final VoidCallback? onTap;
  final SailSVGAsset? icon;
  final int? optionalKey;

  const TopNavRoute({this.label, this.onTap, this.icon, this.optionalKey})
    : assert((label != null) != (icon != null), 'Either label or icon must be set');
}

class QtTab extends StatefulWidget {
  final String? label;
  final SailSVGAsset? icon;
  final bool active;
  final VoidCallback onTap;

  const QtTab({super.key, this.label, this.icon, required this.active, required this.onTap})
    : assert((label != null) != (icon != null), 'Either label or icon must be set');

  @override
  State<QtTab> createState() => _QtTabState();
}

class _QtTabState extends State<QtTab> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: widget.label != null
              ? SailText.primary13(
                  widget.label!,
                  color: widget.active || isHovered ? theme.colors.activeNavText : theme.colors.inactiveNavText,
                  bold: true,
                )
              : SailSVG.fromAsset(
                  widget.icon!,
                  color: widget.active || isHovered ? theme.colors.activeNavText : theme.colors.inactiveNavText,
                  width: 18,
                ),
        ),
      ),
    );
  }
}
