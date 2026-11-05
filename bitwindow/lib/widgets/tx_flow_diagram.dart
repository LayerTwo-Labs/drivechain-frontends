import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// What a band in the flow diagram carries. It sets the band color.
enum FlowKind { input, payment, change, fee }

/// One band in the flow diagram, in satoshis.
class FlowSlot {
  final int sats;
  final FlowKind kind;

  const FlowSlot({required this.sats, required this.kind});

  bool get isFee => kind == FlowKind.fee;
}

/// A mempool.space-style sankey: input caps on the left, a trunk, then a
/// fan into the outputs, with a hairline for the fee. Widths are
/// proportional to sats; a dust output still renders as a visible line.
class TxFlowDiagram extends StatelessWidget {
  final List<FlowSlot> inputs;
  final List<FlowSlot> outputs;

  const TxFlowDiagram({
    super.key,
    required this.inputs,
    required this.outputs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(SailStyleValues.padding20),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.divider),
      ),
      child: TxFlowPlot(inputs: inputs, outputs: outputs),
    );
  }
}

/// The sankey alone, with no frame. It fills its parent.
class TxFlowPlot extends StatelessWidget {
  final List<FlowSlot> inputs;
  final List<FlowSlot> outputs;

  const TxFlowPlot({super.key, required this.inputs, required this.outputs});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: SankeyPainter(inputs: inputs, outputs: outputs, colors: FlowColors.of(context)),
    );
  }
}

/// The band color for each [FlowKind], from the theme.
class FlowColors {
  final Color input;
  final Color payment;
  final Color change;
  final Color fee;

  const FlowColors({required this.input, required this.payment, required this.change, required this.fee});

  factory FlowColors.of(BuildContext context) {
    final colors = context.sailTheme.colors;
    return FlowColors(
      input: colors.textTertiary.withValues(alpha: 0.35),
      payment: colors.orange.withValues(alpha: 0.85),
      change: colors.success.withValues(alpha: 0.85),
      fee: colors.textTertiary,
    );
  }

  Color forKind(FlowKind kind) => switch (kind) {
    FlowKind.input => input,
    FlowKind.payment => payment,
    FlowKind.change => change,
    FlowKind.fee => fee,
  };

  @override
  bool operator ==(Object other) =>
      other is FlowColors &&
      other.input == input &&
      other.payment == payment &&
      other.change == change &&
      other.fee == fee;

  @override
  int get hashCode => Object.hash(input, payment, change, fee);
}

/// The vertical bands of [slots] in a plot of [height] pixels: the same
/// layout the painter draws, so labels can sit at each band center.
List<({double top, double height})> flowBandLayout(List<FlowSlot> slots, double height) {
  if (slots.isEmpty) {
    return const [];
  }
  final heights = SankeyPainter.bandHeights(slots, height);
  var top = SankeyPainter.stackTop(heights, height);
  final bands = <({double top, double height})>[];
  for (final h in heights) {
    bands.add((top: top, height: h));
    top += h + SankeyPainter.gap;
  }
  return bands;
}

class SankeyPainter extends CustomPainter {
  final List<FlowSlot> inputs;
  final List<FlowSlot> outputs;
  final FlowColors colors;

  static const _capWidth = 90.0;
  static const _arrowWidth = 24.0;
  static const gap = 10.0;
  static const _minBand = 2.0;

