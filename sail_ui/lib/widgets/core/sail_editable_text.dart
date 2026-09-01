import 'package:flutter/material.dart' show InputBorder, InputDecoration, TextField, Tooltip;
import 'package:flutter/gestures.dart' show kDoubleTapSlop, kDoubleTapTimeout, kDoubleTapTouchSlop, kPrimaryButton;
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Text that edits in place. A pencil starts editing; enter or tapping away commits.
class SailEditableText extends StatefulWidget {
  final String value;
  final ValueChanged<String> onSubmitted;
  final TextStyle? style;
  final String? tooltip;
  final double minWidth;

  /// Shows the pencil. Turn it off where a double-click is the way in.
  final bool showPencil;

  /// Starts editing on a double-click or a right-click. Single taps still pass
  /// through, so a tab underneath keeps its own tap.
  final bool editOnDoubleTap;

  /// Fills the available width and wraps onto more lines. For long values like
  /// an xpub, which overflow the row when sized to their content.
  final bool wrap;

  const SailEditableText({
    super.key,
    required this.value,
    required this.onSubmitted,
    this.style,
    this.tooltip,
    this.minWidth = 24,
    this.showPencil = true,
    this.editOnDoubleTap = false,
    this.wrap = false,
  });

  @override
  State<SailEditableText> createState() => _SailEditableTextState();
}

class _SailEditableTextState extends State<SailEditableText> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);
  final FocusNode _focus = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus && _editing) {
        _commit();
      }
    });
  }

  Duration? _lastTapTime;
  Offset? _lastTapPosition;

  int? _pressPointer;
  Offset? _pressPosition;
  bool _pressDragged = false;

  @override
  void didUpdateWidget(SailEditableText old) {
    super.didUpdateWidget(old);
    if (!_editing && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// An enclosing SelectionArea installs a pan recognizer above this widget.
  /// That recognizer wins the gesture arena, so a double-tap recognizer here
  /// never fires. A Listener reads raw pointer events whoever wins the arena,
  /// so the two clicks are counted here instead.
  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) {
      return;
    }
    _pressPointer = event.pointer;
    _pressPosition = event.position;
    _pressDragged = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    final from = _pressPosition;
    if (event.pointer != _pressPointer || _pressDragged || from == null) {
      return;
    }
    if ((event.position - from).distance > kDoubleTapTouchSlop) {
      _pressDragged = true;
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer == _pressPointer) {
      _forgetPress();
    }
  }

  /// A press counts as a click only when it ends where it started. A press that
  /// drags selects text, and a canceled press never reaches the user at all.
  /// Two clicks close in time and in place open the rename.
  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _pressPointer) {
      return;
    }
    final dragged = _pressDragged;
    _forgetPress();
    if (dragged) {
      _lastTapTime = null;
      _lastTapPosition = null;
      return;
    }

    final previousTime = _lastTapTime;
    final previousPosition = _lastTapPosition;
    _lastTapTime = event.timeStamp;
    _lastTapPosition = event.position;

    if (previousTime == null || previousPosition == null) {
      return;
    }
    if (event.timeStamp - previousTime > kDoubleTapTimeout) {
      return;
    }
    if ((event.position - previousPosition).distance > kDoubleTapSlop) {
      return;
    }

    _lastTapTime = null;
    _lastTapPosition = null;
    _startEditing();
  }

  void _forgetPress() {
    _pressPointer = null;
    _pressPosition = null;
    _pressDragged = false;
  }

  void _startEditing() {
    setState(() => _editing = true);
    // A SelectionArea above this takes focus when its own recognizer wins, which
    // happens after this click. Commit-on-focus-loss would then close edit mode
    // again, so the field claims focus once the frame settles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_editing) {
        return;
      }
      _focus.requestFocus();
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    });
  }

  // An empty name would leave the row with nothing to click, so it reverts.
  void _commit() {
    final next = _controller.text.trim();
    setState(() => _editing = false);
    if (next.isEmpty) {
      _controller.text = widget.value;
      return;
    }
    _controller.text = next;
    if (next != widget.value) {
      widget.onSubmitted(next);
    }
  }

  void _showMenu(BuildContext context, Offset position) {
    showSailMenu(
      context: context,
      preferredAnchorPoint: position,
      menu: SailMenu(
        width: 180,
        items: [
          SailMenuItem(
            onSelected: () {
              Navigator.of(context).pop();
              _startEditing();
            },
            child: SailText.primary12(widget.tooltip ?? 'Edit label'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final style = widget.style ?? SailStyleValues.fifteen.copyWith(color: theme.colors.text);

    final input = TextField(
      controller: _controller,
      focusNode: _focus,
      style: style,
      cursorColor: theme.colors.primary,
      maxLines: widget.wrap ? null : 1,
      decoration: const InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onSubmitted: (_) => _commit(),
    );

    final field = widget.wrap
        ? input
        : ConstrainedBox(
            constraints: BoxConstraints(minWidth: widget.minWidth),
            child: IntrinsicWidth(child: input),
          );

    Widget idle = IgnorePointer(child: field);
    if (widget.editOnDoubleTap) {
      idle = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapDown: (details) => _showMenu(context, details.globalPosition),
        child: idle,
      );
      idle = SelectionContainer.disabled(child: idle);
      idle = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: idle,
      );
    }

    final content = _editing ? field : idle;

    return Row(
      mainAxisSize: widget.wrap ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.wrap ? Expanded(child: content) : content,
        if (widget.showPencil) ...[
          const SizedBox(width: 6),
          SailTappable(
            onTap: () async => _startEditing(),
            child: Tooltip(
              message: widget.tooltip ?? 'Rename',
              child: SailSVG.icon(
                SailSVGAsset.iconPen,
                width: 12,
                color: _editing ? theme.colors.primary : theme.colors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
