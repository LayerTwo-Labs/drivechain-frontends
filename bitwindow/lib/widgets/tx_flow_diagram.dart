import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// One band in the flow diagram, in satoshis.
class FlowSlot {
  final int sats;
  final bool isFee;

  const FlowSlot({required this.sats, this.isFee = false});
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
      child: CustomPaint(
        size: Size.infinite,
        painter: _SankeyPainter(inputs: inputs, outputs: outputs),
      ),
    );
  }
}

class _SankeyPainter extends CustomPainter {
  final List<FlowSlot> inputs;
  final List<FlowSlot> outputs;

  static const _gradientStart = Color(0xFF8B5CF6);
  static const _gradientEnd = Color(0xFF3B82F6);
  static const _capWidth = 90.0;
  static const _arrowWidth = 24.0;
  static const _gap = 10.0;
  static const _minBand = 2.0;

  _SankeyPainter({required this.inputs, required this.outputs});

  @override
  void paint(Canvas canvas, Size size) {
    if (inputs.isEmpty || outputs.isEmpty) {
      return;
    }

    final shader = LinearGradient(
      colors: const [_gradientStart, _gradientEnd],
    ).createShader(Offset.zero & size);
    final paint = Paint()..shader = shader;

    final inHeights = _bandHeights(inputs, size.height, _gap);
    final outHeights = _bandHeights(outputs, size.height, _gap);
    final trunkHeight = inHeights.reduce((a, b) => a + b);
    final trunkTop = (size.height - trunkHeight) / 2;

    final capRight = _capWidth;
    final trunkLeft = size.width * 0.45;
    final trunkRight = size.width * 0.55;
    final outCapLeft = size.width - _capWidth - _arrowWidth;

    // Input caps and their merge bands into the trunk.
    var slotTop = _stackTop(inHeights, size.height, _gap);
    var trunkY = trunkTop;
    for (var i = 0; i < inputs.length; i++) {
      final h = inHeights[i];
      canvas.drawPath(_inputCap(slotTop, h, capRight), paint);
      _band(canvas, paint, capRight, slotTop, h, trunkLeft, trunkY, h);
      slotTop += h + _gap;
      trunkY += h;
    }

    // The trunk.
    canvas.drawRect(Rect.fromLTWH(trunkLeft, trunkTop, trunkRight - trunkLeft, trunkHeight), paint);

    // Split bands out of the trunk, then the output caps.
    slotTop = _stackTop(outHeights, size.height, _gap);
    trunkY = trunkTop;
    for (var i = 0; i < outputs.length; i++) {
      final h = outHeights[i];
      _band(canvas, paint, trunkRight, trunkY, h, outCapLeft, slotTop, h);
      if (!outputs[i].isFee) {
        canvas.drawPath(_outputCap(slotTop, h, outCapLeft, size.width), paint);
      } else {
        canvas.drawRect(Rect.fromLTWH(outCapLeft, slotTop, size.width - outCapLeft, h), paint);
      }
      slotTop += h + _gap;
      trunkY += h;
    }
  }

  /// Proportional heights with a floor, so dust and the fee stay visible.
  List<double> _bandHeights(List<FlowSlot> slots, double available, double gap) {
    final usable = available - gap * (slots.length - 1);
    final total = slots.fold<int>(0, (sum, s) => sum + max(s.sats, 0));
    if (total <= 0) {
      return List.filled(slots.length, max(usable / slots.length, _minBand));
    }
    return slots.map((s) => max(usable * s.sats / total, _minBand)).toList();
  }

  double _stackTop(List<double> heights, double available, double gap) {
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
  bool shouldRepaint(_SankeyPainter oldDelegate) {
    return !listEquals(oldDelegate.inputs.map((s) => s.sats).toList(), inputs.map((s) => s.sats).toList()) ||
        !listEquals(oldDelegate.outputs.map((s) => s.sats).toList(), outputs.map((s) => s.sats).toList());
  }
}
