import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

Future<T?> showThemedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) async {
  if (SailStyleValues.phoneLayout(context)) {
    return await _showDialogSheet<T>(context: context, builder: builder, barrierDismissible: barrierDismissible);
  }
  return await showDialog(
    context: context,
    // Black, not the theme background: on a light theme that washed the page
    // out instead of darkening it.
    barrierColor: SailColorScheme.black.withValues(alpha: 0.55),
    barrierDismissible: barrierDismissible,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: builder(context),
    ),
  );
}

/// Shows a plain [showDialog] on a desktop, and the same dialog as a sheet on a phone.
Future<T?> showSailDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  if (SailStyleValues.phoneLayout(context)) {
    return _showDialogSheet<T>(context: context, builder: builder, barrierDismissible: barrierDismissible);
  }
  return showDialog<T>(context: context, builder: builder, barrierDismissible: barrierDismissible);
}

Future<T?> _showDialogSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool barrierDismissible,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  return navigator.push<T>(
    _DialogSheetRoute<T>(
      context: context,
      builder: (context) => _DialogSheet(dismissible: barrierDismissible, child: builder(context)),
      barrierColor: SailColorScheme.black.withValues(alpha: 0.55),
      barrierDismissible: barrierDismissible,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
    ),
  );
}

/// A dialog route that slides its page up from the bottom edge.
class _DialogSheetRoute<T> extends DialogRoute<T> {
  _DialogSheetRoute({
    required super.context,
    required super.builder,
    required super.barrierColor,
    required super.barrierDismissible,
    required super.themes,
  }) : super(useSafeArea: false, animationStyle: const AnimationStyle(duration: Duration(milliseconds: 250)));

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slide = animation
        .drive(CurveTween(curve: Curves.easeOutCubic))
        .drive(Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero));
    return FadeTransition(
      opacity: animation,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: SlideTransition(position: slide, child: child),
      ),
    );
  }
}

/// Puts a dialog at the bottom edge at full width, with round top corners.
class _DialogSheet extends StatefulWidget {
  final bool dismissible;
  final Widget child;

  const _DialogSheet({required this.dismissible, required this.child});

  @override
  State<_DialogSheet> createState() => _DialogSheetState();
}

class _DialogSheetState extends State<_DialogSheet> {
  static const _closeDistance = 96.0;
  static const _closeVelocity = 700.0;

  double _drag = 0;

  void _update(DragUpdateDetails details) {
    setState(() => _drag = (_drag + details.delta.dy).clamp(0, double.infinity));
  }

  Future<void> _end(DragEndDetails details) async {
    if (_drag > _closeDistance || (details.primaryVelocity ?? 0) > _closeVelocity) {
      final closed = await Navigator.of(context).maybePop();
      if (closed || !mounted) {
        return;
      }
    }
    setState(() => _drag = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final media = MediaQuery.of(context);
    final top = BorderRadius.vertical(top: theme.chrome.radiusLarge.topLeft);
    return Theme(
      data: Theme.of(context).copyWith(
        dialogTheme: DialogThemeData(
          alignment: Alignment.bottomCenter,
          insetPadding: EdgeInsets.only(top: media.padding.top + SailStyleValues.padding32),
          constraints: BoxConstraints.tightFor(width: media.size.width),
          shape: RoundedRectangleBorder(borderRadius: top),
        ),
      ),
      child: SailSheetScope(
        child: GestureDetector(
          onVerticalDragUpdate: widget.dismissible ? _update : null,
          onVerticalDragEnd: widget.dismissible ? _end : null,
          child: Transform.translate(offset: Offset(0, _drag), child: widget.child),
        ),
      ),
    );
  }
}

/// Centers a dialog body that has no [Dialog] around it. In a phone sheet it sits at the bottom edge.
class SailDialogFrame extends StatelessWidget {
  final Widget child;

  const SailDialogFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: SailSheetScope.of(context) ? Alignment.bottomCenter : Alignment.center,
      child: child,
    );
  }
}

/// Marks content that shows in a bottom sheet. The first [SailCard] below it
/// draws as the sheet surface: round top corners and room for the bottom inset.
class SailSheetScope extends InheritedWidget {
  final bool active;

  const SailSheetScope({super.key, this.active = true, required super.child});

  /// True when the nearest scope marks a sheet surface that no card claimed yet.
  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<SailSheetScope>()?.active ?? false;

  @override
  bool updateShouldNotify(SailSheetScope oldWidget) => active != oldWidget.active;
}

Future<T?> infoDialog<T>({
  required BuildContext context,
  required String title,
  required String subtitle,
  required Future<void> Function() onConfirm,
}) async {
  return await _baseDialogSimple(
    context: context,
    title: title,
    subtitle: subtitle,
    onConfirm: onConfirm,
  );
}

