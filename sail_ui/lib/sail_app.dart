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

  /// The saved look, read before the first frame. When null, the app reads it after the first frame.
  final SailAppLook? look;

  SailApp({
    required this.builder,
    required this.accentColor,
    required this.log,
    required this.dense,
    this.initMethod,
    this.look,
  }) : super(key: sailAppKey);

  @override
  State<SailApp> createState() => SailAppState();

  static SailAppState of(BuildContext context) {
    final SailAppState? result = context.findAncestorStateOfType<SailAppState>();
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'SailAppState.of() called with a context that does not contain a SailApp.',
      ),
    ]);
  }
}

/// The saved theme, font, font scale and style of an app.
class SailAppLook {
  final SailThemeValues theme;
  final SailFontValues font;
  final double fontScale;
  final SailThemeStyle style;

  const SailAppLook({required this.theme, required this.font, required this.fontScale, required this.style});

  /// Reads the saved look. [theme] replaces the saved theme.
  static Future<SailAppLook> load({SailThemeValues? theme}) async {
    final settings = GetIt.I.get<ClientSettings>();
    var resolved = theme ?? (await settings.getValue(ThemeSetting())).value;
    if (resolved == SailThemeValues.system) {
      resolved = PlatformDispatcher.instance.platformBrightness == Brightness.light
          ? SailThemeValues.light
          : SailThemeValues.dark;
    }
    return SailAppLook(
      theme: resolved,
      font: (await settings.getValue(FontSetting())).value,
      fontScale: (await settings.getValue(FontScaleSetting())).value,
      style: await _resolveStyle(),
    );
  }
}

/// Read the global theme style from bitwindow's app-dir settings; falls back
/// to the default style when bitwindow's settings are unreachable.
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
  return sailBundleForId(defaultThemeStyleId).style;
}

/// Applies the user's font scale on top of the platform's own text scaling
/// rather than replacing it, so OS accessibility settings survive.
class _ScaledTextScaler extends TextScaler {
  const _ScaledTextScaler(this.platform, this.factor);

  final TextScaler platform;
  final double factor;

  @override
  double scale(double fontSize) => platform.scale(fontSize * factor);

  @override
  // ignore: deprecated_member_override, deprecated_member_use
  double get textScaleFactor => platform.textScaleFactor * factor;

  @override
  bool operator ==(Object other) => other is _ScaledTextScaler && other.platform == platform && other.factor == factor;

  @override
  int get hashCode => Object.hash(platform, factor);
}

class SailAppState extends State<SailApp> with WidgetsBindingObserver {
  ClientSettings get settings => GetIt.I.get<ClientSettings>();

  late SailThemeData theme;
  SailThemeStyle _style = SailThemeStyle.bitwindowV2;
  double _fontScale = 1.0;

  @override
  void initState() {
    theme = SailThemeData.darkTheme(
      SailColorScheme.orange,
      widget.dense,
      SailFontValues.inter,
      _style,
    );
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final look = widget.look;
    if (look != null) {
      _applyLook(look);
    } else {
      unawaited(loadTheme());
    }
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
    _applyLook(await SailAppLook.load(theme: themeToLoad));

    setState(() {});
    // Save the original theme preference, not the resolved one
    if (themeToLoad != null) {
      await settings.setValue(ThemeSetting(newValue: themeToLoad));
    }
  }

  void _applyLook(SailAppLook look) {
    _fontScale = look.fontScale;
    _style = look.style;
    theme = _themeDataFromTheme(look.theme, widget.dense, look.font, _style);
  }

  Future<void> loadFont([SailFontValues? fontToLoad]) async {
    fontToLoad ??= (await settings.getValue(FontSetting())).value;

    // Rebuild theme with new font but keep current theme type
    theme = _themeDataFromTheme(theme.type, widget.dense, fontToLoad, _style);

    setState(() {});
    await settings.setValue(FontSetting(newValue: fontToLoad));
  }

  /// Applies a font scale. Persistence belongs to
  /// [SettingsProvider.updateFontScale], which serializes writes — a second
  /// writer here would race it on every slider drag.
  Future<void> loadFontScale([double? scaleToLoad]) async {
    scaleToLoad ??= (await settings.getValue(FontScaleSetting())).value;

    _fontScale = nearestSailFontScale(scaleToLoad);
    setState(() {});
  }

  /// Apply a theme style. With no argument, resolves the global style from
  /// BitwindowSettings (so sidechains follow what bitwindow set).
  Future<void> loadStyle([SailThemeStyle? styleToLoad]) async {
    _style = styleToLoad ?? await _resolveStyle();
    theme = _themeDataFromTheme(theme.type, widget.dense, theme.font, _style);
    setState(() {});
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
    final platformScaler = MediaQuery.textScalerOf(context);
    return SailTheme(
      data: theme,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: _fontScale == 1.0 ? platformScaler : _ScaledTextScaler(platformScaler, _fontScale),
        ),
        child: Builder(builder: widget.builder),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
