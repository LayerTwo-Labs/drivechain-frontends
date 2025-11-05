import 'dart:convert';
import 'dart:math';

import 'package:flutter/painting.dart';

/// Visual configuration for wallet avatar
/// Can use either SVG background or gradient blob
class WalletGradient {
  final String? backgroundSvg;
  final List<String> colors;
  final List<double> stops;
  final double centerX;
  final double centerY;
  final double radius;
  final int seed;

  WalletGradient({
    this.backgroundSvg,
    required this.colors,
    required this.stops,
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.seed,
  });

  Map<String, dynamic> toJson() {
    return {
      if (backgroundSvg != null) 'background_svg': backgroundSvg,
      'colors': colors,
      'stops': stops,
      'center_x': centerX,
      'center_y': centerY,
      'radius': radius,
      'seed': seed,
    };
  }

  factory WalletGradient.fromJson(Map<String, dynamic> json) {
    return WalletGradient(
      backgroundSvg: json['background_svg'] as String?,
      colors: (json['colors'] as List<dynamic>).map((c) => c as String).toList(),
      stops: (json['stops'] as List<dynamic>).map((s) => (s as num).toDouble()).toList(),
      centerX: (json['center_x'] as num).toDouble(),
      centerY: (json['center_y'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      seed: json['seed'] as int,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory WalletGradient.fromJsonString(String jsonString) {
    return WalletGradient.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Generate a gradient from wallet ID
  factory WalletGradient.fromWalletId(String walletId) {
    final hash = walletId.hashCode.abs();
    final random = Random(hash);

    final backgroundSvgs = [
      'background_blue.svg',
      'background_contact.svg',
      'background_fog.svg',
      'background_forest.svg',
      'background_hooked.svg',
      'background_ice.svg',
      'background_northern.svg',
      'background_northern_blue.svg',
      'background_northern_green.svg',
      'background_northern_dark_green.svg',
      'background_ocean.svg',
      'background_orange.svg',
      'background_purple.svg',
      'background_sphere.svg',
      'background_sunrise.svg',
      'background_swirl_green.svg',
      'background_swirl_orange.svg',
      'background_swirl_purple.svg',
    ];

    final colorSchemes = [
      ['#FF6B35', '#FF8C42', '#1A1A1A'],
      ['#2E7D32', '#4CAF50', '#0D1F0D'],
      ['#1976D2', '#42A5F5', '#0A1929'],
      ['#C2185B', '#E91E63', '#1A0A12'],
      ['#F57C00', '#FFA726', '#1F1209'],
      ['#7B1FA2', '#AB47BC', '#1A0D1F'],
      ['#0097A7', '#26C6DA', '#0A1A1F'],
      ['#D32F2F', '#EF5350', '#1F0A0A'],
    ];

    final chosenScheme = colorSchemes[random.nextInt(colorSchemes.length)];
    final chosenBackground = backgroundSvgs[random.nextInt(backgroundSvgs.length)];

    return WalletGradient(
      backgroundSvg: chosenBackground,
      colors: chosenScheme,
      stops: [0.0, 0.4, 1.0],
      centerX: -0.3 + random.nextDouble() * 0.6,
      centerY: -0.4 + random.nextDouble() * 0.8,
      radius: 0.9 + random.nextDouble() * 0.5,
      seed: hash,
    );
  }

  /// Convert hex color strings to Color objects
  List<Color> get colorObjects {
    return colors.map((hex) {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    }).toList();
  }

  /// Create a RadialGradient for simple rendering
  RadialGradient toRadialGradient() {
    return RadialGradient(
      center: Alignment(centerX, centerY),
      radius: radius,
      colors: colorObjects,
      stops: stops,
    );
  }

  WalletGradient copyWith({
    String? backgroundSvg,
    List<String>? colors,
    List<double>? stops,
    double? centerX,
    double? centerY,
    double? radius,
    int? seed,
  }) {
    return WalletGradient(
      backgroundSvg: backgroundSvg ?? this.backgroundSvg,
      colors: colors ?? this.colors,
      stops: stops ?? this.stops,
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      radius: radius ?? this.radius,
      seed: seed ?? this.seed,
    );
  }
}
