import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class SailToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueSetter<bool> onChanged;

  const SailToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailScaleButton(
      onPressed: () {
        onChanged(!value);
      },
      child: SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          Container(
            width: 30,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1000),
              color: value ? theme.colors.orange : theme.colors.textSecondary,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? Colors.white : theme.colors.background,
                  ),
                ),
              ),
            ),
          ),
          SailText.secondary12(label),
        ],
      ),
    );
  }
}
