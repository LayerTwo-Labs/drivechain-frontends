import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class StatRow extends StatelessWidget {
  final String label;
  final String value;

  const StatRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final phone = SailStyleValues.phoneLayout(context);
    return Padding(
      padding: EdgeInsets.only(bottom: phone ? 4 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [SailText.secondary13(label), if (phone) SailText.primary13(value) else SailText.primary15(value)],
      ),
    );
  }
}

class StatSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const StatSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    if (SailStyleValues.phoneLayout(context)) {
      final theme = SailTheme.of(context);
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: theme.chrome.radiusLarge,
          color: theme.chrome.panel(theme.colors).color,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SailText.primary15(title, bold: true),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      );
    }
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
