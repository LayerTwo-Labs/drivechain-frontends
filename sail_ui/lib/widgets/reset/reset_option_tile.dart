import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ResetOptionTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;
  final bool isDestructive;

  const ResetOptionTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: SailStyleValues.borderRadiusSmall,
      child: Container(
        padding: const EdgeInsets.all(SailStyleValues.padding12),
        decoration: BoxDecoration(
          border: Border.all(
            color: value ? (isDestructive ? theme.colors.error : theme.colors.primary) : theme.colors.border,
          ),
          borderRadius: SailStyleValues.borderRadiusSmall,
        ),
        child: SailRow(
          spacing: SailStyleValues.padding12,
          children: [
            SailCheckbox(
              value: value,
              onChanged: onChanged,
            ),
            Expanded(
              child: SailColumn(
                spacing: SailStyleValues.padding04,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13(
                    title,
                    color: isDestructive ? theme.colors.error : null,
                  ),
                  SailText.secondary12(
                    subtitle,
                    color: isDestructive ? theme.colors.error.withValues(alpha: 0.7) : null,
                  ),
                ],
              ),
            ),
            if (isDestructive)
              SailSVG.fromAsset(
                SailSVGAsset.iconWarning,
                color: theme.colors.error,
                width: 20,
                height: 20,
              ),
          ],
        ),
      ),
    );
  }
}
