import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailRadioButton<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final double size;
  final bool enabled;

  const SailRadioButton({
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
    this.size = SailStyleValues.padding15,
    this.enabled = true,
    super.key,
  });

  @override
  State<SailRadioButton<T>> createState() => _SailRadioButtonState<T>();
}

class _SailRadioButtonState<T> extends State<SailRadioButton<T>> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    var enabled = widget.onChanged != null && widget.enabled;

    Widget visual;
    if (widget.value == widget.groupValue) {
      Color color;

      if (enabled) {
        color = SailTheme.of(context).colors.primary;
        if (_pressed) color = Color.lerp(color, Colors.black, 0.2)!;
      } else {
        color = Theme.of(context).disabledColor;
      }

      visual = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // borderRadius: BorderRadius.all(Radius.circular(widget.cornerRadius)),
          color: color,
          boxShadow: enabled ? sailBoxShadow(context) : null,
        ),
        child: Icon(
          Icons.circle,
          size: widget.size / 2,
          color: SailTheme.of(context).colors.background,
        ),
      );
    } else {
      var color = SailTheme.of(context).colors.background;
      if (_pressed) color = Color.lerp(color, Colors.black, 0.2)!;

      visual = Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: SailTheme.of(context).colors.formFieldBorder, width: 1.0),
          boxShadow: sailBoxShadow(context),
        ),
      );
    }

    if (widget.label != null) {
      visual = Row(
        children: [
          visual,
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SailText.primary12(
              widget.label!,
              color: enabled ? SailTheme.of(context).colors.text : SailTheme.of(context).colors.textTertiary,
            ),
          ),
        ],
      );
    }

    if (!enabled) return visual;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onChanged!(widget.value);
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
