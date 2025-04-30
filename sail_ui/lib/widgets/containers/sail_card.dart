import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
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
  final NewWindowIdentifier? newWindowIdentifier;

  const SailCard({
    super.key,
    this.title,
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
    this.newWindowIdentifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SelectionArea(
      child: SailShadow(
        shadowSize: shadowSize,
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colors.border,
                width: 1.0,
              ),
              borderRadius: borderRadius ?? SailStyleValues.borderRadiusLarge,
              color: color ?? theme.colors.background,
            ),
            child: SizedBox(
              width: width,
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
                    if (title != null)
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
                                subtitle: subtitle,
                                error: error,
                              ),
                            ),
                            SailRow(
                              spacing: SailStyleValues.padding08,
                              children: [
                                if (widgetHeaderEnd != null) widgetHeaderEnd!,
                                if (newWindowIdentifier != null)
                                  SailButton(
                                    variant: ButtonVariant.icon,
                                    icon: SailSVGAsset.iconNewWindow,
                                    onPressed: () async {
                                      final window = await DesktopMultiWindow.createWindow(
                                        jsonEncode({
                                          'window_type': newWindowIdentifier!.windowType,
                                          'application_dir': newWindowIdentifier!.applicationDir.path,
                                          'log_file': newWindowIdentifier!.logFile.path,
                                        }),
                                      );
                                      await window.setFrame(const Offset(0, 0) & const Size(1280, 720));
                                      await window.center();
                                      await window.setTitle('UTXOs and Denials');
                                      await window.show();
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
                          ],
                        ),
                      )
                    else if (withCloseButton || newWindowIdentifier != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: SailRow(
                          spacing: SailStyleValues.padding08,
                          children: [
                            if (newWindowIdentifier != null)
                              SailButton(
                                variant: ButtonVariant.icon,
                                icon: SailSVGAsset.iconNewWindow,
                                onPressed: () async {
                                  final window = await DesktopMultiWindow.createWindow(
                                    jsonEncode({
                                      'window_type': newWindowIdentifier!.windowType,
                                      'application_dir': newWindowIdentifier!.applicationDir.path,
                                      'log_file': newWindowIdentifier!.logFile.path,
                                    }),
                                  );
                                  await window.setFrame(const Offset(0, 0) & const Size(1280, 720));
                                  await window.center();
                                  await window.setTitle('UTXOs and Denials');
                                  await window.show();
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
                    if (title != null) const SailSpacing(SailStyleValues.padding32),
                    Flexible(
                      child: child,
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
  final String? subtitle;
  final String? error;
  final Widget? headerEnd;
  final VoidCallback? onPressed;
  final Widget child;

  const SailCardSmall({
    super.key,
    this.title,
    this.subtitle,
    this.error,
    this.onPressed,
    this.headerEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: SailShadow(
        child: Material(
          borderRadius: SailStyleValues.borderRadius,
          color: Colors.transparent,
          child: SizedBox(
            child: Padding(
              padding: EdgeInsets.only(
                top: SailStyleValues.padding16,
                left: SailStyleValues.padding16,
                right: SailStyleValues.padding16,
                bottom: SailStyleValues.padding16,
              ),
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
                            subtitle: subtitle,
                            error: error,
                          ),
                        ),
                        if (headerEnd != null) headerEnd!,
                      ],
                    ),
                  ),
                  const SailSpacing(32),
                  Flexible(
                    child: child,
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

class SailAlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Future<void> Function() onConfirm;
  final ButtonVariant? confirmButtonVariant;

  const SailAlertCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
    this.confirmButtonVariant,
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
                label: 'Cancel',
                variant: ButtonVariant.ghost,
                onPressed: () async => Navigator.of(context).pop(),
              ),
              SailButton(
                label: 'Confirm',
                variant: confirmButtonVariant ?? ButtonVariant.secondary,
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

  const SailCardStats({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    this.bitcoinAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SelectionArea(
      child: SailShadow(
        shadowSize: ShadowSize.regular,
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colors.border,
                width: 1.0,
              ),
              borderRadius: SailStyleValues.borderRadiusLarge,
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
                          SailSVG.fromAsset(icon, color: theme.colors.inactiveNavText, width: 10),
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
                          if (bitcoinAmount) SailSVG.fromAsset(SailSVGAsset.bitcoin, color: theme.colors.text),
                          SailText.primary24(value, bold: true),
                        ],
                      ),
                    ),
                    const SailSpacing(SailStyleValues.padding10),
                    SailText.secondary12(subtitle, color: theme.colors.inactiveNavText),
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
