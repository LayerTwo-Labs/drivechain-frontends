import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary13(label),
        const SizedBox(width: 16),
        Flexible(
          child: SailText.secondary13(
            value,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
