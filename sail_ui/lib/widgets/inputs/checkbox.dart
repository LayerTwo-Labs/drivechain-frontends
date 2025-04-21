import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

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
    this.size = SailStyleValues.padding16,
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
        color = context.sailTheme.colors.text;
        if (_pressed) color = Color.lerp(color, Colors.black, 0.2)!;
      } else {
        color = context.sailTheme.colors.disabledBackground;
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
          color: context.sailTheme.colors.background,
        ),
      );
    } else {
      var color = context.sailTheme.colors.backgroundSecondary;
      if (_pressed) color = Color.lerp(color, Colors.black, 0.2)!;

      visual = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(widget.cornerRadius)),
          color: color,
          border: Border.all(
            color: context.sailTheme.colors.border,
            width: 0.5,
          ),
          boxShadow: sailBoxShadow(context),
        ),
      );
    }

    if (widget.label != null) {
      visual = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          visual,
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SailText.primary12(
              widget.label!,
              color: enabled ? context.sailTheme.colors.text : context.sailTheme.colors.textSecondary,
            ),
          ),
        ],
      );
    }

    return MouseRegion(
      cursor: enabled ? WidgetStateMouseCursor.clickable : SystemMouseCursors.forbidden,
      child: Builder(
        builder: (context) {
          if (!enabled) {
            return visual;
          }
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
        },
      ),
    );
  }
}
