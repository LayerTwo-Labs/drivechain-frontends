import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// The keys the board offers: printable ASCII from ! to z, 90 characters.
const String entropyKeyboardChars =
    r"""!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz""";

/// How many keys sit in one row.
const int entropyKeyboardColumns = 10;

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
  static const double _maxKeySize = 44;
  static const double _keyGap = 4;
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

  /// The grid takes its full size when the board is wide, and it scales the
  /// square keys down inside a narrow board.
  double _gridWidthFor(double innerWidth) {
    final full = entropyKeyboardColumns * _maxKeySize + (entropyKeyboardColumns - 1) * _keyGap;
    return min(full, innerWidth);
  }

  double _keySizeFor(double gridWidth) =>
      max(1, (gridWidth - (entropyKeyboardColumns - 1) * _keyGap) / entropyKeyboardColumns);

  double _keysHeightFor(double gridWidth) {
    final key = _keySizeFor(gridWidth);
    return _rows * key + (_rows - 1) * _keyGap;
  }

  /// keyAt reads the key under one point. It answers null outside the keys.
  String? keyAt(Offset local, Size size) {
    final innerWidth = size.width - (_padding + _border) * 2;
    var x = local.dx - _padding - _border;
    final y = local.dy - _padding - _border;
    var width = innerWidth;
    // A visible board centers a square grid and types only on it. A hidden
    // one has no keys to dodge, so its whole face maps to the same grid.
    var height = size.height - (_padding + _border) * 2;
    if (widget.showKeys) {
      final gridWidth = _gridWidthFor(innerWidth);
      x -= (innerWidth - gridWidth) / 2;
      width = gridWidth;
      height = _keysHeightFor(gridWidth);
    }
    if (width <= 0 || height <= 0 || x < 0 || y < 0 || x >= width || y >= height) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = _gridWidthFor(constraints.maxWidth);
        final keySize = _keySizeFor(gridWidth);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SizedBox(
                width: gridWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var row = 0; row < _rows; row++) ...[
                      if (row > 0) const SizedBox(height: _keyGap),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var column = 0; column < entropyKeyboardColumns; column++)
                            _key(theme, keySize, row * entropyKeyboardColumns + column),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
                  disabled: !widget.enabled,
                  onPressed: () async => _shuffle(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _key(SailThemeData theme, double keySize, int index) {
    final char = _layout[index];
    final hovered = char == _hovered;
    return Container(
      width: keySize,
      height: keySize,
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
    );
  }
}
