import 'package:flutter/widgets.dart';

/// Optional external controller for [SailCollapsible].
class SailCollapsibleController extends ChangeNotifier {
  bool _open;

  SailCollapsibleController({bool initiallyOpen = false}) : _open = initiallyOpen;

  bool get isOpen => _open;

  void open() {
    if (_open) return;
    _open = true;
    notifyListeners();
  }

  void close() {
    if (!_open) return;
    _open = false;
    notifyListeners();
  }

  void toggle() {
    _open = !_open;
    notifyListeners();
  }
}

/// Foundation expand/collapse animator.
///
/// Pass either [open] (controlled) or a [controller] (uncontrolled).
/// [trigger] is rendered above the [child]; tapping it toggles when no
/// [controller] is provided and the parent has no [onOpenChanged].
class SailCollapsible extends StatefulWidget {
  final Widget child;
  final Widget? trigger;
  final SailCollapsibleController? controller;
  final bool? open;
  final ValueChanged<bool>? onOpenChanged;
  final Duration duration;
  final Curve curve;

  const SailCollapsible({
    super.key,
    required this.child,
    this.trigger,
    this.controller,
    this.open,
    this.onOpenChanged,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOut,
  }) : assert(
         !(open != null && controller != null),
         'Provide either open or controller, not both',
       );

  @override
  State<SailCollapsible> createState() => _SailCollapsibleState();
}

class _SailCollapsibleState extends State<SailCollapsible> {
  late SailCollapsibleController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = SailCollapsibleController(initiallyOpen: widget.open ?? false);
      _ownsController = true;
    }
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SailCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onControllerChanged);
      if (_ownsController) _controller.dispose();
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = SailCollapsibleController(initiallyOpen: widget.open ?? false);
        _ownsController = true;
      }
      _controller.addListener(_onControllerChanged);
    }
    if (widget.open != null && widget.open != _controller.isOpen) {
      if (widget.open!) {
        _controller.open();
      } else {
        _controller.close();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _handleTriggerTap() {
    if (widget.open != null) {
      widget.onOpenChanged?.call(!_controller.isOpen);
    } else {
      _controller.toggle();
      widget.onOpenChanged?.call(_controller.isOpen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = AnimatedSize(
      duration: widget.duration,
      curve: widget.curve,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: _controller.isOpen ? widget.child : const SizedBox(width: double.infinity, height: 0),
      ),
    );

    if (widget.trigger == null) return body;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTriggerTap,
          child: widget.trigger!,
        ),
        body,
      ],
    );
  }
}
