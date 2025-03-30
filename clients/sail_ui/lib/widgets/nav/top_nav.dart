import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class QtTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const QtTab({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: SailText.primary13(
            label,
            color: active ? theme.colors.text : theme.colors.textSecondary,
            bold: true,
          ),
        ),
      ),
    );
  }
}
