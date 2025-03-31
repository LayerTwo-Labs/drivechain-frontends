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

class SailRawCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? error;
  final Widget? header;
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

  const SailRawCard({
    super.key,
    this.title,
    this.subtitle,
    this.error,
    this.header,
    this.onPressed,
    this.padding = true,
    this.bottomPadding = true,
    this.widgetHeaderEnd,
    required this.child,
    this.width = double.infinity,
    this.color,
    this.borderRadius,
    this.shadowSize = ShadowSize.small,
    this.secondary = false,
    this.withCloseButton = false,
    this.inSeparateWindow = false,
    this.newWindowIdentifier,
  }) : assert(!(header != null && title != null), 'Cannot set both title and header');

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SelectionArea(
      child: SailShadow(
        shadowSize: shadowSize,
        child: Material(
          borderRadius: borderRadius ?? SailStyleValues.borderRadius,
          color: color ?? (secondary ? theme.colors.background : theme.colors.backgroundSecondary),
          clipBehavior: Clip.hardEdge,
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
                  if (header != null)
                    SailRow(
                      spacing: 0,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(child: header!),
                        SailRow(
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
                                  await window.setTitle(title ?? '');
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
                    )
                  else if (title != null)
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
                  if (title != null) const SailSpacing(SailStyleValues.padding16),
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
