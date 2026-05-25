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

  const SailTooltip({
    super.key,
    required this.child,
    required this.message,
    this.position = SailTooltipPosition.auto,
    this.waitDuration = const Duration(milliseconds: 400),
    this.showDuration = const Duration(milliseconds: 1500),
    this.verticalOffset = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  State<SailTooltip> createState() => _SailTooltipState();
}

class _SailTooltipState extends State<SailTooltip> {
  OverlayEntry? _entry;
  Timer? _showTimer;
  Timer? _hideTimer;
  final LayerLink _link = LayerLink();

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _removeOverlay();
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
    _hideTimer = Timer(delay ?? const Duration(milliseconds: 80), _removeOverlay);
  }

  void _show() {
    if (_entry != null || !mounted) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    final overlayHeight = overlayBox?.size.height ?? 0;
    final topLeftGlobal = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);

    bool placeAbove;
    switch (widget.position) {
      case SailTooltipPosition.above:
        placeAbove = true;
        break;
      case SailTooltipPosition.below:
        placeAbove = false;
        break;
      case SailTooltipPosition.auto:
        placeAbove = topLeftGlobal.dy > overlayHeight - (topLeftGlobal.dy + size.height);
        break;
    }

    _entry = OverlayEntry(
      builder: (ctx) {
        final theme = SailTheme.of(context);
        final targetAnchor = placeAbove ? Alignment.topCenter : Alignment.bottomCenter;
        final followerAnchor = placeAbove ? Alignment.bottomCenter : Alignment.topCenter;
        final dy = placeAbove ? -widget.verticalOffset : widget.verticalOffset;
        return Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: targetAnchor,
            followerAnchor: followerAnchor,
            offset: Offset(0, dy),
            child: IgnorePointer(
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: theme.colors.popoverBackground,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SailText.primary12(widget.message),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_entry!);

    _hideTimer = Timer(widget.showDuration, _removeOverlay);
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
