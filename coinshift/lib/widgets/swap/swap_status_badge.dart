import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Badge widget displaying swap status with appropriate color
class SwapStatusBadge extends StatelessWidget {
  final SwapState state;

  const SwapStatusBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final (color, text) = _getStatusInfo(theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: SailStyleValues.borderRadiusSmall,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: SailText.secondary12(
        text,
        color: color,
      ),
    );
  }

  (Color, String) _getStatusInfo(SailThemeData theme) {
    if (state.isPending) {
      return (theme.colors.orangeLight, 'Pending');
    }
    if (state.isWaitingConfirmations) {
      return (
        theme.colors.info,
        '${state.currentConfirmations ?? 0}/${state.requiredConfirmations ?? 6} confirmations',
      );
    }
    if (state.isReadyToClaim) {
      return (theme.colors.success, 'Ready to Claim');
    }
    if (state.isCompleted) {
      return (theme.colors.textSecondary, 'Completed');
    }
    if (state.isCancelled) {
      return (theme.colors.error, 'Cancelled');
    }
    return (theme.colors.textSecondary, state.state);
  }
}
