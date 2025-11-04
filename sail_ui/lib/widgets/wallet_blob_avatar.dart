import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sail_ui/models/wallet_gradient.dart';

/// Organic blob avatar for wallet visualization
class WalletBlobAvatar extends StatelessWidget {
  final WalletGradient gradient;
  final double size;

  const WalletBlobAvatar({
    super.key,
    required this.gradient,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BlobPainter(gradient: gradient),
      ),
    );
  }
}

/// Custom painter that draws organic blob shapes with gradients
class BlobPainter extends CustomPainter {
  final WalletGradient gradient;

  BlobPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final gradientCenter = Offset(
      center.dx + (gradient.centerX * size.width * 0.3),
      center.dy + (gradient.centerY * size.height * 0.3),
    );

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (gradientCenter.dx - size.width / 2) / (size.width / 2),
          (gradientCenter.dy - size.height / 2) / (size.height / 2),
        ),
        radius: gradient.radius,
        colors: gradient.colorObjects,
        stops: gradient.stops,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, paint);
  }

  /// Generate organic blob path using bezier curves
  Path _generateBlobPath(Offset center, double radius, Random random) {
    final path = Path();
    const numPoints = 8;
    final angleStep = (2 * pi) / numPoints;

    final points = <Offset>[];
    for (int i = 0; i < numPoints; i++) {
      final angle = i * angleStep;
      final variance = 0.7 + random.nextDouble() * 0.6;
      final r = radius * variance;

      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < numPoints; i++) {
      final current = points[i];
      final next = points[(i + 1) % numPoints];

      final controlPoint1X = current.dx + (next.dx - current.dx) * 0.5 +
          (random.nextDouble() - 0.5) * radius * 0.3;
      final controlPoint1Y = current.dy + (next.dy - current.dy) * 0.5 +
          (random.nextDouble() - 0.5) * radius * 0.3;

      final controlPoint2X = current.dx + (next.dx - current.dx) * 0.7 +
          (random.nextDouble() - 0.5) * radius * 0.2;
      final controlPoint2Y = current.dy + (next.dy - current.dy) * 0.7 +
          (random.nextDouble() - 0.5) * radius * 0.2;

      path.cubicTo(
        controlPoint1X,
        controlPoint1Y,
        controlPoint2X,
        controlPoint2Y,
        next.dx,
        next.dy,
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) {
    return oldDelegate.gradient != gradient;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlobPainter && other.gradient == gradient;
  }

  @override
  int get hashCode => gradient.hashCode;
}
