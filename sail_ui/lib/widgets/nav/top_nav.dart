import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class TopNav extends StatefulWidget implements PreferredSizeWidget {
  final List<TopNavRoute> routes;
  final bool leadingPadding;
  final Widget? leadingWidget;
  final Widget? endWidget;

  /// Dims the bar and blocks its taps, while the user edits the homepage.
  final bool locked;

  const TopNav({
    super.key,
    required this.routes,
    this.leadingPadding = true,
    this.leadingWidget,
    this.endWidget,
    this.locked = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(53);

  @override
  State<TopNav> createState() => _TopNavState();
}

class _TopNavState extends State<TopNav> {
  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    if (SailStyleValues.phoneLayout(context)) {
      return _PhoneTopNav(
        locked: widget.locked,
        leadingWidget: widget.leadingWidget,
        endWidget: widget.endWidget,
      );
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(53),
      child: Builder(
        builder: (context) {
          final tabsRouter = AutoTabsRouter.of(context);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IgnorePointer(
                ignoring: widget.locked,
                child: Opacity(
                  opacity: widget.locked ? 0.4 : 1,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: widget.leadingPadding ? 16 : 0,
                      bottom: 4,
                    ),
                    child: SailRow(
                      spacing: SailStyleValues.compactBars(context) ? 16 : 30,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.leadingWidget != null) widget.leadingWidget!,
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
                        const Expanded(child: SizedBox()),
                        if (widget.endWidget != null) widget.endWidget!,
                        const NotificationBell(),
                      ],
                    ),
                  ),
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

/// The phone top bar: the side nav button, the leading widget, the end widget and the bell.
class _PhoneTopNav extends StatelessWidget {
  final bool locked;
  final Widget? leadingWidget;
  final Widget? endWidget;

  const _PhoneTopNav({required this.locked, this.leadingWidget, this.endWidget});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IgnorePointer(
            ignoring: locked,
            child: Opacity(
              opacity: locked ? 0.4 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: SailRow(
                  spacing: 8,
                  children: [
                    SailButton(
                      variant: ButtonVariant.icon,
                      icon: SailSVGAsset.menu,
                      onPressed: () async => Scaffold.of(context).openDrawer(),
                    ),
                    Expanded(
                      child: Align(alignment: Alignment.centerLeft, child: leadingWidget),
                    ),
                    ?endWidget,
                    const NotificationBell(),
                  ],
                ),
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: theme.colors.divider),
        ],
      ),
    );
  }
}

/// The phone side nav: the top nav routes as a list, with icon routes at the bottom.
class TopNavDrawer extends StatelessWidget {
  final List<TopNavRoute> routes;

  const TopNavDrawer({super.key, required this.routes});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    final tabsRouter = AutoTabsRouter.of(context);
    final entries = routes.asMap().entries.toList();

    Widget item(MapEntry<int, TopNavRoute> entry) {
      final route = entry.value;
      final active = tabsRouter.activeIndex == (route.optionalKey ?? entry.key);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).pop();
          if (route.onTap != null) {
            route.onTap!();
          } else {
            tabsRouter.setActiveIndex(entry.key);
          }
        },
        child: SizedBox(
          height: 48,
          child: Align(
            alignment: Alignment.centerLeft,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: active ? Colors.orange : Colors.transparent)),
              ),
              child: SailText.primary16(
                route.label ?? route.drawerLabel ?? '',
                color: active ? theme.colors.activeNavText : theme.colors.inactiveNavText,
              ),
            ),
          ),
        ),
      );
    }

    return Drawer(
      width: 288,
      backgroundColor: theme.colors.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
        side: BorderSide(color: theme.colors.border),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: max(0, constraints.maxHeight - 64)),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final entry in entries.where((e) => e.value.label != null)) item(entry),
                    const Spacer(),
                    for (final entry in entries.where((e) => e.value.label == null)) item(entry),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TopNavRoute {
  final String? label;
  final VoidCallback? onTap;
  final SailSVGAsset? icon;
  final int? optionalKey;

  /// The side nav name of a route that the top nav shows as an icon.
  final String? drawerLabel;

  const TopNavRoute({this.label, this.onTap, this.icon, this.optionalKey, this.drawerLabel})
    : assert(
        (label != null) != (icon != null),
        'Either label or icon must be set',
      );
}

class QtTab extends StatefulWidget {
  final String? label;
  final SailSVGAsset? icon;
  final bool active;
  final VoidCallback onTap;

  const QtTab({
    super.key,
    this.label,
    this.icon,
    required this.active,
    required this.onTap,
  }) : assert(
         (label != null) != (icon != null),
         'Either label or icon must be set',
       );

  @override
  State<QtTab> createState() => _QtTabState();
}

class _QtTabState extends State<QtTab> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    Color getColor() {
      if (widget.active || isHovered) {
        return theme.colors.activeNavText;
      }
      return theme.colors.inactiveNavText;
    }

    Widget tab = SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: widget.label != null
              ? SailText.primary13(widget.label!, color: getColor(), bold: true)
              : SailSVG.fromAsset(widget.icon!, color: getColor(), width: 18),
        ),
      ),
    );

    return tab;
  }
}
