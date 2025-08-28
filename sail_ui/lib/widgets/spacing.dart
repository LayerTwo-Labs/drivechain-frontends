import 'package:flutter/material.dart';

class SailSpacing extends StatelessWidget {
  final double spacing;
  const SailSpacing(this.spacing, [Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: spacing, height: spacing);
  }
}
