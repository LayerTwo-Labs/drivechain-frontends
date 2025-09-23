import 'package:flutter/material.dart';
import 'package:sail_ui/models/homepage_configuration.dart';
import 'package:sail_ui/widgets/core/sail_svg.dart';

class HomepageWidgetInfo {
  final String id;
  final String name;
  final String description;
  final WidgetSize size;
  final SailSVGAsset icon;
  final Widget Function(Map<String, dynamic> settings) builder;

  const HomepageWidgetInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.size,
    required this.icon,
    required this.builder,
  });
}
