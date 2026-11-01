import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// A large wallet setup button. The [primary] one is the call to action, so it
/// is oversized and carries a lit edge.
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
          decoration: primary
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [theme.colors.orange, theme.colors.orange.withValues(alpha: 0.88)],
                  ),
                  border: Border.all(color: theme.colors.orange.withValues(alpha: 0.55)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colors.orange.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.colors.backgroundSecondary,
                  border: Border.all(color: theme.colors.border),
                ),
          child: primary
              ? SailText.primary16(label, bold: true, color: SailColorScheme.white)
              : SailText.primary16(label, bold: true),
        ),
      ),
    );
  }
}
