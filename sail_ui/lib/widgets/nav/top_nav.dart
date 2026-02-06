import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class TopNav extends StatefulWidget implements PreferredSizeWidget {
  final List<TopNavRoute> routes;
  final bool leadingPadding;
  final Widget? leadingWidget;
  final Widget? endWidget;

  const TopNav({
    super.key,
    required this.routes,
    this.leadingPadding = true,
    this.leadingWidget,
    this.endWidget,
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

    return PreferredSize(
      preferredSize: const Size.fromHeight(53),
      child: Builder(
        builder: (context) {
          final tabsRouter = AutoTabsRouter.of(context);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: widget.leadingPadding ? 16 : 0, bottom: 4),
                child: SailRow(
                  spacing: 30,
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
                          disabled: entry.value.disabled,
                          disabledMessage: entry.value.disabledMessage,
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
  final bool disabled;
  final String? disabledMessage;

  const TopNavRoute({
    this.label,
    this.onTap,
    this.icon,
    this.optionalKey,
    this.disabled = false,
    this.disabledMessage,
  }) : assert((label != null) != (icon != null), 'Either label or icon must be set');
}

class QtTab extends StatefulWidget {
  final String? label;
  final SailSVGAsset? icon;
  final bool active;
  final VoidCallback onTap;
  final bool disabled;
  final String? disabledMessage;

  const QtTab({
    super.key,
    this.label,
    this.icon,
    required this.active,
    required this.onTap,
    this.disabled = false,
    this.disabledMessage,
  }) : assert((label != null) != (icon != null), 'Either label or icon must be set');

  @override
  State<QtTab> createState() => _QtTabState();
}

class _QtTabState extends State<QtTab> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    Color getColor() {
      if (widget.disabled) {
        return theme.colors.textTertiary;
      }
      if (widget.active || isHovered) {
        return theme.colors.activeNavText;
      }
      return theme.colors.inactiveNavText;
    }

    Widget tab = SelectionContainer.disabled(
      child: MouseRegion(
        cursor: widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: widget.disabled
              ? () {
                  if (widget.disabledMessage != null) {
                    showSnackBar(context, widget.disabledMessage!);
                  }
                }
              : widget.onTap,
          child: widget.label != null
              ? SailText.primary13(
                  widget.label!,
                  color: getColor(),
                  bold: true,
                )
              : SailSVG.fromAsset(
                  widget.icon!,
                  color: getColor(),
                  width: 18,
                ),
        ),
      ),
    );

    if (widget.disabled && widget.disabledMessage != null) {
      tab = Tooltip(
        message: widget.disabledMessage!,
        child: tab,
      );
    }

    return tab;
  }
}