Future<T?> successDialog<T>({
  required BuildContext context,
  required String action,
  required String title,
  required String subtitle,
}) async {
  return await _baseDialogSimple(
    context: context,
    title: title,
    subtitle: subtitle,
    onConfirm: null,
  );
}

Future<T?> errorDialog<T>({
  required BuildContext context,
  required String action,
  required String title,
  required String subtitle,
}) async {
  return await _baseDialogSimple(
    context: context,
    title: title,
    subtitle: subtitle,
    onConfirm: null,
  );
}

Future<T?> _baseDialogSimple<T>({
  required BuildContext context,
  required String title,
  required String subtitle,
  required Future<void> Function()? onConfirm,
}) async {
  final theme = SailTheme.of(context);

  return widgetDialog(
    context: context,
    title: title,
    child: SailColumn(
      spacing: SailStyleValues.padding12,
      mainAxisSize: MainAxisSize.min,
      children: [
        SailText.primary15(subtitle, color: theme.colors.textSecondary),
        DialogButtons(onPressed: onConfirm),
      ],
    ),
  );
}

Future<T?> widgetDialog<T>({
  required String title,
  required BuildContext context,
  required Widget child,
  String? subtitle,
  double maxWidth = 740,
  Color? color,
}) async {
  final theme = SailTheme.of(context);

  return showThemedDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: theme.colors.backgroundSecondary,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        // Unbounded height makes the card hug its content; taller content scrolls.
        child: SingleChildScrollView(
          child: SailCard(
            title: title,
            subtitle: subtitle,
            withCloseButton: true,
            color: color,
            child: child,
          ),
        ),
      ),
    ),
  );
}

class CardHeader extends StatelessWidget {
  final String title;
  final String? titleTooltip;
  final String? subtitle;
  final String? error;

  /// headerValue is the one figure the card is about. It reads between the
  /// title and the subtitle, in large type.
  final String? headerValue;

  const CardHeader({
    super.key,
    required this.title,
    this.titleTooltip,
    this.subtitle,
    this.error,
    this.headerValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding04,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailRow(
          spacing: SailStyleValues.padding04,
          children: [
            Flexible(child: SailText.primary16(title, bold: true)),
            if (titleTooltip != null) SailInfoIcon(title: title, message: titleTooltip!),
          ],
        ),
        if (headerValue != null) SailText.primary22(headerValue!, bold: true),
        if (error != null || subtitle != null)
          SailText.primary13(
            error ?? subtitle!,
            color: error != null ? SailColorScheme.red : theme.colors.textSecondary,
            overflow: TextOverflow.visible,
          ),
      ],
    );
  }
}

class DialogHeader extends StatelessWidget {
  final Future<void> Function() onClose;
  final String title;
  final String? subtitle;

  const DialogHeader({
    super.key,
    required this.onClose,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CardHeader(title: title, subtitle: subtitle),
        ),
        SailButton(
          variant: ButtonVariant.icon,
          icon: SailSVGAsset.iconClose,
          onPressed: onClose,
        ),
      ],
    );
  }
}

class DialogButtons extends StatelessWidget {
  final Future<void> Function()? onPressed;

  const DialogButtons({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        Expanded(child: Container()),
        SailButton(
          label: onPressed != null ? 'Cancel' : 'Close',
          variant: ButtonVariant.ghost,
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        if (onPressed != null)
          SailButton(
            label: 'Confirm',
            variant: ButtonVariant.primary,
            onPressed: onPressed!,
          ),
      ],
    );
  }
}

/// Bare modal container; the child supplies its own card/chrome.
class SailModal extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final BoxConstraints? constraints;

  const SailModal({
    super.key,
    required this.child,
    this.backgroundColor,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    // A modal hugs its contents; without this a column inside it stretches to
    // the full height of the screen.
    return Dialog(
      backgroundColor: backgroundColor ?? SailColorScheme.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flexible, so the child still learns the real height available. A bare
          // Column child gets unbounded height and overflows the dialog.
          Flexible(
            child: constraints != null ? ConstrainedBox(constraints: constraints!, child: child) : child,
          ),
        ],
      ),
    );
  }
}

/// A standardized dialog widget using Dialog + SailCard pattern
/// This provides consistent styling for dialogs across all applications
class SailDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? error;
  final Widget child;
  final List<Widget>? actions;
  final double maxWidth;
  final double maxHeight;
  final bool withCloseButton;
  final Color? color;

  const SailDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.error,
    required this.child,
    this.actions,
    this.maxWidth = 600,
    this.maxHeight = 600,
    this.withCloseButton = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: SailCard(
            title: title,
            subtitle: subtitle,
            error: error,
            withCloseButton: withCloseButton,
            color: color,
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                child,
                if (actions != null && actions!.isNotEmpty)
                  SailRow(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: SailStyleValues.padding08,
                    children: actions!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
