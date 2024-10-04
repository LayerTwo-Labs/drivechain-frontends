import 'package:flutter/material.dart';
import 'package:sail_ui/theme/theme.dart';

List<BoxShadow> sailBoxShadow(BuildContext context) {
  return [
    BoxShadow(
      offset: const Offset(0.0, 1.0),
      blurRadius: 0.5,
      color: SailTheme.of(context).colors.shadow,
    ),
  ];
}
