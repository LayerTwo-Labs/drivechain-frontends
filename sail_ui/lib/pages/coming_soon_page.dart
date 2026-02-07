import 'dart:math';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class ComingSoonPage extends StatefulWidget {
  final RootStackRouter router;
  final String message;

  const ComingSoonPage({super.key, required this.router, required this.message});

  @override
  State<ComingSoonPage> createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage> with TickerProviderStateMixin {
  late AnimationController _starController;
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _stars = List.generate(100, (_) => _Star.random());
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated starfield background
          AnimatedBuilder(
            animation: _starController,
            builder: (context, child) {
              return CustomPaint(
                painter: _StarfieldPainter(
                  stars: _stars,
                  animation: _starController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  SailColorScheme.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with glow effect
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFFA500),
                          Color(0xFFFFD700),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'THIS COULD BE BITCOIN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                          shadows: [
                            ui.Shadow(
                              color: Color(0xFFFFD700),
                              blurRadius: 20,
                            ),
                            ui.Shadow(
                              color: Color(0xFFFFD700),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Subtitle
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Drivechain (BIP-300/301) enables sidechains on Bitcoin. '
                      'This feature requires activation with a soft fork.\n\n'
                      'Until activated, you can continue this demo and take a peak into the future by switching to Signet, where Drivechain is already active.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.8,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Switch to Signet button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.router.push(NetworkSwitchRoute());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Switch to Signet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double brightness;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.brightness,
  });

  factory _Star.random() {
    final random = Random();
    return _Star(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: random.nextDouble() * 2 + 0.5,
      speed: random.nextDouble() * 0.5 + 0.1,
      brightness: random.nextDouble() * 0.5 + 0.5,
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double animation;

  _StarfieldPainter({required this.stars, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Dark background with subtle gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0a0a1a),
          const Color(0xFF1a1a2e),
          const Color(0xFF0a0a1a),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw stars
    for (final star in stars) {
      final twinkle = (sin((animation + star.speed) * pi * 2) + 1) / 2;
      final alpha = star.brightness * (0.5 + twinkle * 0.5);

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 0.5);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => true;
}
