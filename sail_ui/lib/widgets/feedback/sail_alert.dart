import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailAlertVariant { defaultVariant, destructive, warning, info, success }

class SailAlert extends StatelessWidget {
  final SailAlertVariant variant;
  final String? title;
  final String? description;
  final Widget? icon;
  final EdgeInsets padding;

  const SailAlert({
    super.key,
    this.variant = SailAlertVariant.defaultVariant,
    this.title,
    this.description,
    this.icon,
    this.padding = const EdgeInsets.all(16),
  }) : assert(
         title != null || description != null,
         'SailAlert requires title or description',
       );

  Color _semanticColor(SailThemeData theme) {
    switch (variant) {
      case SailAlertVariant.defaultVariant:
        return theme.colors.border;
      case SailAlertVariant.destructive:
        return theme.colors.error;
      case SailAlertVariant.warning:
        return theme.colors.orange;
      case SailAlertVariant.info:
        return theme.colors.info;
      case SailAlertVariant.success:
        return theme.colors.success;
    }
  }

  _AlertColors _resolveColors(SailThemeData theme) {
    if (theme.chrome.terminalStyle) {
      final semantic = _semanticColor(theme);
      return _AlertColors(
        background: theme.colors.backgroundSecondary,
        border: theme.colors.border,
        foreground: theme.colors.text,
        iconColor: semantic,
        leftAccent: semantic,
      );
    }
    switch (variant) {
      case SailAlertVariant.defaultVariant:
        return _AlertColors(
          background: theme.colors.background,
          border: theme.colors.border,
          foreground: theme.colors.text,
          iconColor: theme.colors.text,
        );
      case SailAlertVariant.destructive:
        return _AlertColors(
          background: theme.colors.background,
          border: theme.colors.error,
          foreground: theme.colors.error,
          iconColor: theme.colors.error,
        );
      case SailAlertVariant.warning:
        return _AlertColors(
          background: theme.colors.background,
          border: theme.colors.orange,
          foreground: theme.colors.orange,
          iconColor: theme.colors.orange,
        );
      case SailAlertVariant.info:
        return _AlertColors(
          background: theme.colors.background,
          border: theme.colors.info,
          foreground: theme.colors.info,
          iconColor: theme.colors.info,
        );
      case SailAlertVariant.success:
        return _AlertColors(
          background: theme.colors.background,
          border: theme.colors.success,
          foreground: theme.colors.success,
          iconColor: theme.colors.success,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final c = _resolveColors(theme);

    final body = <Widget>[];
    if (title != null) {
      body.add(
        Text(
          title!,
          style: SailStyleValues.thirteen.copyWith(
            color: c.foreground,
            fontWeight: SailStyleValues.boldWeight,
          ),
        ),
      );
    }
    if (description != null) {
      if (body.isNotEmpty) body.add(const SizedBox(height: 4));
      body.add(
        Text(
          description!,
          style: SailStyleValues.thirteen.copyWith(color: c.foreground),
        ),
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: body,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: theme.chrome.terminalStyle ? theme.chrome.radiusSmall : BorderRadius.circular(6),
        border: theme.chrome.terminalStyle && c.leftAccent != null
            ? Border(
                top: BorderSide(color: c.border),
                right: BorderSide(color: c.border),
                bottom: BorderSide(color: c.border),
                left: BorderSide(color: c.leftAccent!, width: 2),
              )
            : Border.all(color: c.border),
      ),
      child: icon == null
          ? content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconTheme.merge(
                  data: IconThemeData(color: c.iconColor, size: 16),
                  child: icon!,
                ),
                const SizedBox(width: 12),
                Expanded(child: content),
              ],
            ),
    );
  }
}

class _AlertColors {
  final Color background;
  final Color border;
  final Color foreground;
  final Color iconColor;
  final Color? leftAccent;
  _AlertColors({
    required this.background,
    required this.border,
    required this.foreground,
    required this.iconColor,
    this.leftAccent,
  });
}
