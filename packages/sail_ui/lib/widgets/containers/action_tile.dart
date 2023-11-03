import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

enum Category {
  sidechain,
  mainchain,
}

class ActionTile extends StatelessWidget {
  final String title;
  final Category category;
  final IconData? icon;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.title,
    required this.category,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding15, horizontal: SailStyleValues.padding30),
        child: Row(
          children: [
            if (icon != null)
              Icon(
                icon!,
                size: 14,
                color: theme.colors.text,
              ),
            const SailSpacing(SailStyleValues.padding08),
            SailText.primary13(title),
          ],
        ),
      ),
    );
  }
}
