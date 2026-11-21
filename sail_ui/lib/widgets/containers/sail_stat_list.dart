import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// A panel of stat rows with a divider between each row. The phone form of a row of stat cards.
class SailStatList extends StatelessWidget {
  final List<Widget> children;

  /// False drops the panel and its padding, for rows inside a card that has its own panel.
  final bool panel;

  const SailStatList({super.key, required this.children, this.panel = true});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final rows = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) Container(height: 1, color: theme.colors.divider),
          children[i],
        ],
      ],
    );
    if (!panel) {
      return rows;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: theme.chrome.radiusLarge,
        color: theme.chrome.panel(theme.colors).color,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: rows,
      ),
    );
  }
}

/// One stat in a [SailStatList]: the title and subtitle at the left, the value at the right.
class SailStatRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final LoadingDetails? loading;
  final Color? valueColor;

  const SailStatRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    this.loading,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.primary13(title, bold: true),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  SailText.secondary12(subtitle),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          SailSkeletonizer(
            description: loading?.description ?? '',
            enabled: loading?.enabled ?? false,
            child: SailText.primary15(value, bold: true, color: valueColor),
          ),
        ],
      ),
    );
  }
}
