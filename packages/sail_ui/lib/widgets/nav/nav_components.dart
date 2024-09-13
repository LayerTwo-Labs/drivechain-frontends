import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class NavEntry extends StatefulWidget {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SailStyleValues.padding08,
              vertical: SailStyleValues.padding05,
            ),
            child: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.icon(widget.icon),
                if (widget.title != '')
                  mouseIsOver || widget.selected
                      ? SailText.primary12(widget.title, bold: true)
                      : SailText.secondary12(widget.title, bold: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavContainer extends StatelessWidget {
  final String title;
  final List<NavEntry> subs;

  const NavContainer({
    super.key,
    required this.title,
    required this.subs,
  });

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding10,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SailText.secondary12(title),
        SailRow(
          spacing: 0,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final sub in subs) sub,
          ],
        ),
      ],
    );
  }
}
