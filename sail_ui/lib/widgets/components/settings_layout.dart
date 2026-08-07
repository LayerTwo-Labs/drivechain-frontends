import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// One entry in a settings side nav.
class SailSettingsSection {
  final String label;
  final WidgetBuilder builder;

  const SailSettingsSection({required this.label, required this.builder});
}

/// Settings shell: page header, side nav, and the selected section.
class SailSettingsScaffold extends StatelessWidget {
  final String subtitle;
  final List<SailSettingsSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSectionSelected;

  const SailSettingsScaffold({
    super.key,
    required this.subtitle,
    required this.sections,
    required this.selectedIndex,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final index = selectedIndex.clamp(0, sections.length - 1);

    return Container(
      color: theme.colors.background,
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailRow(
              spacing: SailStyleValues.padding12,
              children: [
                SailText.primary20('Settings', bold: true),
                SailText.secondary13(subtitle),
              ],
            ),
            const SailSpacing(SailStyleValues.padding12),
            SailSeparator(thickness: 1, color: theme.colors.divider),
            const SailSpacing(SailStyleValues.padding12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SideNav(
                    width: 160,
                    items: sections.map((s) => SideNavItem(label: s.label)).toList(),
                    selectedIndex: index,
                    onItemSelected: onSectionSelected,
                  ),
                  const SailSpacing(SailStyleValues.padding20),
                  Expanded(child: sections[index].builder(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable body of one settings section, holding [SailSettingsGroup]s.
class SailSettingsBody extends StatelessWidget {
  final List<Widget> children;

  /// Room for a [BottomActionBar] drawn over the body.
  final double bottomPadding;

  const SailSettingsBody({
    super.key,
    required this.children,
    this.bottomPadding = SailStyleValues.padding32,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SailColumn(
          spacing: SailStyleValues.padding20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// Titled panel holding [SailSettingsRow]s, divided by 1px lines.
class SailSettingsGroup extends StatelessWidget {
  final String? title;
  final String? description;
  final List<Widget> children;

  const SailSettingsGroup({
    super.key,
    this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Container(height: 1, color: theme.colors.divider));
      }
      rows.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          SailText.primary13(title!, bold: true),
          const SailSpacing(SailStyleValues.padding04),
        ],
        if (description != null) ...[
          SailText.secondary12(description!),
          const SailSpacing(SailStyleValues.padding08),
        ],
        ClipRRect(
          borderRadius: theme.chrome.radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colors.border),
              borderRadius: theme.chrome.radius,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
          ),
        ),
      ],
    );
  }
}

/// One setting: label and optional description on the left, control on the
/// right. [child] puts a wide control on its own line below.
class SailSettingsRow extends StatelessWidget {
  final String label;
  final String? description;
  final Color? descriptionColor;
  final Widget? leading;
  final Widget? trailing;
  final Widget? child;
  final bool destructive;
  final VoidCallback? onTap;

  const SailSettingsRow({
    super.key,
    required this.label,
    this.description,
    this.descriptionColor,
    this.leading,
    this.trailing,
    this.child,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    final head = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SailSpacing(SailStyleValues.padding12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary13(label, color: destructive ? theme.colors.error : null),
              if (description != null) ...[
                const SailSpacing(2),
                SailText.secondary12(description!, color: descriptionColor),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SailSpacing(SailStyleValues.padding16), trailing!],
      ],
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding10,
      ),
      child: child == null
          ? head
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                head,
                const SailSpacing(SailStyleValues.padding08),
                child!,
              ],
            ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, child: content);
  }
}
