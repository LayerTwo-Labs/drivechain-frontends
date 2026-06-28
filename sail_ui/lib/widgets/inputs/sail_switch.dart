import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;
  final double width;
  final double height;

  const SailSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
    this.width = 36,
    this.height = 20,
  });

  bool get _isEnabled => !disabled && onChanged != null;

  @override
  State<SailSwitch> createState() => _SailSwitchState();
}

class _SailSwitchState extends State<SailSwitch> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: widget.value ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(covariant SailSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget._isEnabled) return;
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final enabled = widget._isEnabled;

    final activeColor = theme.colors.primary;
    final inactiveColor = theme.colors.backgroundSecondary;
    final borderColor = theme.colors.border;
    final thumbColor = theme.colors.background;

    final padding = 2.0;
    final thumbSize = widget.height - padding * 2;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerUp: (PointerUpEvent e) => _handleTap(),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              final t = _animation.value;
              final terminal = theme.chrome.terminalStyle;
              final trackColor = Color.lerp(inactiveColor, activeColor, t)!;
              return Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(terminal ? 3 : widget.height),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Align(
                    alignment: Alignment(-1.0 + 2.0 * t, 0),
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: terminal
                          ? BoxDecoration(
                              color: thumbColor,
                              borderRadius: BorderRadius.circular(2),
                            )
                          : BoxDecoration(
                              color: thumbColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colors.shadow,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
