import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

const _menuItemHeight = 24.0;
const _menuDividerHeight = 10.0;
const _menuPadding = EdgeInsets.all(4);
const _menuPaddingWindows = EdgeInsets.symmetric(vertical: 4);

class SailMenu extends StatelessWidget {
  const SailMenu({
    required this.items,
    this.width,
    super.key,
  });

  final List<SailMenuEntity> items;
  final double? width;

  double get height => items.fold(_menuPadding.vertical * 2, (prev, e) => prev + e.height);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.sailTheme.colors.popoverBackground,
        borderRadius: BorderRadius.all(Radius.circular(context.isWindows ? 3 : 4)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
        ),
      ),
      padding: context.isWindows ? _menuPaddingWindows : _menuPadding,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        ),
      ),
    );
  }
}

abstract class SailMenuEntity extends Widget {
  const SailMenuEntity({super.key});

  double get height;
}

class SailMenuItem extends StatefulWidget implements SailMenuEntity {
  const SailMenuItem({
    required this.child,
    this.onSelected,
    this.height = _menuItemHeight,
    super.key,
  });

  final Widget child;
  final VoidCallback? onSelected;

  @override
  final double height;

  @override
  State<SailMenuItem> createState() => _SailMenuItemState();
}

class _SailMenuItemState extends State<SailMenuItem> {
  bool _hover = false;
  bool _selected = false;
  bool _flashing = false;

  Timer? _closeTimer;
  Timer? _toggleFlashTimer;

  @override
  Widget build(BuildContext context) {
    bool enabled = widget.onSelected != null;
    var menuPadding = context.isWindows ? _menuPaddingWindows : _menuPadding;

    var menu = context.findAncestorWidgetOfExactType<SailMenu>();
    var menuWidth = menu?.width;
    if (menuWidth != null) menuWidth += menuPadding.horizontal * 2;

    var highlightColor = context.isWindows ? context.sailTheme.colors.text : context.sailTheme.colors.primary;
    var textColor = enabled ? context.sailTheme.colors.text : context.sailTheme.colors.textTertiary;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          if (!_selected && enabled) {
            _hover = true;
          }
        });
      },
      onExit: (_) {
        setState(() {
          _hover = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (enabled && !_selected) {
            _handleSelection(context.isWindows);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.isWindows ? 12 : 16),
          width: menuWidth,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: context.isWindows ? null : const BorderRadius.all(Radius.circular(4.0)),
            color: _hover || (_selected && _flashing) ? highlightColor : null,
          ),
          child: DefaultTextStyle(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSelection(bool isWindows) {
    _selected = true;

    // Start flashing the item.
    if (!isWindows) {
      _toggleFlash();
    }

    // Close menu after a short delay.
    var closeDelay = isWindows ? 50 : 240;
    _closeTimer = Timer(Duration(milliseconds: closeDelay), () {
      final menuAnchor = context.findAncestorWidgetOfExactType<MenuAnchor>();
      if (menuAnchor != null) {
        menuAnchor.controller?.close();
      }

      if (widget.onSelected != null) {
        widget.onSelected!();
      }
    });
  }

  void _toggleFlash() {
    setState(() {
      _hover = false;
      _flashing = !_flashing;
    });

    _toggleFlashTimer?.cancel();
    _toggleFlashTimer = Timer(const Duration(milliseconds: 80), _toggleFlash);
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _toggleFlashTimer?.cancel();
    super.dispose();
  }
}

class SailMenuItemDivider extends StatelessWidget implements SailMenuEntity {
  final bool padding;

  const SailMenuItemDivider({
    super.key,
    this.padding = true,
  });

  @override
  double get height => _menuDividerHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _menuDividerHeight,
      padding: padding ? EdgeInsets.symmetric(horizontal: context.isWindows ? 8 : 16) : null,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          color: context.sailTheme.colors.divider,
          height: 1.0,
        ),
      ),
    );
  }
}
