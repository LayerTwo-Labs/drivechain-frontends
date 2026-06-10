import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class SailApp extends StatefulWidget {
  // This key is used to programmatically trigger a rebuild of the widget.
  static GlobalKey<SailAppState> sailAppKey = GlobalKey();
  final Future<void> Function(BuildContext context)? initMethod;
  final Color accentColor;
  final bool dense;
  final Logger log;

  final WidgetBuilder builder;

  SailApp({
    required this.builder,
    required this.accentColor,
    required this.log,
    required this.dense,
    this.initMethod,
  }) : super(key: sailAppKey);

  @override
  State<SailApp> createState() => SailAppState();

  static SailAppState of(BuildContext context) {
    final SailAppState? result = context.findAncestorStateOfType<SailAppState>();
    if (result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'SailAppState.of() called with a context that does not contain a SailApp.',
      ),
    ]);
  }
}

class SailAppState extends State<SailApp> with WidgetsBindingObserver {
  ClientSettings get settings => GetIt.I.get<ClientSettings>();

  late SailThemeData theme;
  SailThemeStyle _style = SailThemeStyle.sail;

  @override
  void initState() {
    theme = SailThemeData.darkTheme(
      SailColorScheme.orange,
      widget.dense,
      SailFontValues.inter,
    );
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(loadTheme());
    widget.initMethod?.call(context);
  }

  @override
  void didUpdateWidget(SailApp oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild theme if accent color changed
    if (oldWidget.accentColor != widget.accentColor) {
      theme = _themeDataFromTheme(theme.type, widget.dense, theme.font, _style);
      setState(() {});
    }
  }

  Future<void> loadTheme([SailThemeValues? themeToLoad]) async {
    final originalTheme = themeToLoad ?? (await settings.getValue(ThemeSetting())).value;
    SailThemeValues resolvedTheme = originalTheme;

    if (originalTheme == SailThemeValues.system) {
      resolvedTheme = PlatformDispatcher.instance.platformBrightness == Brightness.light
          ? SailThemeValues.light
          : SailThemeValues.dark;
    }

    // Load the current font setting
    final fontSetting = await settings.getValue(FontSetting());
    final font = fontSetting.value;

    _style = await _resolveStyle();
    theme = _themeDataFromTheme(resolvedTheme, widget.dense, font, _style);

    setState(() {});
    // Save the original theme preference, not the resolved one
    if (themeToLoad != null) {
      await settings.setValue(ThemeSetting(newValue: originalTheme));
    }
  }

  Future<void> loadFont([SailFontValues? fontToLoad]) async {
    fontToLoad ??= (await settings.getValue(FontSetting())).value;

    // Rebuild theme with new font but keep current theme type
    theme = _themeDataFromTheme(theme.type, widget.dense, fontToLoad, _style);

    setState(() {});
    await settings.setValue(FontSetting(newValue: fontToLoad));
  }

  /// Apply a theme style. With no argument, resolves the global style from
  /// BitwindowSettings (so sidechains follow what bitwindow set).
  Future<void> loadStyle([SailThemeStyle? styleToLoad]) async {
    _style = styleToLoad ?? await _resolveStyle();
    theme = _themeDataFromTheme(theme.type, widget.dense, theme.font, _style);
    setState(() {});
  }

  /// Read the global theme style from bitwindow's app-dir settings; falls back
  /// to 'sail' when bitwindow's settings are unreachable.
  Future<SailThemeStyle> _resolveStyle() async {
    try {
      if (GetIt.I.isRegistered<BitwindowClientSettings>()) {
        final bitwindowSettings = GetIt.I.get<BitwindowClientSettings>();
        final loaded = await bitwindowSettings.getValue(BitwindowSettingValue());
        return sailBundleForId(loaded.value.themeStyle).style;
      }
    } catch (_) {
      // Fall through to the default below.
    }
    return SailThemeStyle.sail;
  }

  SailThemeData _themeDataFromTheme(
    SailThemeValues themeType,
    bool dense,
    SailFontValues font, [
    SailThemeStyle style = SailThemeStyle.sail,
    Color? accentColor,
  ]) {
    final color = accentColor ?? widget.accentColor;
    switch (themeType) {
      case SailThemeValues.light:
        return SailThemeData.lightTheme(color, dense, font, style);
      case SailThemeValues.dark:
        return SailThemeData.darkTheme(color, dense, font, style);
      default:
        throw Exception('Could not get theme');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailTheme(data: theme, child: widget.builder(context));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
