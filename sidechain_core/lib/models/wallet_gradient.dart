import 'dart:convert';
import 'dart:math';

import 'package:flutter/painting.dart';

/// Visual configuration for wallet avatar
/// Can use either SVG background or gradient blob
class WalletGradient {
  final String? backgroundSvg;

  /// A picture the user chose, as a file on this computer. It replaces the
  /// generated avatar while it is set.
  final String? picturePath;
  final List<String> colors;
  final List<double> stops;
  final double centerX;
  final double centerY;
  final double radius;
  final int seed;

  WalletGradient({
    this.backgroundSvg,
    this.picturePath,
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
      if (picturePath != null) 'picture_path': picturePath,
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
      picturePath: json['picture_path'] as String?,
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
    return WalletGradient.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Generate a gradient from wallet ID
  factory WalletGradient.fromWalletId(String walletId) {
    final hash = walletId.hashCode.abs();
    final random = Random(hash);

    final backgroundAssets = allBackgrounds;

    final colorSchemes = allColorSchemes;

    final chosenScheme = colorSchemes[random.nextInt(colorSchemes.length)];
    final chosenBackground = backgroundAssets[random.nextInt(backgroundAssets.length)];

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

  /// Drops the picture and brings the generated avatar back.
  WalletGradient withoutPicture() => WalletGradient(
    backgroundSvg: backgroundSvg,
    colors: colors,
    stops: stops,
    centerX: centerX,
    centerY: centerY,
    radius: radius,
    seed: seed,
  );

  WalletGradient copyWith({
    String? backgroundSvg,
    String? picturePath,
    List<String>? colors,
    List<double>? stops,
    double? centerX,
    double? centerY,
    double? radius,
    int? seed,
  }) {
    return WalletGradient(
      backgroundSvg: backgroundSvg ?? this.backgroundSvg,
      picturePath: picturePath ?? this.picturePath,
      colors: colors ?? this.colors,
      stops: stops ?? this.stops,
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      radius: radius ?? this.radius,
      seed: seed ?? this.seed,
    );
  }

  /// All available background SVG filenames for user selection
  static List<String> get allBackgrounds => [
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

  /// All available color schemes for user selection
  static List<List<String>> get allColorSchemes => [
    ['#FF6B35', '#FF8C42', '#1A1A1A'], // Orange
    ['#2E7D32', '#4CAF50', '#0D1F0D'], // Green
    ['#1976D2', '#42A5F5', '#0A1929'], // Blue
    ['#C2185B', '#E91E63', '#1A0A12'], // Pink
    ['#F57C00', '#FFA726', '#1F1209'], // Amber
    ['#7B1FA2', '#AB47BC', '#1A0D1F'], // Purple
    ['#0097A7', '#26C6DA', '#0A1A1F'], // Cyan
    ['#D32F2F', '#EF5350', '#1F0A0A'], // Red
  ];

  /// Create a gradient with specific background and colors
  factory WalletGradient.custom({
    required String backgroundSvg,
    required List<String> colors,
    int? seed,
  }) {
    return WalletGradient(
      backgroundSvg: backgroundSvg,
      colors: colors,
      stops: [0.0, 0.4, 1.0],
      centerX: 0.0,
      centerY: 0.0,
      radius: 1.2,
      seed: seed ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
