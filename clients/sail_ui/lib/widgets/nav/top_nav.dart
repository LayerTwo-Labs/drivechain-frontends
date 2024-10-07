import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class QtTab extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool active;
  final VoidCallback onTap;

  const QtTab({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SailScaleButton(
        onPressed: onTap,
        pressed: active,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 2),
              SailText.primary12(
                label,
                color: active ? context.sailTheme.colors.primary : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
