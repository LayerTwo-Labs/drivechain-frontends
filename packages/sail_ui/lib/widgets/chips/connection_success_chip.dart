import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class ConnectionSuccessChip extends StatelessWidget {
  final String chain;

  const ConnectionSuccessChip({super.key, required this.chain});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: theme.colors.formFieldBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: SailStyleValues.padding05,
          horizontal: SailStyleValues.padding10,
        ),
        child: SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailSVG.fromAsset(SailSVGAsset.iconGlobe, color: theme.colors.success),
            SailText.primary12('Connected to $chain'),
          ],
        ),
      ),
    );
  }
}
