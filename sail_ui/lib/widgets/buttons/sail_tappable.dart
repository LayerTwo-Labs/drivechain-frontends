import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Tappable wrapper with hover highlight and click cursor.
class SailTappable extends StatefulWidget {
  final Future<void> Function()? onTap;
  final Future<void> Function()? onDoubleTap;
  final Widget child;
  final BorderRadius? borderRadius;
  final Color? hoverColor;
  final MouseCursor cursor;

  const SailTappable({
    super.key,
    this.onTap,
    this.onDoubleTap,
    required this.child,
    this.borderRadius,
    this.hoverColor,
    this.cursor = SystemMouseCursors.click,
  });

  @override
  State<SailTappable> createState() => _SailTappableState();
}

class _SailTappableState extends State<SailTappable> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final enabled = widget.onTap != null || widget.onDoubleTap != null;
    final hoverColor = widget.hoverColor ?? theme.colors.text.withValues(alpha: 0.04);

    return MouseRegion(
      cursor: enabled ? widget.cursor : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap != null ? () => widget.onTap!() : null,
        onDoubleTap: widget.onDoubleTap != null ? () => widget.onDoubleTap!() : null,
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: ColoredBox(
            color: _hovered && enabled ? hoverColor : SailColorScheme.transparent,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
