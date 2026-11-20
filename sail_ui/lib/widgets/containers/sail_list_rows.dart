import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// A two-line row for a [SailStatList]: the title over the subtitle at the left, [trailing] at the right.
class SailListRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final Widget? trailing;

  const SailListRow({
    super.key,
    required this.title,
    this.subtitle = '',
    this.subtitleColor,
    this.trailing,
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
                  SailText.secondary12(subtitle, color: subtitleColor),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// A label at the left and its value at the right, for a [SailStatList].
class SailValueRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  /// A control after the value, such as a copy button.
  final Widget? action;

  const SailValueRow({super.key, required this.label, required this.value, this.valueColor, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SailText.secondary13(label),
          const SizedBox(width: 16),
          Expanded(
            child: SailText.primary13(
              value,
              color: valueColor,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action!,
          ],
        ],
      ),
    );
  }
}

/// A label with [action] on its line, and the full value under it, for a [SailStatList].
class SailStackedValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;

  /// Shows the label in the primary text color, medium weight.
  final bool strongLabel;

  /// A control at the right of the label, such as a copy button.
  final Widget? action;

  const SailStackedValueRow({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
    this.strongLabel = false,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: strongLabel ? SailText.primary13(label, bold: true) : SailText.secondary13(label),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 4),
          SailText.secondary12(value, monospace: monospace),
        ],
      ),
    );
  }
}

/// A lazy list of rows with a divider between each row, for rows inside a card that already draws the panel.
class SailDividedList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool shrinkWrap;

  const SailDividedList({super.key, required this.itemCount, required this.itemBuilder, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context) {
    final divider = SailTheme.of(context).colors.divider;
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: (context, index) => Container(height: 1, color: divider),
    );
  }
}
