import 'package:flutter/material.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // Value between 0.0 and 1.0

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Flexible(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 16.0,
              decoration: BoxDecoration(
                color: theme.colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(999),
              ),
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
          SizedBox(width: 8.0),
          SailText.primary12(
            '${(progress * 100).toStringAsFixed(2)}%',
          ),
        ],
      ),
    );
  }
}
