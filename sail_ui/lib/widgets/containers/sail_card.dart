import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class NewWindowIdentifier {
  final String windowType;
  final Directory applicationDir;
  final File logFile;

  const NewWindowIdentifier({
    required this.windowType,
    required this.applicationDir,
    required this.logFile,
  });
}

class SailCard extends StatelessWidget {
  final String? title;
  final String? titleTooltip;
  final String? subtitle;
  final String? error;
  final VoidCallback? onPressed;
  final bool padding;
  final bool bottomPadding;
  final Widget child;
  final Widget? widgetHeaderEnd;
  final double? width;
  final Color? color;
  final BorderRadius? borderRadius;
  final ShadowSize shadowSize;
  final bool secondary;
  final bool withCloseButton;
  final bool inSeparateWindow;
  final SailWindow? newWindow;

  const SailCard({
    super.key,
    this.title,
    this.titleTooltip,
    this.subtitle,
    this.error,
    this.onPressed,
    this.padding = true,
    this.bottomPadding = true,
    this.widgetHeaderEnd,
    required this.child,
    this.width = double.infinity,
    this.color,
    this.borderRadius,
    this.shadowSize = ShadowSize.regular,
    this.secondary = false,
    this.withCloseButton = false,
    this.inSeparateWindow = false,
    this.newWindow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final radius = borderRadius ?? theme.chrome.radiusLarge;

    return _build(context, theme, radius);
  }

  Widget _build(BuildContext context, SailThemeData theme, BorderRadius radius) {
    return SelectionArea(
      child: SailShadow(
        shadowSize: shadowSize,
        child: ClipRRect(
          borderRadius: radius,
          child: DecoratedBox(
            decoration: theme.chrome.bevel != null
                ? theme.chrome.panel(theme.colors)
                : BoxDecoration(
                    border: Border.all(color: theme.colors.border, width: 1.0),
                    borderRadius: radius,
                    color: color ?? theme.colors.background,
                  ),
            child: SizedBox(
              width: width,
              // A flex child (the Flexible content below) is illegal under an
              // unbounded height, e.g. inside a SingleChildScrollView. The
              // LimitedBox bounds the column for the flex algorithm; loose flex
              // + MainAxisSize.min still shrink-wraps to the natural height, so
              // the limit only has to exceed any real content. Replaces a
              // LayoutBuilder, which threw when SailCard sat in IntrinsicHeight.
              child: LimitedBox(
                maxHeight: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // win95-style window header: full-width gradient bar
                    if (theme.chrome.beveled && title != null)
                      Container(
                        height: 33,
                        padding: const EdgeInsets.only(left: 8),
                        decoration: theme.chrome.titleBar(theme.colors),
                        child: Row(
                          children: [
                            Expanded(
                              child: SailText.primary15(
                                title!,
                                bold: true,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                            if (widgetHeaderEnd != null) widgetHeaderEnd!,
                            if (newWindow != null)
                              SailButton(
                                variant: ButtonVariant.icon,
                                icon: SailSVGAsset.iconNewWindow,
                                onPressed: () async {
                                  final windowProvider = GetIt.I.get<WindowProvider>();
                                  await windowProvider.open(newWindow!);
                                },
                              ),
                            if (withCloseButton)
                              SailButton(
                                variant: ButtonVariant.icon,
                                icon: SailSVGAsset.iconClose,
                                onPressed: () async => Navigator.of(context).pop(),
                              ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    // The outer min-height Column hands non-flex children
                    // unbounded max height, so the content section must be a
                    // flex child for the card's own bounds to reach the inner
                    // Column. Loose fit keeps the card shrink-wrapping its content.
                    Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: padding
                            ? EdgeInsets.only(
                                top: inSeparateWindow ? SailStyleValues.padding32 : SailStyleValues.padding16,
                                left: SailStyleValues.padding16,
                                right: SailStyleValues.padding16,
                                bottom: bottomPadding ? SailStyleValues.padding16 : 0,
                              )
                            : EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (theme.chrome.beveled && title != null && (subtitle != null || error != null))
                              SailText.primary12(
                                error ?? subtitle!,
                                color: error != null ? theme.colors.error : theme.colors.inactiveNavText,
                                overflow: TextOverflow.visible,
                              ),
                            if (title != null && !theme.chrome.beveled)
                              SizedBox(
                                width: double.infinity,
                                child: SailRow(
                                  spacing: 0,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: CardHeader(
                                        title: title!,
                                        titleTooltip: titleTooltip,
                                        subtitle: subtitle,
                                        error: error,
                                      ),
                                    ),
                                    SailRow(
                                      spacing: SailStyleValues.padding08,
                                      children: [
                                        if (widgetHeaderEnd != null) widgetHeaderEnd!,
                                        if (newWindow != null)
                                          SailTooltip(
                                            message: 'Open in a new window',
                                            child: SailButton(
                                              variant: ButtonVariant.icon,
                                              icon: SailSVGAsset.iconNewWindow,
                                              onPressed: () async {
                                                final windowProvider = GetIt.I.get<WindowProvider>();
                                                await windowProvider.open(newWindow!);
                                              },
                                            ),
                                          ),
                                        if (withCloseButton)
                                          SailButton(
                                            variant: ButtonVariant.icon,
                                            icon: SailSVGAsset.iconClose,
                                            onPressed: () async => Navigator.of(context).pop(),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            else if ((withCloseButton || newWindow != null) && !(theme.chrome.beveled && title != null))
                              Align(
                                alignment: Alignment.centerRight,
                                child: SailRow(
                                  spacing: SailStyleValues.padding08,
                                  children: [
                                    if (newWindow != null)
                                      SailButton(
                                        variant: ButtonVariant.icon,
                                        icon: SailSVGAsset.iconNewWindow,
                                        onPressed: () async {
                                          final windowProvider = GetIt.I.get<WindowProvider>();
                                          await windowProvider.open(newWindow!);
                                        },
                                      ),
                                    if (withCloseButton)
                                      SailButton(
                                        variant: ButtonVariant.icon,
                                        icon: SailSVGAsset.iconClose,
                                        onPressed: () async => Navigator.of(context).pop(),
                                      ),
                                  ],
                                ),
                              ),
                            if (title != null) const SailSpacing(SailStyleValues.padding08),
                            Flexible(fit: FlexFit.loose, child: child),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SailCardSmall extends StatelessWidget {
  final String? title;
  final String? titleTooltip;
  final String? subtitle;
  final String? error;
  final Widget? headerEnd;
  final VoidCallback? onPressed;
  final Widget child;

  const SailCardSmall({
    super.key,
    this.title,
    this.titleTooltip,
    this.subtitle,
    this.error,
    this.onPressed,
    this.headerEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return _build(context, theme);
  }

  Widget _build(BuildContext context, SailThemeData theme) {
    return SelectionArea(
      child: SailShadow(
        child: ClipRRect(
          borderRadius: theme.chrome.radius,
          child: SizedBox(
            child: Padding(
              padding: EdgeInsets.only(
                top: SailStyleValues.padding16,
                left: SailStyleValues.padding16,
                right: SailStyleValues.padding16,
                bottom: SailStyleValues.padding16,
              ),
              // See SailCard._build: bounds the column so the Flexible content
              // is legal under unbounded height while still shrink-wrapping.
              child: LimitedBox(
                maxHeight: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SailRow(
                        spacing: 0,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: CardHeader(
                              title: title!,
                              titleTooltip: titleTooltip,
                              subtitle: subtitle,
                              error: error,
                            ),
                          ),
                          if (headerEnd != null) headerEnd!,
                        ],
                      ),
                    ),
                    const SailSpacing(32),
                    Flexible(fit: FlexFit.loose, child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SailAlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Future<void> Function() onConfirm;
  final Future<void> Function()? onCancel;
  final ButtonVariant? confirmButtonVariant;
  final String? loadingLabel;
  final String confirmText;
  final String cancelText;

  const SailAlertCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
    this.onCancel,
    this.confirmButtonVariant,
    this.loadingLabel,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 512,
        child: SailCard(
          title: title,
          subtitle: subtitle,
          child: SailRow(
            spacing: SailStyleValues.padding08,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              SailButton(
                label: cancelText,
                variant: ButtonVariant.ghost,
                onPressed: () async {
                  if (onCancel != null) {
                    await onCancel!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              SailButton(
                label: confirmText,
                variant: confirmButtonVariant ?? ButtonVariant.secondary,
                loadingLabel: loadingLabel,
                loading: loadingLabel != null,
                onPressed: () async {
                  await onConfirm();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SailCardStats extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final SailSVGAsset icon;
  final bool bitcoinAmount;
  final LoadingDetails? loading;

  const SailCardStats({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    this.bitcoinAmount = false,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SelectionArea(
      child: SailShadow(
        shadowSize: ShadowSize.regular,
        child: ClipRRect(
          borderRadius: theme.chrome.radiusLarge,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colors.border, width: 1.0),
              borderRadius: theme.chrome.radiusLarge,
              color: theme.colors.background,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SailRow(
                        spacing: 0,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.primary13(title, bold: true),
                          SailSVG.fromAsset(
                            icon,
                            color: theme.colors.inactiveNavText,
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: SailRow(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (bitcoinAmount)
                            SailSVG.fromAsset(
                              SailSVGAsset.bitcoin,
                              color: theme.colors.text,
                            ),
                          SailSkeletonizer(
                            description: loading?.description ?? '',
                            enabled: loading?.enabled ?? false,
                            child: SailText.primary24(value, bold: true),
                          ),
                        ],
                      ),
                    ),
                    const SailSpacing(SailStyleValues.padding10),
                    SailSkeletonizer(
                      description: loading?.description ?? '',
                      enabled: loading?.enabled ?? false,
                      child: SailText.secondary12(
                        subtitle,
                        color: theme.colors.inactiveNavText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditField {
  final String name;
  String currentValue;

  EditField({required this.name, required this.currentValue});
}

class SailCardEditValues extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<EditField> fields;
  final void Function(List<EditField> updatedFields) onSave;

  const SailCardEditValues({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.onSave,
  });

  @override
  State<SailCardEditValues> createState() => _SailCardEditValuesState();
}

class _SailCardEditValuesState extends State<SailCardEditValues> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = widget.fields.map((field) => TextEditingController(text: field.currentValue)).toList();
    for (var controller in controllers) {
      controller.addListener(setTheState);
    }
  }

  void setTheState() {
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.removeListener(setTheState);
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: widget.title,
      subtitle: widget.subtitle,
      withCloseButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(widget.fields.length, (i) {
            final field = widget.fields[i];
            return SailRow(
              spacing: 16,
              children: [
                SailText.primary13(field.name, bold: true),
                Expanded(
                  child: SailTextField(
                    controller: controllers[i],
                    hintText: '',
                    autofocus: i == 0,
                  ),
                ),
              ],
            );
          }),
          const SailSpacing(SailStyleValues.padding16),
          Align(
            alignment: Alignment.centerRight,
            child: SailButton(
              label: 'Save changes',
              onPressed: () async {
                final updatedFields = List<EditField>.generate(
                  widget.fields.length,
                  (i) => EditField(
                    name: widget.fields[i].name,
                    currentValue: controllers[i].text,
                  ),
                );
                widget.onSave(updatedFields);
              },
            ),
          ),
        ],
      ),
    );
  }
}
