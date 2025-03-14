import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/nav/top_nav.dart';

class NavEntry extends StatefulWidget {
  final String title;
  final SailSVGAsset icon;

  final bool selected;
  final Future<void> Function() onPressed;

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
              vertical: SailStyleValues.padding04,
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
  final List<QtTab> subs;

  const NavContainer({
    super.key,
    required this.title,
    required this.subs,
  });

  @override
  Widget build(BuildContext context) {
    return SailPadding(
      padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding08),
      child: SailColumn(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SailSpacing(SailStyleValues.padding08 / 2),
          SailText.secondary12(title),
          const SailSpacing(SailStyleValues.padding08),
          SailRow(
            spacing: 0,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final sub in subs) sub,
            ],
          ),
        ],
      ),
    );
  }
}
