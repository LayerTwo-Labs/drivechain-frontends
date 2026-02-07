import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Represents an action entry in the recent actions list.
class ActionEntry {
  final Widget? avatar;
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback? onTap;

  const ActionEntry({
    this.avatar,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onTap,
  });
}

/// A single action entry tile with avatar, title, subtitle, and value.
class ActionEntryTile extends StatelessWidget {
  final ActionEntry entry;

  const ActionEntryTile({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    Widget content = SailRow(
      spacing: SailStyleValues.padding12,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (entry.avatar != null)
          SizedBox(
            width: 40,
            height: 40,
            child: entry.avatar,
          )
        else
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colors.backgroundSecondary,
              border: Border.all(color: theme.colors.border),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SailText.primary13(entry.title, bold: true),
              SailText.secondary12(entry.subtitle),
            ],
          ),
        ),
        SailText.primary13(entry.value, bold: true),
      ],
    );

    if (entry.onTap != null) {
      return InkWell(
        onTap: entry.onTap,
        borderRadius: SailStyleValues.borderRadius,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: SailStyleValues.padding08),
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: SailStyleValues.padding08),
      child: content,
    );
  }
}

/// A card displaying a list of recent actions.
class RecentActionsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ActionEntry> actions;
  final Widget? headerEnd;

  const RecentActionsCard({
    super.key,
    this.title = 'Recent Actions',
    this.subtitle,
    required this.actions,
    this.headerEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: title,
      subtitle: subtitle,
      widgetHeaderEnd: headerEnd,
      child: SailColumn(
        spacing: 0,
        withDivider: true,
        children: [
          for (final action in actions) ActionEntryTile(entry: action),
        ],
      ),
    );
  }
}
