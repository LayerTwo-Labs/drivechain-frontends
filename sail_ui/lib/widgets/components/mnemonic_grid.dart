import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// A numbered BIP39 phrase. Words read down each column, so word N stays in the
/// same place whatever the column count.
class SailMnemonicGrid extends StatefulWidget {
  final List<String> words;
  final int columns;

  /// Per-word bit strings, shown under each word. Must match [words] in length.
  final List<String>? bits;

  /// One controller per word turns the grid into inputs. Its length sets the
  /// cell count, and [words] is ignored.
  final List<TextEditingController>? controllers;
  final void Function(int index, String value)? onChanged;

  /// Called when the last word is submitted.
  final VoidCallback? onCompleted;

  const SailMnemonicGrid({
    super.key,
    this.words = const [],
    this.columns = 3,
    this.bits,
    this.controllers,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<SailMnemonicGrid> createState() => _SailMnemonicGridState();
}

class _SailMnemonicGridState extends State<SailMnemonicGrid> {
  List<FocusNode> _nodes = [];

  int get _count => widget.controllers?.length ?? widget.words.length;

  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(SailMnemonicGrid old) {
    super.didUpdateWidget(old);
    if (_nodes.length != _count) {
      _syncNodes();
    }
  }

  void _syncNodes() {
    for (final n in _nodes) {
      n.dispose();
    }
    _nodes = widget.controllers == null ? [] : List.generate(_count, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _advance(int index) {
    if (index + 1 < _nodes.length) {
      _nodes[index + 1].requestFocus();
      return;
    }
    _nodes[index].unfocus();
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return const SizedBox.shrink();
    }
    final columns = widget.columns;
    final rows = (_count + columns - 1) ~/ columns;
    final showBits = widget.bits != null && widget.bits!.length == widget.words.length;

    // Words read down the columns, so tree order is not word order. Number the
    // cells so tab follows 1, 2, 3 rather than the layout.
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int r = 0; r < rows; r++)
            Padding(
              padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int c = 0; c < columns; c++) ...[
                    if (c > 0) const SizedBox(width: 16),
                    Expanded(child: _cell(context, c * rows + r, showBits)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, int index, bool showBits) {
    if (index >= _count) {
      return const SizedBox.shrink();
    }
    final theme = SailTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          child: SailText.secondary13('${index + 1}.', textAlign: TextAlign.right),
        ),
        const SizedBox(width: 8),
        if (widget.controllers != null)
          Expanded(
            child: FocusTraversalOrder(
              order: NumericFocusOrder(index.toDouble()),
              child: SailTextField(
                controller: widget.controllers![index],
                focusNode: _nodes[index],
                hintText: '',
                size: TextFieldSize.small,
                onChanged: (v) => widget.onChanged?.call(index, v),
                onSubmitted: (_) => _advance(index),
              ),
            ),
          )
        else
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13(widget.words[index]),
                  if (showBits) SailText.secondary12(widget.bits![index], monospace: true),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
