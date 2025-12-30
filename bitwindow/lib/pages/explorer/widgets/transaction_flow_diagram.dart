import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';

class TransactionFlowDiagram extends StatefulWidget {
  final GetTransactionDetailsResponse details;

  const TransactionFlowDiagram({super.key, required this.details});

  @override
  State<TransactionFlowDiagram> createState() => _TransactionFlowDiagramState();
}

class _TransactionFlowDiagramState extends State<TransactionFlowDiagram> {
  int? _hoveredInputIndex;
  int? _hoveredOutputIndex;
  bool _hoveredFee = false;
  OverlayEntry? _tooltipOverlay;

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  void _hideTooltip() {
    _tooltipOverlay?.remove();
    _tooltipOverlay = null;
  }

  void _showTooltip(BuildContext context, Offset globalPosition, Widget content) {
    _hideTooltip();

    final overlay = Overlay.of(context);
    _tooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: globalPosition.dx + 15,
        top: globalPosition.dy + 15,
        child: Material(
          color: Colors.transparent,
          child: content,
        ),
      ),
    );
    overlay.insert(_tooltipOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    final formatter = GetIt.I<FormatterProvider>();
    final details = widget.details;

    final maxInputs = 8;
    final maxOutputs = 8;
    final displayInputs = details.inputs.take(maxInputs).toList();
    final displayOutputs = details.outputs.take(maxOutputs).toList();

    // Calculate max value for scaling
    final maxInputValue = details.inputs.map((i) => i.valueSats.toInt()).fold(0, math.max);
    final maxOutputValue = details.outputs.map((o) => o.valueSats.toInt()).fold(0, math.max);
    final maxValue = math.max(maxInputValue, maxOutputValue);

    // Use SailUI primary color for the flow
    final primaryColor = theme.colors.primary;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.divider),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return MouseRegion(
            onExit: (_) {
              _hideTooltip();
              setState(() {
                _hoveredInputIndex = null;
                _hoveredOutputIndex = null;
                _hoveredFee = false;
              });
            },
            onHover: (event) => _handleHover(
              context,
              event.position,
              event.localPosition,
              constraints.biggest,
              displayInputs.length,
              displayOutputs.length,
              formatter,
            ),
            child: CustomPaint(
              painter: _BowtiePainter(
                inputs: displayInputs,
                outputs: displayOutputs,
                maxValue: maxValue,
                totalInputSats: details.totalInputSats.toInt(),
                feeSats: details.feeSats.toInt(),
                primaryColor: primaryColor,
                feeColor: theme.colors.orange,
                hoveredInputIndex: _hoveredInputIndex,
                hoveredOutputIndex: _hoveredOutputIndex,
                hoveredFee: _hoveredFee,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }

  // Calculate stroke width - must match the painter exactly
  double _getStrokeWidth(int valueSats, int totalInputSats) {
    if (totalInputSats == 0) return 3.0;
    final ratio = valueSats / totalInputSats;
    return math.max(2.0, ratio * 120).clamp(2.0, 50.0);
  }

  // Get Y position on a cubic bezier curve at parameter t
  double _bezierY(double t, double y0, double y1, double y2, double y3) {
    final mt = 1 - t;
    return mt * mt * mt * y0 + 3 * mt * mt * t * y1 + 3 * mt * t * t * y2 + t * t * t * y3;
  }

  // Get X position on a cubic bezier curve at parameter t
  double _bezierX(double t, double x0, double x1, double x2, double x3) {
    final mt = 1 - t;
    return mt * mt * mt * x0 + 3 * mt * mt * t * x1 + 3 * mt * t * t * x2 + t * t * t * x3;
  }

  // Check if point is near a bezier curve
  bool _isNearInputCurve(
    Offset point,
    double startY,
    double centerY,
    double knotLeft,
    double padding,
    double hitRadius,
  ) {
    // Input curve: from (padding, startY) to (knotLeft, centerY)
    // Control points match the painter
    final x0 = padding;
    final y0 = startY;
    final x1 = knotLeft * 0.6;
    final y1 = startY;
    final x2 = knotLeft * 0.8;
    final y2 = centerY;
    final x3 = knotLeft;
    final y3 = centerY;

    // Sample the curve densely and check distance
    for (var t = 0.0; t <= 1.0; t += 0.02) {
      final cx = _bezierX(t, x0, x1, x2, x3);
      final cy = _bezierY(t, y0, y1, y2, y3);
      final dx = point.dx - cx;
      final dy = point.dy - cy;
      if (dx * dx + dy * dy < hitRadius * hitRadius) return true;
    }
    return false;
  }

  bool _isNearOutputCurve(
    Offset point,
    double endY,
    double centerY,
    double knotRight,
    double width,
    double padding,
    double hitRadius,
  ) {
    // Output curve: from (knotRight, centerY) to (width - padding, endY)
    final x0 = knotRight;
    final y0 = centerY;
    final x1 = knotRight + (width - knotRight) * 0.2;
    final y1 = centerY;
    final x2 = knotRight + (width - knotRight) * 0.4;
    final y2 = endY;
    final x3 = width - padding;
    final y3 = endY;

    // Sample the curve densely and check distance
    for (var t = 0.0; t <= 1.0; t += 0.02) {
      final cx = _bezierX(t, x0, x1, x2, x3);
      final cy = _bezierY(t, y0, y1, y2, y3);
      final dx = point.dx - cx;
      final dy = point.dy - cy;
      if (dx * dx + dy * dy < hitRadius * hitRadius) return true;
    }
    return false;
  }

  void _handleHover(
    BuildContext context,
    Offset globalPosition,
    Offset localPosition,
    Size size,
    int inputCount,
    int outputCount,
    FormatterProvider formatter,
  ) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const padding = 16.0;
    final flowHeight = size.height - padding * 2;
    final flowTop = padding;

    // Center knot bounds (must match painter exactly)
    const knotWidth = 80.0;
    const knotHeight = 60.0;
    final knotLeft = centerX - knotWidth / 2;
    final knotRight = centerX + knotWidth / 2;
    final knotTop = centerY - knotHeight / 2;
    final knotBottom = centerY + knotHeight / 2;

    int? newInputIndex;
    int? newOutputIndex;
    bool newFee = false;

    // Check if hovering over center knot
    final isInKnot =
        localPosition.dx >= knotLeft &&
        localPosition.dx <= knotRight &&
        localPosition.dy >= knotTop &&
        localPosition.dy <= knotBottom;

    // Check if hovering over fee indicator (small area below knot)
    final isInFeeArea =
        localPosition.dx >= centerX - 10 &&
        localPosition.dx <= centerX + 10 &&
        localPosition.dy > knotBottom &&
        localPosition.dy <= knotBottom + 30;

    if (isInKnot || isInFeeArea) {
      newFee = true;
    } else {
      final details = widget.details;
      final totalInputSats = details.totalInputSats.toInt();

      // Check input curves - hit radius scales with stroke width
      final inputSpacing = flowHeight / (inputCount + 1);
      for (var i = 0; i < inputCount && i < details.inputs.length; i++) {
        final lineY = flowTop + inputSpacing * (i + 1);
        final valueSats = details.inputs[i].valueSats.toInt();
        final strokeWidth = _getStrokeWidth(valueSats, totalInputSats);
        final hitRadius = (strokeWidth / 2).clamp(8.0, 30.0); // Min 8px so thin lines are hittable
        if (_isNearInputCurve(localPosition, lineY, centerY, knotLeft, padding, hitRadius)) {
          newInputIndex = i;
          break;
        }
      }

      // Check output curves if no input found
      if (newInputIndex == null) {
        final outputSpacing = flowHeight / (outputCount + 1);
        for (var i = 0; i < outputCount && i < details.outputs.length; i++) {
          final lineY = flowTop + outputSpacing * (i + 1);
          final valueSats = details.outputs[i].valueSats.toInt();
          final strokeWidth = _getStrokeWidth(valueSats, totalInputSats);
          final hitRadius = (strokeWidth / 2).clamp(8.0, 30.0); // Min 8px so thin lines are hittable
          if (_isNearOutputCurve(localPosition, lineY, centerY, knotRight, size.width, padding, hitRadius)) {
            newOutputIndex = i;
            break;
          }
        }
      }
    }

    // Only update if changed
    if (newInputIndex != _hoveredInputIndex || newOutputIndex != _hoveredOutputIndex || newFee != _hoveredFee) {
      setState(() {
        _hoveredInputIndex = newInputIndex;
        _hoveredOutputIndex = newOutputIndex;
        _hoveredFee = newFee;
      });

      // Show/hide tooltip
      if (newInputIndex != null || newOutputIndex != null || newFee) {
        _showTooltip(context, globalPosition, _buildTooltipContent(context, formatter));
      } else {
        _hideTooltip();
      }
    } else if (_tooltipOverlay != null) {
      // Update tooltip position
      _tooltipOverlay!.markNeedsBuild();
      _showTooltip(context, globalPosition, _buildTooltipContent(context, formatter));
    }
  }

  Widget _buildTooltipContent(BuildContext context, FormatterProvider formatter) {
    final theme = context.sailTheme;
    final details = widget.details;

    Widget content;
    if (_hoveredInputIndex != null && _hoveredInputIndex! < details.inputs.length) {
      final input = details.inputs[_hoveredInputIndex!];
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailText.primary12('Input #${_hoveredInputIndex! + 1}', bold: true),
          const SizedBox(height: 4),
          if (input.isCoinbase)
            SailText.secondary12('Coinbase (newly minted)')
          else ...[
            SailText.secondary12('Value: ${formatter.formatSats(input.valueSats.toInt())}'),
            const SizedBox(height: 2),
            SailText.secondary12(
              'Address: ${_truncateAddress(input.address)}',
              monospace: true,
            ),
            const SizedBox(height: 2),
            SailText.secondary12(
              'From: ${input.prevTxid.substring(0, 8)}...  :${input.prevVout}',
              monospace: true,
            ),
          ],
        ],
      );
    } else if (_hoveredOutputIndex != null && _hoveredOutputIndex! < details.outputs.length) {
      final output = details.outputs[_hoveredOutputIndex!];
      final isOpReturn = output.scriptType == 'nulldata';
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailText.primary12('Output #${_hoveredOutputIndex! + 1}', bold: true),
          const SizedBox(height: 4),
          if (isOpReturn)
            SailText.secondary12('OP_RETURN (data carrier)')
          else ...[
            SailText.secondary12('Value: ${formatter.formatSats(output.valueSats.toInt())}'),
            const SizedBox(height: 2),
            SailText.secondary12(
              'Address: ${_truncateAddress(output.address)}',
              monospace: true,
            ),
            const SizedBox(height: 2),
            SailText.secondary12('Type: ${output.scriptType}'),
          ],
        ],
      );
    } else if (_hoveredFee) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SailText.primary12('Transaction Fee', bold: true),
          const SizedBox(height: 4),
          SailText.secondary12('Fee: ${formatter.formatSats(details.feeSats.toInt())}'),
          const SizedBox(height: 2),
          SailText.secondary12('Rate: ${details.feeRateSatVb.toStringAsFixed(2)} sat/vB'),
          const SizedBox(height: 2),
          SailText.secondary12('Size: ${details.vsizeVbytes} vB'),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 250),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: SailStyleValues.borderRadiusSmall,
        border: Border.all(color: theme.colors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }

  String _truncateAddress(String address) {
    if (address.isEmpty) return '???';
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }
}