  SankeyPainter({required this.inputs, required this.outputs, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (inputs.isEmpty || outputs.isEmpty) {
      return;
    }

    final paint = Paint()..color = colors.input;

    final inHeights = bandHeights(inputs, size.height);
    final outHeights = bandHeights(outputs, size.height);
    final trunkHeight = inHeights.reduce((a, b) => a + b);
    final trunkTop = (size.height - trunkHeight) / 2;

    // A narrow plot puts the trunk against the input caps, to keep room for the split bands.
    final compact = size.width < 500;
    final capRight = compact ? size.width * 0.29 : _capWidth;
    final trunkLeft = compact ? capRight : size.width * 0.45;
    final trunkRight = size.width * (compact ? 0.5 : 0.55);
    final outCapLeft = compact ? size.width * 0.82 : size.width - _capWidth - _arrowWidth;

    // Input caps and their merge bands into the trunk.
    var slotTop = stackTop(inHeights, size.height);
    var trunkY = trunkTop;
    for (var i = 0; i < inputs.length; i++) {
      final h = inHeights[i];
      canvas.drawPath(_inputCap(slotTop, h, capRight), paint);
      _band(canvas, paint, capRight, slotTop, h, trunkLeft, trunkY, h);
      slotTop += h + gap;
      trunkY += h;
    }

    // The trunk.
    canvas.drawRect(Rect.fromLTWH(trunkLeft, trunkTop, trunkRight - trunkLeft, trunkHeight), paint);

    // Split bands out of the trunk, then the output caps.
    slotTop = stackTop(outHeights, size.height);
    trunkY = trunkTop;
    for (var i = 0; i < outputs.length; i++) {
      final h = outHeights[i];
      final outPaint = Paint()..color = colors.forKind(outputs[i].kind);
      _band(canvas, outPaint, trunkRight, trunkY, h, outCapLeft, slotTop, h);
      if (!outputs[i].isFee) {
        canvas.drawPath(_outputCap(slotTop, h, outCapLeft, size.width), outPaint);
      } else {
        canvas.drawRect(Rect.fromLTWH(outCapLeft, slotTop, size.width - outCapLeft, h), outPaint);
      }
      slotTop += h + gap;
      trunkY += h;
    }
  }

  /// Proportional heights with a floor, so dust and the fee stay visible.
  static List<double> bandHeights(List<FlowSlot> slots, double available) {
    final usable = available - gap * (slots.length - 1);
    final total = slots.fold<int>(0, (sum, s) => sum + max(s.sats, 0));
    if (total <= 0) {
      return List.filled(slots.length, max(usable / slots.length, _minBand));
    }
    return slots.map((s) => max(usable * s.sats / total, _minBand)).toList();
  }

  static double stackTop(List<double> heights, double available) {
    final total = heights.reduce((a, b) => a + b) + gap * (heights.length - 1);
    return (available - total) / 2;
  }

  /// A left cap with a notched arrow tip pointing right.
  Path _inputCap(double top, double h, double right) {
    final tip = min(h / 2, 18.0);
    return Path()
      ..moveTo(0, top)
      ..lineTo(right - tip, top)
      ..lineTo(right, top + h / 2)
      ..lineTo(right - tip, top + h)
      ..lineTo(0, top + h)
      ..close();
  }

  /// A right cap ending in an arrow tip.
  Path _outputCap(double top, double h, double left, double right) {
    final tip = min(h / 2, _arrowWidth);
    return Path()
      ..moveTo(left, top)
      ..lineTo(right - tip, top)
      ..lineTo(right, top + h / 2)
      ..lineTo(right - tip, top + h)
      ..lineTo(left, top + h)
      ..close();
  }

  /// A smooth band from one vertical slot to another.
  void _band(
    Canvas canvas,
    Paint paint,
    double x0,
    double y0,
    double h0,
    double x1,
    double y1,
    double h1,
  ) {
    final cx = (x0 + x1) / 2;
    final path = Path()
      ..moveTo(x0, y0)
      ..cubicTo(cx, y0, cx, y1, x1, y1)
      ..lineTo(x1, y1 + h1)
      ..cubicTo(cx, y1 + h1, cx, y0 + h0, x0, y0 + h0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SankeyPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        !listEquals(oldDelegate.inputs.map((s) => s.kind).toList(), inputs.map((s) => s.kind).toList()) ||
        !listEquals(oldDelegate.outputs.map((s) => s.kind).toList(), outputs.map((s) => s.kind).toList()) ||
        !listEquals(oldDelegate.inputs.map((s) => s.sats).toList(), inputs.map((s) => s.sats).toList()) ||
        !listEquals(oldDelegate.outputs.map((s) => s.sats).toList(), outputs.map((s) => s.sats).toList());
  }
}

/// A small colored tag, such as "payment" or "change".
class FlowChip extends StatelessWidget {
  final String label;
  final Color color;

  const FlowChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SailText.secondary12(label, color: color),
    );
  }
}
