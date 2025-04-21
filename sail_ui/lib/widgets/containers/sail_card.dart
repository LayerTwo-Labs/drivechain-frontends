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
          color: theme.colors.background,
          clipBehavior: Clip.hardEdge,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colors.border,
                width: 1.0,
              ),
              borderRadius: borderRadius ?? SailStyleValues.borderRadiusLarge,
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

  const SailAlertCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
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
                variant: ButtonVariant.secondary,
                onPressed: onConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
