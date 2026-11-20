import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

SailApp buildSailWindowApp(
  Logger log,
  String windowTitle,
  Widget child,
  Color accentColor,
) {
  return SailApp(
    log: log,
    dense: true,
    builder: (context) => MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
        fontFamily: SailTheme.of(context).chrome.textFamily(),
      ),
      home: SailWindowScaffold(title: windowTitle, child: child),
    ),
    accentColor: accentColor,
  );
}

/// A sub-window page: a title bar over [child]. With [onBack], the bar has a back button.
class SailWindowScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onBack;

  const SailWindowScaffold({super.key, required this.title, required this.child, this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: onBack == null ? 26 : 48,
              color: colors.backgroundSecondary,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (onBack != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SailButton(
                        variant: ButtonVariant.icon,
                        icon: SailSVGAsset.chevronLeft,
                        onPressed: () async => onBack!(),
                      ),
                    ),
                  SailText.primary13(title),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
