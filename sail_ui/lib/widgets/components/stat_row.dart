import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class StatRow extends StatelessWidget {
  final String label;
  final String value;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary13(label),
          SailText.primary15(value),
        ],
      ),
    );
  }
}

class StatSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const StatSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20(title),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
