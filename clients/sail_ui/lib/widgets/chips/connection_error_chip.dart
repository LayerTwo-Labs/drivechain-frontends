import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ConnectionErrorChip extends StatelessWidget {
  final String chain;
  final Future<void> Function() onPressed;

  const ConnectionErrorChip({
    super.key,
    required this.chain,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SailButton(
      label: 'Not connected to $chain',
      variant: ButtonVariant.outline,
      icon: SailSVGAsset.iconGlobe,
      onPressed: onPressed,
    );
  }
}
