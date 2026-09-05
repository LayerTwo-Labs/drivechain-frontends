import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// The keys the board offers: every printable ASCII character.
const String entropyKeyboardChars =
    r"""!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~""";

/// How many keys sit in one row.
const int entropyKeyboardColumns = 12;

/// How often a key repeats while the pointer rests on it.
const Duration entropyKeyRepeat = Duration(milliseconds: 50);

/// SailEntropyKeyboard turns pointer movement into text. The pointer types the
/// key it passes over, and that key repeats while the pointer rests on it.
/// The layout is dealt by the OS CSPRNG at open; Shuffle deals a new one.
///
/// [showKeys] draws the keys. Hidden keys still type, so both modes share one
/// sampler and one character stream.
class SailEntropyKeyboard extends StatefulWidget {
  final ValueChanged<String> onType;
  final bool showKeys;
  final bool enabled;

  /// hiddenHeight is the height of the board when it draws no keys.
  final double hiddenHeight;
  final String caption;
  final String? subCaption;

  const SailEntropyKeyboard({
    super.key,
    required this.onType,
    required this.caption,
    this.showKeys = false,
    this.enabled = true,
    this.hiddenHeight = 320,
    this.subCaption,
  });

  @override
  State<SailEntropyKeyboard> createState() => _SailEntropyKeyboardState();
}

class _SailEntropyKeyboardState extends State<SailEntropyKeyboard> {
  static const double _keyHeight = 24;
  static const double _keyGap = 2;
  static const double _padding = 8;
  static const double _border = 1;

  Timer? _repeat;
  String? _hovered;
  // Random.secure reads the OS CSPRNG, the Dart equal of Go crypto/rand.
  final Random _random = Random.secure();
  late final List<String> _layout = entropyKeyboardChars.split('')..shuffle(_random);

  int get _rows => (entropyKeyboardChars.length / entropyKeyboardColumns).ceil();

  @override
  void dispose() {
    _repeat?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(SailEntropyKeyboard old) {
    super.didUpdateWidget(old);
    if (!widget.enabled) {
      _stop();
    }
  }

  void _stop() {
    _repeat?.cancel();
    _repeat = null;
    if (_hovered != null) {
      setState(() => _hovered = null);
    }
  }

  double get _keysHeight => _rows * _keyHeight + (_rows - 1) * _keyGap;

  /// keyAt reads the key under one point. It answers null outside the keys.
  String? keyAt(Offset local, Size size) {
    final width = size.width - (_padding + _border) * 2;
    // A visible board types only where the keys are. A hidden one has no
    // caption to dodge, so its whole face maps to the same grid.
    final height = widget.showKeys ? _keysHeight : size.height - (_padding + _border) * 2;
    if (width <= 0 || height <= 0) {
      return null;
    }
    final x = local.dx - _padding - _border;
    final y = local.dy - _padding - _border;
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return null;
    }
    final column = (x / (width / entropyKeyboardColumns)).floor();
    final row = (y / (height / _rows)).floor();
    final index = row * entropyKeyboardColumns + column;
    if (index < 0 || index >= _layout.length) {
      return null;
    }
    return _layout[index];
  }

  // The pointer sits on the button during a press, so no key is hovered.
  void _shuffle() {
    setState(() {
      _layout.shuffle(_random);
      _hovered = null;
    });
  }

  void _hover(PointerHoverEvent event, Size size) {
    final key = keyAt(event.localPosition, size);
    if (key == null) {
      _stop();
      return;
    }
    if (key != _hovered) {
      setState(() => _hovered = key);
    }
    widget.onType(key);
    _repeat ??= Timer.periodic(entropyKeyRepeat, (_) {
      final held = _hovered;
      if (held == null) {
        return;
      }
      widget.onType(held);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final board = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.border, width: _border),
      ),
      child: widget.showKeys ? _keys(context) : _blank(context),
    );
    final face = widget.showKeys ? board : SizedBox(height: widget.hiddenHeight, child: board);

    if (!widget.enabled) {
      return Opacity(opacity: 0.5, child: face);
    }
    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        key: const Key('mouse-entropy-pad'),
        onHover: (event) => _hover(event, Size(constraints.maxWidth, widget.hiddenHeight)),
        onExit: (_) => _stop(),
        child: face,
      ),
    );
  }

  Widget _blank(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SailText.secondary13(widget.caption),
        if (widget.subCaption != null) ...[
          const SizedBox(height: 6),
          SailText.secondary12(widget.subCaption!),
        ],
      ],
    );
  }

  Widget _keys(BuildContext context) {
    final theme = SailTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < _rows; row++) ...[
          if (row > 0) const SizedBox(height: _keyGap),
          SizedBox(
            height: _keyHeight,
            child: Row(
              children: [
                for (var column = 0; column < entropyKeyboardColumns; column++)
                  Expanded(
                    child: _key(theme, row * entropyKeyboardColumns + column),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: SailText.secondary12(widget.caption)),
            if (widget.subCaption != null) ...[
              const SizedBox(width: 12),
              SailText.secondary12(widget.subCaption!),
            ],
            const SizedBox(width: 12),
            SailButton(
              label: 'Shuffle',
              icon: SailSVGAsset.shuffle,
              variant: ButtonVariant.secondary,
              small: true,
              onPressed: () async => _shuffle(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _key(SailThemeData theme, int index) {
    if (index >= entropyKeyboardChars.length) {
      return const SizedBox.shrink();
    }
    final char = _layout[index];
    final hovered = char == _hovered;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _keyGap / 2),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hovered ? theme.colors.orange : theme.colors.background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: SailText.primary13(
          char,
          monospace: true,
          color: hovered ? theme.colors.backgroundSecondary : null,
        ),
      ),
    );
  }
}
