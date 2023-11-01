import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/style/color_scheme.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/theme/theme_data.dart';
import 'package:sail_ui/widgets/core/scaffold.dart';
import 'package:sail_ui/widgets/loading_indicator.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/sail_settings/theme_settings.dart';

class SailApp extends StatefulWidget {
  final Widget Function(BuildContext context, AppRouter router) builder;

  const SailApp({
    super.key,
    required this.builder,
  });

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
  SailThemeData? theme;
  AppRouter get router => GetIt.I.get<AppRouter>();
  final settings = GetIt.I.get<ClientSettings>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadTheme();
  }

  SailThemeData _themeDataFromTheme(SailThemeValues theme) {
    switch (theme) {
      case SailThemeValues.light:
        return SailThemeData.darkTheme();
      case SailThemeValues.dark:
        return SailThemeData.darkTheme();
      default:
        throw Exception('Could not get theme');
    }
  }

  void loadTheme([SailThemeValues? themeToLoad]) async {
    themeToLoad ??= (await settings.getValue(ThemeSetting())).value;
    if (themeToLoad == SailThemeValues.platform) {
      // ignore: deprecated_member_use
      themeToLoad = WidgetsBinding.instance.window.platformBrightness == Brightness.light //
          ? SailThemeValues.light
          : SailThemeValues.dark;
    }

    theme = _themeDataFromTheme(themeToLoad);

    setState(() {});
    await settings.setValue(ThemeSetting(newValue: themeToLoad));
  }

  @override
  Widget build(BuildContext context) {
    if (theme == null) {
      return MaterialApp(
        home: Material(
          color: SailColorScheme.orange,
          child: SailTheme(
            data: SailThemeData.lightTheme(),
            child: const SailScaffold(
              body: Center(
                child: SailCircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    }

    return SailTheme(
      data: theme!,
      child: widget.builder(context, router),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
