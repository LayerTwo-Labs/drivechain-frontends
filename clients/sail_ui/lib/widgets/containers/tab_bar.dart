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
            final tab = widget.tabs[index];
            
            // Handle dropdown tab items differently
            if (tab is DropdownTabItem) {
              return tab.buildTab(context, isSelected, () {
                if (tab.onTap != null) {
                  tab.onTap!();
                }
                setIndex(index);
              });
            }
            
            // Regular tab items
            return InkWell(
              onTap: () {
                if (tab.onTap != null) {
                  tab.onTap!();
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
                      tab.icon,
                      color:
                          isSelected ? context.sailTheme.colors.textSecondary : context.sailTheme.colors.textTertiary,
                      height: 18,
                    ),
                    const SizedBox(width: SailStyleValues.padding08),
                    SailText.primary13(
                      tab.label,
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

class DropdownTabItem extends TabItem {
  final List<String> menuItems;
  final Function(String) onItemSelected;

  const DropdownTabItem({
    required super.label,
    required super.icon,
    required super.child,
    required this.menuItems,
    required this.onItemSelected,
    super.onTap,
  });

  Widget buildTab(BuildContext context, bool isSelected, VoidCallback onTabTap) {
    final theme = SailTheme.of(context);
    
    // Create SailMenuItems from the string menu items
    final sailMenuItems = menuItems.map((item) => 
      SailMenuItem(
        onSelected: () {
          onItemSelected(item);
        },
        child: SailText.primary13(item),
      )
    ).toList();
    
    // Create a MenuController to control the dropdown
    final MenuController controller = MenuController();
    
    return MenuAnchor(
      controller: controller,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.colors.backgroundSecondary),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shadowColor: WidgetStatePropertyAll(Colors.black26),
        elevation: const WidgetStatePropertyAll(4),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SailStyleValues.padding04),
            side: BorderSide(color: theme.colors.formFieldBorder),
          ),
        ),
      ),
      menuChildren: [
        SailMenu(
          items: sailMenuItems,
        ),
      ],
      builder: (context, menuController, child) {
        return InkWell(
          onTap: () {
            if (onTap != null) {
              onTap!();
            }
            onTabTap();
            
            // Toggle the dropdown menu
            if (menuController.isOpen) {
              menuController.close();
            } else {
              menuController.open();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: SailStyleValues.padding04,
              horizontal: SailStyleValues.padding12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? theme.colors.backgroundSecondary : theme.colors.background,
              borderRadius: BorderRadius.circular(SailStyleValues.padding04),
            ),
            child: Row(
              children: [
                SailSVG.fromAsset(
                  icon,
                  color: isSelected ? theme.colors.textSecondary : theme.colors.textTertiary,
                  height: 18,
                ),
                const SizedBox(width: SailStyleValues.padding08),
                SailText.primary13(
                  label,
                  color: isSelected ? theme.colors.textSecondary : theme.colors.textTertiary,
                  bold: true,
                ),
                const SizedBox(width: SailStyleValues.padding04),
                Icon(
                  Icons.arrow_drop_down,
                  color: isSelected ? theme.colors.textSecondary : theme.colors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
