import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Compact "Reset" affordance; [onTap] navigates to the app's reset settings.
class ResetButton extends StatelessWidget {
  final Future<void> Function() onTap;

  const ResetButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailTooltip(
      message: 'Reset / Troubleshoot',
      child: SailTappable(
        onTap: onTap,
        borderRadius: SailStyleValues.borderRadiusSmall,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SailRow(
            spacing: SailStyleValues.padding04,
            children: [
              SailSVG.fromAsset(
                SailSVGAsset.iconRestart,
                color: theme.colors.textSecondary,
                width: 12,
                height: 12,
              ),
              SailText.secondary12('Reset'),
            ],
          ),
        ),
      ),
    );
  }
}
