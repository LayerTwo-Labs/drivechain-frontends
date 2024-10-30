import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

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
          vertical: SailStyleValues.padding04,
          horizontal: SailStyleValues.padding10,
        ),
        child: SailText.secondary12(title),
      ),
    );
  }
}
