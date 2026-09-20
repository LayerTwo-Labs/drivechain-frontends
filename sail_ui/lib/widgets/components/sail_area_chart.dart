import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// One reading on a [SailAreaChart].
class SailChartPoint {
  final DateTime at;
  final double value;

  const SailChartPoint({required this.at, required this.value});
}

/// A filled line over time. The vertical axis starts at zero and reaches the
/// highest point, so a flat series draws a flat line at the bottom.
class SailAreaChart extends StatelessWidget {
  final List<SailChartPoint> points;

  /// Labels under the plot, left to right.
  final List<String> labels;
  final double height;

  const SailAreaChart({
    super.key,
    required this.points,
    this.labels = const [],
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _AreaPainter(
              values: [for (final point in points) point.value],
              line: theme.colors.primary,
              grid: theme.colors.border,
            ),
          ),
        ),
        if (labels.isNotEmpty) ...[
          const SizedBox(height: SailStyleValues.padding08),
          SailRow(
            spacing: 0,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (final label in labels) SailText.secondary12(label)],
          ),
        ],
      ],
    );
  }
}

/// chartTopValue returns the value the vertical axis reaches. A series that is
/// all zero still gets a positive top, so the line lands on the floor.
double chartTopValue(List<double> values) {
  var top = 0.0;
  for (final value in values) {
    if (value > top) {
      top = value;
    }
  }
  return top <= 0 ? 1 : top;
}

class _AreaPainter extends CustomPainter {
  final List<double> values;
  final Color line;
  final Color grid;

  const _AreaPainter({required this.values, required this.line, required this.grid});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (values.length < 2) {
      return;
    }

    final top = chartTopValue(values);
    final step = size.width / (values.length - 1);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = Offset(step * i, size.height * (1 - values[i] / top));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: 0.28), line.withValues(alpha: 0.02)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_AreaPainter old) => old.values != values || old.line != line || old.grid != grid;
}
