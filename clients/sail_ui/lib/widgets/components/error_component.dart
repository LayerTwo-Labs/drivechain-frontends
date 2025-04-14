import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ErrorComponent extends StatelessWidget {
  final String error;

  const ErrorComponent({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (error.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: SailColorScheme.red.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(
          color: SailColorScheme.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: SailColorScheme.red,
          ),
          const SizedBox(width: SailStyleValues.padding08),
          Expanded(
            child: SailText.primary13(
              error,
              color: SailColorScheme.red,
            ),
          ),
        ],
      ),
    );
  }
}
