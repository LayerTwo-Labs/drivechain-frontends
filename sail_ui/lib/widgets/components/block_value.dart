import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class BlockValue extends StatelessWidget {
  final String label;
  final String value;

  const BlockValue({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      height: 60,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SailText.primary13(
            label,
            monospace: true,
            color: theme.colors.textTertiary,
          ),
          SailText.secondary13(
            value,
            monospace: true,
          ),
        ],
      ),
    );
  }
}
