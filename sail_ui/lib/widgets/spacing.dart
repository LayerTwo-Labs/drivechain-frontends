import 'package:flutter/material.dart';

class SailSpacing extends StatelessWidget {
  final double spacing;
  const SailSpacing(this.spacing, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: spacing);
  }
}