class _BowtiePainter extends CustomPainter {
  final List<TransactionInput> inputs;
  final List<TransactionOutput> outputs;
  final int maxValue;
  final int totalInputSats;
  final int feeSats;
  final Color primaryColor;
  final Color feeColor;
  final int? hoveredInputIndex;
  final int? hoveredOutputIndex;
  final bool hoveredFee;

  _BowtiePainter({
    required this.inputs,
    required this.outputs,
    required this.maxValue,
    required this.totalInputSats,
    required this.feeSats,
    required this.primaryColor,
    required this.feeColor,
    this.hoveredInputIndex,
    this.hoveredOutputIndex,
    this.hoveredFee = false,
  });

  double _getStrokeWidth(int valueSats) {
    if (maxValue == 0 || totalInputSats == 0) return 3.0;
    // Scale between 2 and 40 based on proportion of total
    final ratio = valueSats / totalInputSats;
    return math.max(2.0, ratio * 120).clamp(2.0, 50.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 16.0;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final flowHeight = size.height - padding * 2;
    final flowTop = padding;

    // Center "knot" dimensions
    const knotWidth = 80.0;
    final knotLeft = centerX - knotWidth / 2;
    final knotRight = centerX + knotWidth / 2;

    // Draw inputs flowing into center
    final inputCount = inputs.length;
    final inputSpacing = flowHeight / (inputCount + 1);

    for (var i = 0; i < inputCount; i++) {
      final input = inputs[i];
      final strokeWidth = _getStrokeWidth(input.valueSats.toInt());
      final y = flowTop + inputSpacing * (i + 1);
      final isHovered = hoveredInputIndex == i;

      // Use primary color with gradient alpha
      final gradient = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: isHovered ? 0.9 : 0.4),
          primaryColor.withValues(alpha: isHovered ? 1.0 : 0.7),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromLTRB(0, 0, knotLeft, size.height))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(padding, y);

      // Smooth cubic bezier curve to center
      path.cubicTo(
        knotLeft * 0.6,
        y,
        knotLeft * 0.8,
        centerY,
        knotLeft,
        centerY,
      );

      canvas.drawPath(path, paint);

      // Draw arrow indicator at start
      if (isHovered) {
        final arrowPaint = Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill;
        final arrowPath = Path();
        arrowPath.moveTo(padding + 8, y - 6);
        arrowPath.lineTo(padding + 16, y);
        arrowPath.lineTo(padding + 8, y + 6);
        arrowPath.close();
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }

    // Draw center knot
    final knotPaint = Paint()
      ..color = primaryColor.withValues(alpha: hoveredFee ? 0.9 : 0.6)
      ..style = PaintingStyle.fill;

    final knotPath = Path();
    knotPath.moveTo(knotLeft, centerY - 30);
    knotPath.lineTo(knotRight, centerY - 30);
    knotPath.lineTo(knotRight, centerY + 30);
    knotPath.lineTo(knotLeft, centerY + 30);
    knotPath.close();
    canvas.drawPath(knotPath, knotPaint);

    // Draw outputs flowing from center
    final outputCount = outputs.length;
    final outputSpacing = flowHeight / (outputCount + 1);

    for (var i = 0; i < outputCount; i++) {
      final output = outputs[i];
      final strokeWidth = _getStrokeWidth(output.valueSats.toInt());
      final y = flowTop + outputSpacing * (i + 1);
      final isHovered = hoveredOutputIndex == i;

      // Use primary color with gradient alpha
      final gradient = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: isHovered ? 1.0 : 0.7),
          primaryColor.withValues(alpha: isHovered ? 0.9 : 0.4),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromLTRB(knotRight, 0, size.width, size.height))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(knotRight, centerY);

