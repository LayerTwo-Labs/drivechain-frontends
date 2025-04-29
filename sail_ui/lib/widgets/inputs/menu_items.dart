import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

const _menuItemHeight = 33.0;
const _menuDividerHeight = 10.0;
const _menuPadding = EdgeInsets.all(4);
const _menuPaddingWindows = EdgeInsets.symmetric(vertical: 4);

class SailMenu extends StatelessWidget {
  final String? title;

  const SailMenu({
    required this.items,
    this.title,
    this.width,
    super.key,
  });

  final List<SailMenuEntity> items;
  final double? width;

  double get height => items.fold(_menuPadding.vertical * 2, (prev, e) => prev + e.height);

  @override
  Widget build(BuildContext context) {
    final minWidth = width ?? 0;
    final maxWidth = width ?? double.infinity;

    return Container(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: context.sailTheme.colors.background,
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(
          color: context.sailTheme.colors.border,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 12,
              ),
              child: SailText.primary13(
                title!,
                bold: true,
              ),
            ),
          if (title != null)
            Divider(
              height: 1,
            ),
          ...items,
        ],
      ),
    );
  }
}

abstract class SailMenuEntity extends Widget {
  const SailMenuEntity({super.key});

  double get height;
}

class SailMenuItem extends StatefulWidget implements SailMenuEntity {
  final Widget child;
  final VoidCallback? onSelected;
  final bool closeOnSelect;

  const SailMenuItem({
    required this.child,
    this.onSelected,
    this.closeOnSelect = true,
    this.height = _menuItemHeight,
    super.key,
  });

  @override
  final double height;

  @override
  State<SailMenuItem> createState() => _SailMenuItemState();
}

class _SailMenuItemState extends State<SailMenuItem> {
  bool _hover = false;
  final bool _selected = false;

  Timer? _closeTimer;

  @override
  Widget build(BuildContext context) {
    bool enabled = widget.onSelected != null;
    var menuPadding = context.isWindows ? _menuPaddingWindows : _menuPadding;

    var menu = context.findAncestorWidgetOfExactType<SailMenu>();
    var menuWidth = menu?.width;
    if (menuWidth != null) menuWidth += menuPadding.horizontal * 2;

    var highlightColor = context.sailTheme.colors.backgroundSecondary;
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
          padding: EdgeInsets.symmetric(horizontal: 16),
          width: menuWidth,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: context.isWindows ? null : const BorderRadius.all(Radius.circular(4.0)),
            color: _hover || _selected ? highlightColor : null,
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
    if (widget.closeOnSelect) {
      final menuAnchor = context.findAncestorWidgetOfExactType<MenuAnchor>();
      if (menuAnchor != null) {
        menuAnchor.controller?.close();
      }
    }

    if (widget.onSelected != null) {
      widget.onSelected!();
    }
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
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
