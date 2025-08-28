import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class CrossPlatformMenuBar extends StatelessWidget {
  final List<PlatformMenuItem> menus;
  final Widget child;

  const CrossPlatformMenuBar({super.key, required this.menus, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return PlatformMenuBar(menus: menus, child: child);
    }

    return Column(
      children: [
        Container(
          color: context.sailTheme.colors.background,
          height: 28,
          child: Row(
            children: [
              const SizedBox(width: 8),
              for (final menu in menus)
                if (menu is PlatformMenu) ...[_buildMenu(context, menu), const SizedBox(width: 4)],
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildMenu(BuildContext context, PlatformMenu menu) {
    return _MenuButton(menu: menu);
  }
}

class _MenuButton extends StatefulWidget {
  final PlatformMenu menu;

  const _MenuButton({required this.menu});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  late final MenuController _controller;
  bool _isInButton = false;
  bool _isInMenu = false;

  @override
  void initState() {
    super.initState();
    _controller = MenuController();
  }

  void _checkShouldClose() {
    // Add delay to make menu more forgiving when moving between areas
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && !_isInButton && !_isInMenu) {
        _controller.close();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isInButton = true;
        _controller.open();
      }),
      onExit: (_) => setState(() {
        _isInButton = false;
        _checkShouldClose();
      }),
      child: MenuAnchor(
        controller: _controller,
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(context.sailTheme.colors.background),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        ),
        builder: (context, controller, child) {
          return TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              backgroundColor: controller.isOpen ? context.sailTheme.colors.backgroundSecondary : Colors.transparent,
            ),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: SailText.primary13(widget.menu.label),
          );
        },
        menuChildren: [
          MouseRegion(
            onEnter: (_) => setState(() => _isInMenu = true),
            onExit: (_) => setState(() {
              _isInMenu = false;
              _checkShouldClose();
            }),
            child: SailMenu(items: _buildMenuItems(context, widget.menu)),
          ),
        ],
      ),
    );
  }

  List<SailMenuEntity> _buildMenuItems(BuildContext context, PlatformMenu menu) {
    final items = <SailMenuEntity>[];

    for (final group in menu.menus) {
      if (group is PlatformMenuItemGroup) {
        items.addAll(_buildMenuGroup(context, group));
        items.add(const SailMenuItemDivider());
      }
    }

    if (items.isNotEmpty && items.last is SailMenuItemDivider) {
      items.removeLast();
    }

    return items;
  }

  List<SailMenuEntity> _buildMenuGroup(BuildContext context, PlatformMenuItemGroup group) {
    return group.members.map((item) {
      final bool isEnabled = item.onSelected != null;

      return SailMenuItem(
        onSelected: item.onSelected,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SailText.primary13(
              item.label,
              color: isEnabled ? context.sailTheme.colors.text : context.sailTheme.colors.text.withValues(alpha: 0.3),
            ),
            if (item.shortcut != null)
              SailText.secondary13(
                _getShortcutLabel(item.shortcut!),
                color: isEnabled
                    ? context.sailTheme.colors.textTertiary
                    : context.sailTheme.colors.textTertiary.withValues(alpha: 0.3),
              ),
          ],
        ),
      );
    }).toList();
  }

  String _getShortcutLabel(MenuSerializableShortcut shortcut) {
    if (shortcut is SingleActivator) {
      final List<String> keys = [];
      if (shortcut.meta) keys.add('⌘');
      if (shortcut.shift) keys.add('⇧');
      if (shortcut.alt) keys.add('⌥');
      if (shortcut.control) keys.add('⌃');
      keys.add(shortcut.trigger.keyLabel);
      return keys.join(' ');
    }
    return '';
  }
}
