import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// One line of a send summary: the label on the left, the value on the right.
class SummaryLine extends StatelessWidget {
  final String label;
  final Widget value;
  final bool bold;

  const SummaryLine({super.key, required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        bold ? SailText.primary13(label, bold: true) : SailText.secondary13(label),
        const SizedBox(width: SailStyleValues.padding08),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: value),
        ),
      ],
    );
  }
}
