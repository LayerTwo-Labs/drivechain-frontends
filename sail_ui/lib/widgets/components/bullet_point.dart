import 'package:flutter/material.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary13('\u2022  '),
          Expanded(child: SailText.secondary13(text)),
        ],
      ),
    );
  }
}
