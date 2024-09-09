import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/style/shadows.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';

class SailCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final double size;
  final double cornerRadius;
  final bool enabled;

  const SailCheckbox({
    required this.value,
    this.onChanged,
    this.label,
    this.size = 16.0,
    this.cornerRadius = 4.0,
    this.enabled = true,
    super.key,
  });

  @override
  State<SailCheckbox> createState() => _SailCheckboxState();
}

class _SailCheckboxState extends State<SailCheckbox> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    var enabled = widget.onChanged != null && widget.enabled;

    Widget visual;
    if (widget.value) {
      Color color;

      if (enabled) {
        if (Platform.isMacOS) {
          color = CupertinoColors.activeBlue;
        } else {
          color = Theme.of(context).indicatorColor;
        }
        if (_pressed) color = Color.lerp(color, Colors.black, 0.2)!;
      } else {
        color = Theme.of(context).disabledColor;
      }

      visual = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(widget.cornerRadius)),
          color: color,
          boxShadow: enabled ? sailBoxShadow(context) : null,
        ),
        child: Icon(
          Icons.check,
          size: widget.size - 2,
          color: Theme.of(context).cardColor,
        ),
      );
    } else {
      var color = Theme.of(context).cardColor;
      if (_pressed) color = Color.lerp(color, Colors.black, 0.2)!;

      visual = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(widget.cornerRadius)),
          color: color,
          border: Border.all(
            color: Colors.grey,
            width: 0.5,
          ),
          boxShadow: sailBoxShadow(context),
        ),
      );
    }

    if (widget.label != null) {
      var textStyle = SailStyleValues.twelve;
      if (!enabled) {
        textStyle = textStyle.copyWith(
          color: SailTheme.of(context).colors.textSecondary,
        );
      }

      visual = Row(
        children: [
          visual,
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              widget.label!,
              style: textStyle,
            ),
          ),
        ],
      );
    }

    if (!enabled) return visual;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onChanged!(!widget.value);
      },
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      child: visual,
    );
  }
}
