import 'package:flutter/material.dart';

class SSpacing extends StatelessWidget {
  final double spacing;
  const SSpacing(this.spacing, [Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: spacing,
      height: spacing,
    );
  }
}
