import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailPopoverAlignment { start, center, end }

enum SailPopoverSide { top, bottom, left, right }

class SailPopoverController extends ChangeNotifier {
  bool _open = false;
  bool get isOpen => _open;

  void show() {
    if (_open) return;
    _open = true;
    notifyListeners();
  }

  void hide() {
    if (!_open) return;
    _open = false;
    notifyListeners();
  }

  void toggle() {
    _open = !_open;
    notifyListeners();
  }
}

class SailPopover extends StatefulWidget {
  /// The trigger element. Tapping it toggles the popover unless [controller]
  /// is non-null, in which case the consumer drives visibility.
  final Widget child;

  /// The floating content.
  final Widget popover;

  final SailPopoverController? controller;
  final SailPopoverSide side;
  final SailPopoverAlignment alignment;
  final double offset;

  /// Tap outside dismisses the popover.
  final bool barrierDismissible;

  const SailPopover({
    super.key,
    required this.child,
    required this.popover,
    this.controller,
    this.side = SailPopoverSide.bottom,
    this.alignment = SailPopoverAlignment.start,
    this.offset = 4,
    this.barrierDismissible = true,
  });

  @override
  State<SailPopover> createState() => _SailPopoverState();
}

class _SailPopoverState extends State<SailPopover> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  late SailPopoverController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SailPopoverController();
    _ownsController = widget.controller == null;
    _controller.addListener(_sync);
    _sync();
  }

  @override
  void didUpdateWidget(covariant SailPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_sync);
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? SailPopoverController();
      _ownsController = widget.controller == null;
      _controller.addListener(_sync);
      _sync();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    if (_controller.isOpen) {
      if (!_portal.isShowing) _portal.show();
    } else {
      if (_portal.isShowing) _portal.hide();
    }
  }

  void _toggleFromTap() {
    _controller.toggle();
  }

  Alignment _targetAnchor() {
    switch (widget.side) {
      case SailPopoverSide.bottom:
        switch (widget.alignment) {
          case SailPopoverAlignment.start:
            return Alignment.bottomLeft;
          case SailPopoverAlignment.center:
            return Alignment.bottomCenter;
          case SailPopoverAlignment.end:
            return Alignment.bottomRight;
        }
      case SailPopoverSide.top:
        switch (widget.alignment) {
          case SailPopoverAlignment.start:
            return Alignment.topLeft;
          case SailPopoverAlignment.center:
            return Alignment.topCenter;
          case SailPopoverAlignment.end:
            return Alignment.topRight;
        }
      case SailPopoverSide.left:
        switch (widget.alignment) {
          case SailPopoverAlignment.start:
            return Alignment.topLeft;
          case SailPopoverAlignment.center:
            return Alignment.centerLeft;
          case SailPopoverAlignment.end:
            return Alignment.bottomLeft;
        }
      case SailPopoverSide.right:
        switch (widget.alignment) {
          case SailPopoverAlignment.start:
            return Alignment.topRight;
          case SailPopoverAlignment.center:
            return Alignment.centerRight;
          case SailPopoverAlignment.end:
            return Alignment.bottomRight;
        }
    }
  }

  Alignment _followerAnchor() {
    switch (widget.side) {
      case SailPopoverSide.bottom:
        switch (widget.alignment) {
          case SailPopoverAlignment.start:
            return Alignment.topLeft;
          case SailPopoverAlignment.center:
            return Alignment.topCenter;
          case SailPopoverAlignment.end:
            return Alignment.topRight;
        }
      case SailPopoverSide.top:
        switch (widget.alignment) {
          case SailPopoverAlignment.start:
            return Alignment.bottomLeft;
          case SailPopoverAlignment.center:
            return Alignment.bottomCenter;
          case SailPopoverAlignment.end:
            return Alignment.bottomRight;
        }
      case SailPopoverSide.left:
        switch (widget.alignment) {
          case SailPopoverAlignment.start:
            return Alignment.topRight;
          case SailPopoverAlignment.center:
            return Alignment.centerRight;
          case SailPopoverAlignment.end:
            return Alignment.bottomRight;
        }
      case SailPopoverSide.right:
        switch (widget.alignment) {
          case SailPopoverAlignment.start:
            return Alignment.topLeft;
          case SailPopoverAlignment.center:
            return Alignment.centerLeft;
          case SailPopoverAlignment.end:
            return Alignment.bottomLeft;
        }
    }
  }

  Offset _offset() {
    switch (widget.side) {
      case SailPopoverSide.bottom:
        return Offset(0, widget.offset);
      case SailPopoverSide.top:
        return Offset(0, -widget.offset);
      case SailPopoverSide.left:
        return Offset(-widget.offset, 0);
      case SailPopoverSide.right:
        return Offset(widget.offset, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (ctx) {
          return Stack(
            children: [
              if (widget.barrierDismissible)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _controller.hide,
                  ),
                ),
              Positioned(
                left: 0,
                top: 0,
                child: CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  targetAnchor: _targetAnchor(),
                  followerAnchor: _followerAnchor(),
                  offset: _offset(),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.popoverBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colors.shadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: widget.popover,
                  ),
                ),
              ),
            ],
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleFromTap,
          child: widget.child,
        ),
      ),
    );
  }
}
