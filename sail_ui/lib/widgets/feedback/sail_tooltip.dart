import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailTooltipPosition { above, below, auto }

class SailTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final SailTooltipPosition position;
  final Duration waitDuration;
  final Duration showDuration;
  final double verticalOffset;
  final EdgeInsets padding;
  final bool showArrow;

  const SailTooltip({
    super.key,
    required this.child,
    required this.message,
    this.position = SailTooltipPosition.auto,
    this.waitDuration = const Duration(milliseconds: 400),
    this.showDuration = const Duration(milliseconds: 1500),
    this.verticalOffset = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.showArrow = true,
  });

  @override
  State<SailTooltip> createState() => _SailTooltipState();
}

class _SailTooltipState extends State<SailTooltip> with SingleTickerProviderStateMixin {
  static const _arrowWidth = 10.0;
  static const _arrowHeight = 5.0;

  OverlayEntry? _entry;
  Timer? _showTimer;
  Timer? _hideTimer;
  final LayerLink _link = LayerLink();
  late final AnimationController _controller;
  bool _placeAbove = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _controller.dispose();
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  void _scheduleShow() {
    _hideTimer?.cancel();
    _showTimer?.cancel();
    _showTimer = Timer(widget.waitDuration, _show);
  }

  void _scheduleHide({Duration? delay}) {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _hideTimer = Timer(delay ?? const Duration(milliseconds: 80), _hide);
  }

  void _hide() {
    if (_entry == null) return;
    _controller.reverse().whenComplete(() {
      // A re-show during the fade-out keeps the overlay alive.
      if (_controller.status == AnimationStatus.dismissed) _removeOverlay();
    });
  }

  void _show() {
    if (!mounted) return;
    if (_entry != null) {
      _controller.forward();
      return;
    }
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    final overlayHeight = overlayBox?.size.height ?? 0;
    final topLeftGlobal = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);

    switch (widget.position) {
      case SailTooltipPosition.above:
        _placeAbove = true;
      case SailTooltipPosition.below:
        _placeAbove = false;
      case SailTooltipPosition.auto:
        _placeAbove = topLeftGlobal.dy > overlayHeight - (topLeftGlobal.dy + size.height);
    }

    _entry = OverlayEntry(builder: _buildOverlay);
    overlay.insert(_entry!);
    _controller.forward(from: 0);

    _hideTimer = Timer(widget.showDuration, _hide);
  }

  Widget _buildOverlay(BuildContext ctx) {
    final theme = SailTheme.of(context);
    final override = theme.chrome.tooltipBackground;
    final background = override ?? theme.colors.text;
    final foreground = override != null ? theme.colors.text : theme.colors.background;

    final bubble = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: theme.chrome.beveled
            ? BorderRadius.zero
            : theme.chrome.terminalStyle
            ? theme.chrome.radiusSmall
            : BorderRadius.circular(6),
        border: theme.chrome.beveled
            ? Border.all(color: theme.colors.text, width: 1)
            : override != null
            ? Border.all(color: theme.colors.border)
            : null,
        boxShadow: theme.chrome.terminalStyle
            ? null
            : [BoxShadow(color: theme.colors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: SailText.primary12(
        widget.message,
        color: foreground,
        monospace: theme.chrome.terminalStyle,
        overflow: TextOverflow.visible,
      ),
    );

    final arrow = CustomPaint(
      size: const Size(_arrowWidth, _arrowHeight),
      painter: _ArrowPainter(color: background, pointsDown: _placeAbove),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _placeAbove ? [bubble, if (widget.showArrow) arrow] : [if (widget.showArrow) arrow, bubble],
    );

    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: _placeAbove ? Alignment.topCenter : Alignment.bottomCenter,
        followerAnchor: _placeAbove ? Alignment.bottomCenter : Alignment.topCenter,
        offset: Offset(0, _placeAbove ? -widget.verticalOffset : widget.verticalOffset),
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeOut.transform(_controller.value);
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  // Slides out of the trigger, so the tooltip reads as coming from it.
                  offset: Offset(0, (_placeAbove ? 8 : -8) * (1 - t)),
                  child: Transform.scale(
                    scale: 0.95 + 0.05 * t,
                    alignment: _placeAbove ? Alignment.bottomCenter : Alignment.topCenter,
                    child: child,
                  ),
                ),
              );
            },
            child: content,
          ),
        ),
      ),
    );
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _scheduleShow(),
        onExit: (_) => _scheduleHide(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: _show,
          onLongPressEnd: (_) => _scheduleHide(),
          child: widget.child,
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool pointsDown;

  const _ArrowPainter({required this.color, required this.pointsDown});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    if (pointsDown) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width / 2, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color || old.pointsDown != pointsDown;
}
