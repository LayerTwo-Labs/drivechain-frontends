import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:url_launcher/url_launcher.dart';

const _menuItemHeight = 33.0;
const _menuItemWidth = 200.0;
const _menuDividerHeight = 10.0;
const _menuPadding = EdgeInsets.all(4);
const _menuPaddingWindows = EdgeInsets.symmetric(vertical: 4);

class SailMenu extends StatelessWidget {
  final String? title;

  const SailMenu({required this.items, this.title, this.width, super.key});

  final List<SailMenuEntity> items;
  final double? width;

  double get height => items.fold(_menuPadding.vertical * 2, (prev, e) => prev + e.height);
  double get maxItemWidth => items.fold(0.0, (m, e) => max(m, e.width));

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? maxItemWidth;
    final minWidth = effectiveWidth;
    final maxWidth = effectiveWidth;

    return Container(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: context.sailTheme.colors.background,
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: context.sailTheme.colors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 12),
              child: SailText.primary13(title!, bold: true),
            ),
          if (title != null) Divider(height: 1),
          ...items,
        ],
      ),
    );
  }
}

abstract class SailMenuEntity extends Widget {
  const SailMenuEntity({super.key});

  double get height;
  double get width;
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
    this.width = _menuItemWidth,
    super.key,
  });

  @override
  final double height;
  @override
  final double width;

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
          padding: EdgeInsets.symmetric(horizontal: 12),
          width: menuWidth,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: context.isWindows ? null : const BorderRadius.all(Radius.circular(4.0)),
            color: _hover || _selected ? highlightColor : null,
          ),
          child: DefaultTextStyle(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Expanded(child: widget.child)],
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

  const SailMenuItemDivider({super.key, this.padding = true});

  @override
  double get height => _menuDividerHeight;
  @override
  double get width => _menuItemWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _menuDividerHeight,
      width: width,
      padding: padding ? EdgeInsets.symmetric(horizontal: context.isWindows ? 8 : 16) : null,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(color: context.sailTheme.colors.divider, height: 1.0),
      ),
    );
  }
}

class MempoolMenuItem extends StatelessWidget implements SailMenuEntity {
  final String txid;

  const MempoolMenuItem({super.key, required this.txid});

  @override
  double get height => _menuItemHeight;

  @override
  double get width => _menuItemWidth + 100; // Add 100 to account for the long text

  @override
  Widget build(BuildContext context) {
    final url = 'https://explorer.drivechain.info/tx/$txid';
    return SailMenuItem(
      onSelected: () async {
        await launchUrl(Uri.parse(url));
      },
      child: SailText.primary12('View on explorer.drivechain.info'),
    );
  }
}
