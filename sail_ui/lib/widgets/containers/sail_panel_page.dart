import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// The phone form of a full page form: one panel that scrolls, with the title at the left, then the body and the
/// actions.
class SailPanelPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? subtitleColor;

  /// An icon in front of the title.
  final Widget? leading;
  final List<Widget> children;

  /// The buttons under the body.
  final Widget? actions;

  const SailPanelPage({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.leading,
    this.children = const [],
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: theme.chrome.radiusLarge,
          color: theme.chrome.panel(theme.colors).color,
        ),
        child: Padding(
          padding: const EdgeInsets.all(SailStyleValues.padding16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  ?leading,
                  Expanded(child: SailText.primary18(title)),
                ],
              ),
              if (subtitle != null) ...[
                const SailSpacing(SailStyleValues.padding04),
                SailText.secondary13(subtitle!, color: subtitleColor),
              ],
              if (children.isNotEmpty) ...[
                const SailSpacing(SailStyleValues.padding16),
                ...children,
              ],
              if (actions != null) ...[
                const SailSpacing(SailStyleValues.padding20),
                actions!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
