import 'package:flutter/material.dart' show InputBorder, InputDecoration, TextField, Tooltip;
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

  void _startEditing() {
    setState(() => _editing = true);
    _focus.requestFocus();
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
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
        onDoubleTap: _startEditing,
        onSecondaryTapDown: (details) => _showMenu(context, details.globalPosition),
        child: idle,
      );
      // An enclosing SailCard puts a SelectionArea over this, whose
      // double-click-to-select wins the gesture arena unless the subtree opts out.
      idle = SelectionContainer.disabled(child: idle);
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
