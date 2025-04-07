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
  String? _selectedSubItem;
  final Map<String, MenuController> _menuControllers = {};

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    if (index >= 0 && index < widget.tabs.length) {
      setState(() {
        _selectedIndex = index;
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
    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding04),
      decoration: BoxDecoration(
        color: context.sailTheme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        side: BorderSide(color: context.sailTheme.colors.formFieldBorder),
                      ),
                    ),
                  ),
                  menuChildren: [
                    SailMenu(
                      items: tab.items
                          .map(
                            (item) => SailMenuItem(
                              onSelected: () {
                                setState(() {
                                  _selectedIndex = index;
                                  _selectedSubItem = item.label;
                                });
                                if (item.onTap != null) {
                                  item.onTap!();
                                }
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
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                    _selectedSubItem = null;
                  });
                  if (tab.onTap != null) {
                    tab.onTap!();
                  }
                },
              );
            }),
          ),
          const SizedBox(height: SailStyleValues.padding16),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
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
  final bool isSelected;
  final int index;
  final bool withDropdown;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.index,
    required this.onTap,
    this.icon,
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
            if (icon != null)
              SailSVG.fromAsset(
                icon!,
                color: isSelected ? context.sailTheme.colors.background : Colors.transparent,
                height: 18,
              ),
            if (icon != null) const SizedBox(width: SailStyleValues.padding04),
            SailText.primary13(
              label,
              color: isSelected ? context.sailTheme.colors.activeNavText : context.sailTheme.colors.inactiveNavText,
              bold: true,
            ),
            if (withDropdown)
              Icon(
                Icons.arrow_drop_down,
                color: isSelected ? context.sailTheme.colors.activeNavText : context.sailTheme.colors.inactiveNavText,
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

  const TabItem({
    required this.label,
    required this.child,
    this.onTap,
    this.icon,
  });
}
