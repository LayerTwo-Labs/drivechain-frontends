import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailPadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const SailPadding({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: SailTheme.of(context).dense ? SailStyleValues.padding10 : SailStyleValues.padding20,
            vertical: SailTheme.of(context).dense ? SailStyleValues.padding16 : SailStyleValues.padding25,
          ),
      child: child,
    );
  }
}
