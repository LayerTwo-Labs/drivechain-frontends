import 'package:flutter/widgets.dart';
import 'package:sidechain_core/models/homepage_configuration.dart';

extension WidgetSizeLabel on WidgetSize {
  String get label => switch (this) {
    WidgetSize.bar => 'Bar',
    WidgetSize.half => 'Half Width',
    WidgetSize.full => 'Full Width',
  };
}

class HomepageWidgetInfo {
  final String id;
  final String name;

  /// The sizes the widget has, smallest first.
  final List<WidgetSize> sizes;

  /// The library section that lists the widget. Null puts it in the first section with no header.
  final String? group;

  /// One line that says what the widget shows. The phone library lists it under the name.
  final String? subtitle;

  /// True keeps the full size in the one-column phone layout, for a full form that stacks its parts.
  final bool fullOnPhones;

  final Widget Function(WidgetSize size) builder;

  const HomepageWidgetInfo({
    required this.id,
    required this.name,
    required this.sizes,
    required this.builder,
    this.group,
    this.subtitle,
    this.fullOnPhones = false,
  }) : assert(sizes.length > 0);

  WidgetSize sizeOf(HomepageWidgetConfig config) {
    final size = config.size;
    if (size != null && sizes.contains(size)) {
      return size;
    }
    return sizes.first;
  }
}
