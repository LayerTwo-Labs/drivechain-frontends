import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailPadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const SailPadding({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: SailStyleValues.padding20,
            vertical: SailStyleValues.padding25,
          ),
      child: child,
    );
  }
}
