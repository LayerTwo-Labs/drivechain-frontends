import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

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

    return SailScaleButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding16, horizontal: SailStyleValues.padding32),
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
