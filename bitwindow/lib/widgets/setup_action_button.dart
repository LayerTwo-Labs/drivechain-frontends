import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// A large wallet setup button. The [primary] one is the call to action.
class SetupActionButton extends StatelessWidget {
  final String label;
  final bool primary;
  final bool enabled;
  final Future<void> Function() onPressed;

  const SetupActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SailTappable(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: 400,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: theme.chrome.radius,
            color: primary ? theme.colors.primaryButtonBackground : theme.colors.secondaryButtonBackground,
          ),
          child: SailText.primary16(
            label,
            bold: true,
            color: primary ? theme.colors.primaryButtonText : theme.colors.secondaryButtonText,
          ),
        ),
      ),
    );
  }
}
