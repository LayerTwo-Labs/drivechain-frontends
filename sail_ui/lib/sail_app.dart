import 'dart:async';

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

  SailApp({required this.builder, required this.accentColor, required this.log, required this.dense, this.initMethod})
    : super(key: sailAppKey);

  @override
  State<SailApp> createState() => SailAppState();

  static SailAppState of(BuildContext context) {
    final SailAppState? result = context.findAncestorStateOfType<SailAppState>();
    if (result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('SailAppState.of() called with a context that does not contain a SailApp.'),
    ]);
  }
}

class SailAppState extends State<SailApp> with WidgetsBindingObserver {
  ClientSettings get settings => GetIt.I.get<ClientSettings>();

  late SailThemeData theme;

  @override
  void initState() {
    theme = SailThemeData.darkTheme(SailColorScheme.orange, widget.dense);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(loadTheme());
    widget.initMethod?.call(context);
  }

  Future<void> loadTheme([SailThemeValues? themeToLoad]) async {
    themeToLoad ??= (await settings.getValue(ThemeSetting())).value;
    if (themeToLoad == SailThemeValues.system) {
      // ignore: deprecated_member_use
      themeToLoad = WidgetsBinding.instance.window.platformBrightness == Brightness.light
          ? SailThemeValues.light
          : SailThemeValues.dark;
    }

    theme = _themeDataFromTheme(themeToLoad, widget.dense);

    setState(() {});
    await settings.setValue(ThemeSetting(newValue: themeToLoad));
  }

  SailThemeData _themeDataFromTheme(SailThemeValues theme, bool dense) {
    switch (theme) {
      case SailThemeValues.light:
        return SailThemeData.lightTheme(widget.accentColor, dense);
      case SailThemeValues.dark:
        return SailThemeData.darkTheme(widget.accentColor, dense);
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
