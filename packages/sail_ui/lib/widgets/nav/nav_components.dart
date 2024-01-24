import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class TopNavEntry extends StatelessWidget {
  final String title;
  final SailSVGAsset icon;

  final bool selected;
  final VoidCallback onPressed;

  const TopNavEntry({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailScaleButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? theme.colors.actionHeader : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SailStyleValues.padding08,
            vertical: SailStyleValues.padding05,
          ),
          child: SailRow(
            spacing: SailStyleValues.padding10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SailSVG.icon(icon, width: 0, height: 16),
              SailText.secondary12(title, bold: true),
            ],
          ),
        ),
      ),
    );
  }
}

class NavCategory extends StatelessWidget {
  final String category;

  const NavCategory({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: SailStyleValues.padding05,
        top: SailStyleValues.padding15,
      ),
      child: SailText.secondary15(category),
    );
  }
}

class NavEntry extends StatelessWidget {
  final String title;
  final SailSVGAsset icon;

  final bool selected;
  final VoidCallback onPressed;

  const NavEntry({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 187),
      child: SailScaleButton(
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
          decoration: BoxDecoration(
            color: selected ? theme.colors.actionHeader : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding08,
              vertical: SailStyleValues.padding05,
            ),
            child: SailRow(
              spacing: SailStyleValues.padding10,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SailSVG.icon(icon, width: 16),
                SailText.secondary12(title, bold: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubNavEntry extends StatefulWidget {
  final String title;

  final bool selected;
  final VoidCallback onPressed;

  const SubNavEntry({
    super.key,
    required this.title,
    required this.selected,
    required this.onPressed,
  });

  @override
  State<SubNavEntry> createState() => _SubNavEntryState();
}

class _SubNavEntryState extends State<SubNavEntry> {
  bool mouseIsOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          mouseIsOver = true;
        });
      },
      onExit: (_) {
        setState(() {
          mouseIsOver = false;
        });
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 163, maxWidth: 163),
        child: SailScaleButton(
          onPressed: widget.onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.selected ? theme.colors.actionHeader : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SailColumn(
              spacing: 0,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SailStyleValues.padding08,
                    vertical: SailStyleValues.padding05,
                  ),
                  child: mouseIsOver || widget.selected
                      ? SailText.primary12(widget.title, bold: true)
                      : SailText.secondary12(widget.title, bold: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubNavEntryContainer extends StatelessWidget {
  final bool open;
  final List<SubNavEntry> subs;

  const SubNavEntryContainer({
    super.key,
    required this.open,
    required this.subs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (!open) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: SailStyleValues.padding15,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: theme.colors.divider,
              width: 1.0,
            ),
          ),
        ),
        child: SailRow(
          spacing: 0,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SailSpacing(SailStyleValues.padding08),
            Column(
              children: [
                for (final sub in subs) sub,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
