import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double rangeStart;
  final double rangeEnd;
  final void Function(double start, double end)? onRangeChanged;
  final bool isRange;
  final double min;
  final double max;
  final int? divisions;
  final bool disabled;
  final double height;

  /// Draws the snap points. Snapping still follows [divisions] either way.
  final bool showSteps;

  /// Caption below the track, e.g. "Require 2 signatures to move funds".
  final String? label;

  const SailSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.disabled = false,
    this.height = 20,
    this.showSteps = true,
    this.label,
  }) : assert(max > min),
       isRange = false,
       rangeStart = 0,
       rangeEnd = 0,
       onRangeChanged = null;

  const SailSlider.range({
    super.key,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onRangeChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.disabled = false,
    this.height = 20,
    this.showSteps = true,
    this.label,
  }) : assert(max > min),
       isRange = true,
       value = 0,
       onChanged = null;

  bool get _isEnabled => !disabled && (isRange ? onRangeChanged != null : onChanged != null);

  @override
  State<SailSlider> createState() => _SailSliderState();
}

class _SailSliderState extends State<SailSlider> {
  // Which thumb the current gesture owns, so a drag past the other one cannot
  // hand it over mid-drag.
  int? _held;

  double _snap(double v) {
    final divisions = widget.divisions;
    if (divisions == null || divisions <= 0) {
      return v.clamp(widget.min, widget.max);
    }
    final step = (widget.max - widget.min) / divisions;
    final snapped = widget.min + ((v - widget.min) / step).round() * step;
    return snapped.clamp(widget.min, widget.max);
  }

  double _valueAt(double localX, double trackWidth) {
    final clamped = localX.clamp(0.0, trackWidth);
    final t = trackWidth == 0 ? 0.0 : clamped / trackWidth;
    return _snap(widget.min + t * (widget.max - widget.min));
  }

  void _emit(double localX, double trackWidth) {
    if (!widget._isEnabled) {
      return;
    }
    final v = _valueAt(localX, trackWidth);
    if (!widget.isRange) {
      widget.onChanged!(v);
      return;
    }
    final held = _held ?? _nearestThumb(v);
    if (held == 0) {
      widget.onRangeChanged!(v > widget.rangeEnd ? widget.rangeEnd : v, widget.rangeEnd);
    } else {
      widget.onRangeChanged!(widget.rangeStart, v < widget.rangeStart ? widget.rangeStart : v);
    }
  }

  // At start == end both thumbs sit together, so the tie goes to whichever one
  // the gesture is heading for; otherwise the range could never be reopened.
  int _nearestThumb(double v) {
    final toStart = (v - widget.rangeStart).abs();
    final toEnd = (widget.rangeEnd - v).abs();
    if (toStart == toEnd) {
      return v >= widget.rangeEnd ? 1 : 0;
    }
    return toStart < toEnd ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final terminal = theme.chrome.terminalStyle;
    final enabled = widget._isEnabled;
    final thumbRadius = terminal ? 6.0 : 10.0;
    final trackHeight = terminal ? 4.0 : 8.0;
    final tickRadius = terminal ? 1.5 : 2.0;

    final span = widget.max - widget.min;
    final tStart = widget.isRange ? (widget.rangeStart.clamp(widget.min, widget.max) - widget.min) / span : 0.0;
    final tEnd = widget.isRange
        ? (widget.rangeEnd.clamp(widget.min, widget.max) - widget.min) / span
        : (widget.value.clamp(widget.min, widget.max) - widget.min) / span;

    final track = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0;
        final trackWidth = width - thumbRadius * 2;

        return MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _emit(d.localPosition.dx - thumbRadius, trackWidth),
            onHorizontalDragStart: (d) {
              if (!widget.isRange) {
                return;
              }
              _held = _nearestThumb(_valueAt(d.localPosition.dx - thumbRadius, trackWidth));
            },
            onHorizontalDragUpdate: (d) => _emit(d.localPosition.dx - thumbRadius, trackWidth),
            onHorizontalDragEnd: (_) => _held = null,
            child: Opacity(
              opacity: enabled ? 1.0 : 0.5,
              child: SizedBox(
                width: width,
                height: widget.height,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: thumbRadius,
                      right: thumbRadius,
                      child: Container(
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: theme.colors.backgroundSecondary,
                          borderRadius: terminal ? BorderRadius.circular(2) : BorderRadius.circular(trackHeight),
                        ),
                      ),
                    ),
                    Positioned(
                      left: thumbRadius + tStart * trackWidth,
                      width: (tEnd - tStart) * trackWidth,
                      child: Container(
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: theme.colors.primary,
                          borderRadius: terminal ? BorderRadius.circular(2) : BorderRadius.circular(trackHeight),
                        ),
                      ),
                    ),
                    if (widget.showSteps && widget.divisions != null && widget.divisions! > 0)
                      for (int i = 0; i <= widget.divisions!; i++)
                        Positioned(
                          left: thumbRadius + (i / widget.divisions!) * trackWidth - tickRadius,
                          child: Container(
                            width: tickRadius * 2,
                            height: tickRadius * 2,
                            decoration: BoxDecoration(
                              color: (i / widget.divisions!) >= tStart && (i / widget.divisions!) <= tEnd
                                  ? theme.colors.background
                                  : theme.colors.primary,
                              borderRadius: terminal ? BorderRadius.circular(1) : null,
                              shape: terminal ? BoxShape.rectangle : BoxShape.circle,
                            ),
                          ),
                        ),
                    if (widget.isRange) _thumb(context, thumbRadius, tStart, trackWidth, terminal),
                    _thumb(context, thumbRadius, tEnd, trackWidth, terminal),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.label == null) {
      return track;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        track,
        const SizedBox(height: SailStyleValues.padding08),
        SailText.secondary13(widget.label!),
      ],
    );
  }

  Widget _thumb(BuildContext context, double radius, double t, double trackWidth, bool terminal) {
    final theme = SailTheme.of(context);
    return Positioned(
      left: t * trackWidth,
      child: terminal
          ? Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                color: theme.colors.primary,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: theme.colors.outlineButtonBorder, width: 1),
              ),
            )
          : Container(
              width: radius * 2,
              height: radius * 2,
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
    );
  }
}
