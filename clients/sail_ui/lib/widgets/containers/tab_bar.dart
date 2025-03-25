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
              }, refreshState,);
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
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }
  
  Widget _buildTabContent() {
    final tab = widget.tabs[_selectedIndex];
    
    if (tab is DropdownTabItem) {
      if (tab.selectedItem != null && tab.contentMap.containsKey(tab.selectedItem)) {
        return tab.contentMap[tab.selectedItem]!;
      }
      return tab.child;
    }
    
    return tab.child;
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

/// A special tab item that displays a dropdown menu when clicked.
/// When a menu item is selected, the tab's content changes accordingly.
class DropdownTabItem extends TabItem {
  final List<String> menuItems;
  final Function(String) onItemSelected;
  
  // Keep track of the currently selected item
  String? selectedItem;
  
  // Map of menu labels to content widgets
  final Map<String, Widget> contentMap;
  
  // Whether to keep the original label or show the selected item
  final bool useFixedLabel;
  
  // Store the menu controller as a class member
  final MenuController _menuController = MenuController();

  /// Returns the current content widget based on the selected item
  Widget get currentContent {
    if (selectedItem != null && contentMap.containsKey(selectedItem)) {
      return contentMap[selectedItem]!;
    }
    // Fallback to default child
    return child;
  }

  DropdownTabItem({
    required super.label,
    required super.icon,
    required super.child,
    required this.menuItems,
    required this.onItemSelected,
    required this.contentMap,
    this.selectedItem,
    this.useFixedLabel = false,
    super.onTap,
  });

  /// Builds the dropdown tab UI
  Widget buildTab(BuildContext context, bool isSelected, VoidCallback onTabTap, VoidCallback refreshState) {
    final theme = SailTheme.of(context);
    
    // If no item is selected, default to the first one
    selectedItem ??= menuItems.isNotEmpty ? menuItems.first : null;
    
    return MenuAnchor(
      controller: _menuController,
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
          items: menuItems.map((item) => 
            SailMenuItem(
              onSelected: () {
                // Update the selected item
                selectedItem = item;
                
                // Force parent to rebuild with the new content
                refreshState();
                
                // Call the item selected callback
                onItemSelected(item);
                
                // Close the dropdown
                _menuController.close();
              },
              child: SailText.primary13(item),
            ),
          ).toList(),
        ),
      ],
      builder: (context, menuController, child) {
        return InkWell(
          onTap: () {
            onTabTap();
            
            // Toggle the dropdown menu
            if (_menuController.isOpen) {
              _menuController.close();
            } else {
              _menuController.open();
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
                  useFixedLabel ? label : (isSelected && selectedItem != null ? '$label: $selectedItem' : label),
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