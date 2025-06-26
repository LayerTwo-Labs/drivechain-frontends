import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class InlineTabBar extends StatefulWidget {
  final List<TabItem> tabs;
  final int initialIndex;
  final int? selectedIndex;
  final void Function(int)? onTabChanged;

  const InlineTabBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.selectedIndex,
    this.onTabChanged,
  });

  @override
  State<InlineTabBar> createState() => InlineTabBarState();
}

class InlineTabBarState extends State<InlineTabBar> {
  late int _selectedIndex;
  String? _selectedSubItem;
  final Map<String, MenuController> _menuControllers = {};

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex ?? widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant InlineTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != null && widget.selectedIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.selectedIndex!;
        _selectedSubItem = null;
      });
    }
  }

  void setIndex(int index, String? label) {
    if (index >= 0 && index < widget.tabs.length) {
      setState(() {
        _selectedIndex = index;
        _selectedSubItem = label;
      });
      widget.onTabChanged?.call(index);
    } else {
      throw Exception('Index out of bounds: index=$index, tabs.length=${widget.tabs.length}');
    }
  }

  // Method to force rebuild when dropdown selection changes
  void refreshState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: context.sailTheme.colors.backgroundSecondary,
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SailRow(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(widget.tabs.length, (index) {
                final tab = widget.tabs[index];

                if (tab is MultiSelectTabItem) {
                  // Ensure we have a controller for this tab
                  _menuControllers[tab.title] ??= MenuController();

                  return MenuAnchor(
                    controller: _menuControllers[tab.title]!,
                    style: MenuStyle(
                      backgroundColor: WidgetStatePropertyAll(context.sailTheme.colors.backgroundSecondary),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                      shadowColor: const WidgetStatePropertyAll(Colors.black26),
                      elevation: const WidgetStatePropertyAll(4),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: SailStyleValues.borderRadius,
                          side: BorderSide(color: context.sailTheme.colors.border),
                        ),
                      ),
                    ),
                    menuChildren: [
                      SailMenu(
                        items: tab.items
                            .map(
                              (item) => SailMenuItem(
                                onSelected: () {
                                  setIndex(index, item.label);
                                  item.onTap?.call();
                                  _menuControllers[tab.title]!.close();
                                },
                                child: SailText.primary13(item.label),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    builder: (context, controller, child) {
                      final isSelected = _selectedIndex == index && _selectedSubItem != null;
                      final displayLabel = isSelected && _selectedSubItem != null ? _selectedSubItem! : tab.label;

                      return _TabItem(
                        label: displayLabel, // Use the dynamic label
                        isSelected: isSelected,
                        index: index,
                        icon: tab.icon,
                        onIconTap: tab.onIconTap,
                        onTap: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        withDropdown: true,
                      );
                    },
                  );
                }

                // Regular tab items
                final isSelected = index == _selectedIndex && _selectedSubItem == null;
                return _TabItem(
                  label: tab.label,
                  isSelected: isSelected,
                  index: index,
                  icon: tab.icon,
                  onIconTap: tab.onIconTap,
                  onTap: () {
                    setIndex(index, null);
                    if (tab.onTap != null) {
                      tab.onTap!();
                    }
                  },
                  withDropdown: false,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: SailStyleValues.padding16),
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    final tab = widget.tabs[_selectedIndex];

    if (tab is MultiSelectTabItem && _selectedSubItem != null) {
      final selectedItem = tab.items.firstWhere(
        (item) => item.label == _selectedSubItem,
      );
      return selectedItem.child;
    }

    return tab.child;
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final SailSVGAsset? icon;
  final VoidCallback? onIconTap;
  final bool isSelected;
  final int index;
  final bool withDropdown;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.index,
    required this.onTap,
    this.icon,
    this.onIconTap,
    this.withDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: SailStyleValues.padding04,
          horizontal: SailStyleValues.padding12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.sailTheme.colors.background : Colors.transparent,
          borderRadius: SailStyleValues.borderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.primary13(
              label,
              color: isSelected ? context.sailTheme.colors.activeNavText : context.sailTheme.colors.inactiveSubNavText,
              bold: false,
            ),
            if (icon != null) const SizedBox(width: SailStyleValues.padding04),
            if (icon != null)
              GestureDetector(
                onTap: onIconTap,
                child: SailSVG.fromAsset(
                  icon!,
                  color:
                      isSelected ? context.sailTheme.colors.activeNavText : context.sailTheme.colors.inactiveSubNavText,
                  height: 13,
                ),
              )
            else if (withDropdown)
              Icon(
                Icons.arrow_drop_down,
                color:
                    isSelected ? context.sailTheme.colors.activeNavText : context.sailTheme.colors.inactiveSubNavText,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class SingleTabItem extends TabItem {
  const SingleTabItem({
    required super.label,
    required super.child,
    super.onTap,
    super.icon,
    super.onIconTap,
  });
}

class MultiSelectTabItem extends TabItem {
  final String title; // The display title (e.g. "Tools")
  final List<TabItem> items;

  const MultiSelectTabItem({
    required this.title,
    required this.items,
  }) : super(
          label: title, // Use the title as the label
          child: const SizedBox(), // Not used since we handle content differently
        );
}

class TabItem {
  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final SailSVGAsset? icon;
  final VoidCallback? onIconTap;
  const TabItem({
    required this.label,
    required this.child,
    this.onTap,
    this.icon,
    this.onIconTap,
  });
}
