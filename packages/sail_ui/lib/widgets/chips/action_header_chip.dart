import 'package:flutter/material.dart';
import 'package:sail_ui/style/style_values.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class ActionHeaderChip extends StatelessWidget {
  final String title;

  const ActionHeaderChip({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: theme.colors.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: SailStyleValues.padding5,
          horizontal: SailStyleValues.padding10,
        ),
        child: SailText.primary12(title),
      ),
    );
  }
}
