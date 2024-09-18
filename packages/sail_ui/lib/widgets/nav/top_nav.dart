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
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? Colors.grey.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 2),
              SailText.primary12(label),
            ],
          ),
        ),
      ),
    );
  }
}
