import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final bool disabled;
  final double height;

  const SailSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.disabled = false,
    this.height = 20,
  }) : assert(max > min);

  bool get _isEnabled => !disabled && onChanged != null;

  @override
  State<SailSlider> createState() => _SailSliderState();
}

class _SailSliderState extends State<SailSlider> {
  void _emit(double localX, double trackWidth) {
    if (!widget._isEnabled) return;
    final clamped = localX.clamp(0.0, trackWidth);
    double t = trackWidth == 0 ? 0 : clamped / trackWidth;
    double v = widget.min + t * (widget.max - widget.min);
    if (widget.divisions != null && widget.divisions! > 0) {
      final step = (widget.max - widget.min) / widget.divisions!;
      v = widget.min + ((v - widget.min) / step).round() * step;
    }
    widget.onChanged!(v.clamp(widget.min, widget.max));
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final enabled = widget._isEnabled;
    final clampedValue = widget.value.clamp(widget.min, widget.max);
    final t = (clampedValue - widget.min) / (widget.max - widget.min);
    const thumbRadius = 8.0;
    const trackHeight = 4.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0;
        final trackWidth = width - thumbRadius * 2;
        final thumbX = thumbRadius + t * trackWidth;

        return MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails d) => _emit(d.localPosition.dx - thumbRadius, trackWidth),
            onHorizontalDragUpdate: (DragUpdateDetails d) => _emit(d.localPosition.dx - thumbRadius, trackWidth),
            child: Opacity(
              opacity: enabled ? 1.0 : 0.5,
              child: SizedBox(
                width: width,
                height: widget.height,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // inactive track
                    Positioned(
                      left: thumbRadius,
                      right: thumbRadius,
                      child: Container(
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: theme.colors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(trackHeight),
                        ),
                      ),
                    ),
                    // active track
                    Positioned(
                      left: thumbRadius,
                      width: t * trackWidth,
                      child: Container(
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: theme.colors.primary,
                          borderRadius: BorderRadius.circular(trackHeight),
                        ),
                      ),
                    ),
                    // thumb
                    Positioned(
                      left: thumbX - thumbRadius,
                      child: Container(
                        width: thumbRadius * 2,
                        height: thumbRadius * 2,
                        decoration: BoxDecoration(
                          color: theme.colors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colors.primary, width: 2),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
