import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class DashboardGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  final Widget? widgetTrailing;
  final Widget? widgetEnd;

  const DashboardGroup({
    super.key,
    required this.title,
    required this.children,
    this.widgetTrailing,
    this.widgetEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: 0,
      withDivider: true,
      children: [
        Container(
          height: 36,
          color: theme.colors.actionHeader,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 05, horizontal: 30),
            child: Row(
              children: [
                SailRow(
                  spacing: SailStyleValues.padding10,
                  children: [
                    SailText.primary13(
                      title,
                      bold: true,
                    ),
                    if (widgetTrailing != null) widgetTrailing!,
                  ],
                ),
                Expanded(child: Container()),
                if (widgetEnd != null) widgetEnd!,
              ],
            ),
          ),
        ),
        for (final child in children) child,
      ],
    );
  }
}
