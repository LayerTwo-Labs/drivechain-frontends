import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SideNav extends StatelessWidget {
  final List<SideNavItem> items;
  final double width;
  final ValueChanged<int>? onItemSelected;
  final int selectedIndex;

  const SideNav({super.key, required this.items, this.width = 200, this.onItemSelected, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.asMap().entries.map(
            (entry) => _SideNavItem(
              label: entry.value.label,
              isSelected: entry.key == selectedIndex,
              onTap: () => onItemSelected?.call(entry.key),
            ),
          ),
        ],
      ),
    );
  }
}

class SideNavItem {
  final String label;

  const SideNavItem({required this.label});
}

class _SideNavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _SideNavItem({required this.label, required this.onTap, this.isSelected = false});

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: SailStyleValues.padding16,
            vertical: SailStyleValues.padding10,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected || isHovered ? theme.colors.backgroundSecondary : Colors.transparent,
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: SailText.primary13(widget.label, bold: true),
        ),
      ),
    );
  }
}
