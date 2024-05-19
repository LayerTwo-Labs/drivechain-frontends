import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class NavEntry extends StatefulWidget {
  final String title;

  final bool selected;
  final VoidCallback onPressed;

  final SailSVGAsset? icon;

  const NavEntry({
    super.key,
    required this.title,
    required this.selected,
    required this.onPressed,
    this.icon,
  });

  @override
  State<NavEntry> createState() => _NavEntryState();
}

class _NavEntryState extends State<NavEntry> {
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
              if (widget.icon != null) SailSVG.icon(widget.icon!, width: 0, height: 16),
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
    );
  }
}

class SubNavEntryContainer extends StatelessWidget {
  final bool open;
  final List<NavEntry> subs;

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
            for (final sub in subs) sub,
          ],
        ),
      ),
    );
  }
}
