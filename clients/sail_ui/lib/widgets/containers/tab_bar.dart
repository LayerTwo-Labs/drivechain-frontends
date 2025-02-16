import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class InlineTabBar extends StatefulWidget {
  final List<TabItem> tabs;
  final int initialIndex;
  final void Function(int)? onTabChanged;

  const InlineTabBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
  });

  @override
  State<InlineTabBar> createState() => InlineTabBarState();
}

class InlineTabBarState extends State<InlineTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    if (index >= 0 && index < widget.tabs.length) {
      setState(() => _selectedIndex = index);
      widget.onTabChanged?.call(index);
    } else {
      throw Exception('Index out of bounds: index=$index, tabs.length=${widget.tabs.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(widget.tabs.length, (index) {
            final isSelected = index == _selectedIndex;
            return InkWell(
              onTap: () {
                if (widget.tabs[index].onTap != null) {
                  widget.tabs[index].onTap!();
                }
                setIndex(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: SailStyleValues.padding04,
                  horizontal: SailStyleValues.padding12,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? context.sailTheme.colors.backgroundSecondary : context.sailTheme.colors.background,
                  borderRadius: BorderRadius.circular(SailStyleValues.padding04),
                ),
                child: Row(
                  children: [
                    SailSVG.fromAsset(
                      widget.tabs[index].icon,
                      color:
                          isSelected ? context.sailTheme.colors.textSecondary : context.sailTheme.colors.textTertiary,
                      height: 18,
                    ),
                    const SizedBox(width: SailStyleValues.padding08),
                    SailText.primary13(
                      widget.tabs[index].label,
                      color:
                          isSelected ? context.sailTheme.colors.textSecondary : context.sailTheme.colors.textTertiary,
                      bold: true,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: SailStyleValues.padding08),
        Expanded(child: widget.tabs[_selectedIndex].child),
      ],
    );
  }
}

class TabItem {
  final String label;
  final SailSVGAsset icon;
  final Widget child;
  final VoidCallback? onTap;

  const TabItem({
    required this.label,
    required this.icon,
    required this.child,
    this.onTap,
  });
}
