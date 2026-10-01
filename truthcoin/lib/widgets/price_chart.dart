import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/providers/price_history_provider.dart';

/// Draws the recorded price of one outcome. The chart holds the readings the
/// app took, because the node serves no price history.
class PriceChart extends StatelessWidget {
  final List<PricePoint> points;
  final Color color;
  final double height;

  const PriceChart({
    super.key,
    required this.points,
    required this.color,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (points.length < 2) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          borderRadius: SailStyleValues.borderRadius,
        ),
        child: SailText.secondary12('The chart fills as the price moves'),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _PriceChartPainter(
          points: points,
          line: color,
          grid: theme.colors.divider,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _PriceChartPainter extends CustomPainter {
  final List<PricePoint> points;
  final Color line;
  final Color grid;

  _PriceChartPainter({required this.points, required this.line, required this.grid});

  @override
  void paint(Canvas canvas, Size size) {
    final first = points.first.at.millisecondsSinceEpoch.toDouble();
    final last = points.last.at.millisecondsSinceEpoch.toDouble();
    final span = (last - first).abs() < 1 ? 1.0 : last - first;

    double x(PricePoint point) => (point.at.millisecondsSinceEpoch - first) / span * size.width;
    // A chance runs from 0 to 1, so the chart keeps that scale and never lies
    // about the size of a move.
    double y(PricePoint point) => size.height - point.price.clamp(0.0, 1.0) * size.height;

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final at = size.height * i / 4;
      canvas.drawLine(Offset(0, at), Offset(size.width, at), gridPaint);
    }

    final path = Path()..moveTo(x(points.first), y(points.first));
    for (final point in points.skip(1)) {
      path.lineTo(x(point), y(point));
    }

    final fill = Path.from(path)
      ..lineTo(x(points.last), size.height)
      ..lineTo(x(points.first), size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = line.withValues(alpha: 0.12));

    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PriceChartPainter old) {
    if (old.line != line || old.grid != grid || old.points.length != points.length) return true;
    for (var i = 0; i < points.length; i++) {
      if (old.points[i].price != points[i].price || old.points[i].at != points[i].at) return true;
    }
    return false;
  }
}
