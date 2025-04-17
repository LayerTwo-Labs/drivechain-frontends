import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final int? current;
  final int? goal;

  const ProgressBar({
    super.key,
    required this.progress,
    this.current,
    this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('fr_FR');
    final theme = SailTheme.of(context);

    return SizedBox(
      height: 16,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background container
                Container(
                  decoration: BoxDecoration(
                    color: theme.colors.backgroundSecondary,
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
                          right: Radius.circular(progress > 0.99 ? 999 : 0),
                        ),
                      ),
                    ),
                  ),
                ),
                if (current != null && goal != null)
                  Positioned.fill(
                    // Use Positioned.fill for stable text positioning
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: Text(
                          '${current != null ? numberFormat.format(current) : '0'} / ${goal != null ? numberFormat.format(goal) : '0'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colors.inactiveNavText,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 50, maxWidth: 50),
            child: SailText.primary12(
              '${(progress * 100).toStringAsFixed(2)}%',
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
