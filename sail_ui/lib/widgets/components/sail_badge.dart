import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// The tone a badge carries.
enum SailBadgeTone { neutral, success, warning, destructive }

/// A short label on a tinted pill, for a state or a kind.
class SailBadge extends StatelessWidget {
  final String label;
  final SailBadgeTone tone;

  const SailBadge(this.label, {super.key, this.tone = SailBadgeTone.neutral});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final color = switch (tone) {
      SailBadgeTone.neutral => colors.textSecondary,
      SailBadgeTone.success => colors.success,
      SailBadgeTone.warning => colors.orange,
      SailBadgeTone.destructive => colors.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding10, vertical: SailStyleValues.padding04),
      decoration: BoxDecoration(
        color: colors.chip,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SailText.primary12(label, color: color),
    );
  }
}
