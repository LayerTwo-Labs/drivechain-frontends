import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class QtTab extends StatelessWidget {
  final String label;
  final SailSVGAsset icon;
  final bool active;
  final bool end;
  final VoidCallback onTap;

  const QtTab({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.end = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: active ? theme.colors.backgroundSecondary : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: theme.colors.formFieldBorder,
                  width: 2,
                ),
                top: BorderSide(
                  color: active ? Colors.transparent : theme.colors.formFieldBorder,
                  width: 2,
                ),
                right: end
                    ? BorderSide(
                        color: theme.colors.formFieldBorder,
                        width: 2,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: SailStyleValues.padding08,
                horizontal: SailStyleValues.padding25,
              ),
              child: SailColumn(
                mainAxisSize: MainAxisSize.max,
                spacing: 0,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SailSVG.fromAsset(
                    icon,
                    width: 24,
                    color: theme.colors.text,
                  ),
                  Expanded(child: Container()),
                  SailText.primary12(
                    label,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
