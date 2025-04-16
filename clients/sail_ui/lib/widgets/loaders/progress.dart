import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

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

    return Flexible(
      child: Row(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.passthrough, // This ensures proper fitting
              children: [
                // Background container
                Container(
                  height: 16.0,
                  decoration: BoxDecoration(
                    color: theme.colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                // Progress indicator
                ClipRRect(
                  // Added to ensure clean clipping
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 16.0,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colors.text,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(999),
                            right: Radius.circular(progress > 0.99 ? 999 : 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (current != null && goal != null)
                  Center(
                    child: SailText.primary10(
                      '${current != null ? numberFormat.format(current) : '0'} / ${goal != null ? numberFormat.format(goal) : '0'}',
                      color: theme.colors.inactiveNavText,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.0),
          SailText.primary12(
            '${(progress * 100).toStringAsFixed(2)}%',
          ),
        ],
      ),
    );
  }
}