      // Smooth cubic bezier curve to output
      path.cubicTo(
        knotRight + (size.width - knotRight) * 0.2,
        centerY,
        knotRight + (size.width - knotRight) * 0.4,
        y,
        size.width - padding,
        y,
      );

      canvas.drawPath(path, paint);

      // Draw arrow indicator at end
      if (isHovered) {
        final arrowPaint = Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill;
        final arrowPath = Path();
        arrowPath.moveTo(size.width - padding - 8, y - 6);
        arrowPath.lineTo(size.width - padding, y);
        arrowPath.lineTo(size.width - padding - 8, y + 6);
        arrowPath.close();
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }

    // Draw fee indicator (small line going down)
    if (feeSats > 0) {
      final feeWidth = _getStrokeWidth(feeSats).clamp(2.0, 8.0);
      final feePaint = Paint()
        ..color = feeColor.withValues(alpha: hoveredFee ? 1.0 : 0.5)
        ..strokeWidth = feeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final feePath = Path();
      feePath.moveTo(centerX, centerY + 30);
      feePath.lineTo(centerX, centerY + 50);
      canvas.drawPath(feePath, feePaint);

      // Small circle at end
      canvas.drawCircle(
        Offset(centerX, centerY + 54),
        4,
        Paint()..color = feeColor.withValues(alpha: hoveredFee ? 1.0 : 0.4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BowtiePainter oldDelegate) {
    return inputs != oldDelegate.inputs ||
        outputs != oldDelegate.outputs ||
        hoveredInputIndex != oldDelegate.hoveredInputIndex ||
        hoveredOutputIndex != oldDelegate.hoveredOutputIndex ||
        hoveredFee != oldDelegate.hoveredFee;
  }
}
