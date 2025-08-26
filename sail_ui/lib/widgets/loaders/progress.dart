import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';

class ProgressBar extends StatelessWidget {
  final double current;
  final double goal;
  final bool small;
  final bool justPercent;
  final bool hideProgressInside;

  const ProgressBar({
    super.key,
    required this.current,
    required this.goal,
    this.small = false,
    this.hideProgressInside = false,
    this.justPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final numberFormat = NumberFormat.decimalPattern('fr_FR');
    final progress = (goal <= 0 ? 0 : current / goal).toDouble();

    var textInsideBar = '${numberFormat.format(current)} / ${numberFormat.format(goal)}';
    if (justPercent) {
      textInsideBar = '${((progress) * 100).toStringAsFixed(2)}%';
    } else if (hideProgressInside) {
      textInsideBar = '';
    }

    return SizedBox(
      height: small ? 10 : 16,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background container
                Container(
                  decoration: BoxDecoration(
                    color: theme.colors.backgroundSecondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                // Progress indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colors.text,
                        borderRadius: BorderRadius.horizontal(
                          left: const Radius.circular(999),
                          right: Radius.circular(current / goal > 0.99 ? 999 : 0),
                        ),
                      ),
                    ),
                  ),
                ),
                // Use Positioned.fill for stable text positioning
                Positioned.fill(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 100),
                      child: SailText.primary10(
                        textInsideBar,
                        textAlign: TextAlign.center,
                        color: theme.colors.inactiveNavText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!small && !justPercent) const SizedBox(width: 8.0),
          if (!small && !justPercent)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 50, maxWidth: 50),
              child: SailText.primary12('${((progress) * 100).toStringAsFixed(2)}%', textAlign: TextAlign.left),
            ),
        ],
      ),
    );
  }
}
