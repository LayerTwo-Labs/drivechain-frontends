import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/theme/theme_data.dart';
import 'package:sail_ui/widgets/core/scaffold.dart';
import 'package:sail_ui/widgets/loading_indicator.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/storage/client_settings.dart';
import 'package:sidesail/storage/sail_settings/theme_settings.dart';

class SailApp extends StatefulWidget {
  // This key is used to programmatically trigger a rebuild of the MyApp widget.
  static GlobalKey<SailAppState> sailAppKey = GlobalKey();

  final Widget Function(BuildContext context, AppRouter router) builder;

  SailApp({
    required this.builder,
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
  SailThemeData? theme;
  AppRouter get router => GetIt.I.get<AppRouter>();
  SidechainRPC get _sidechain => GetIt.I.get<SidechainRPC>();
  final settings = GetIt.I.get<ClientSettings>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadTheme();
  }

  void rebuildUI() {
    setState(() {
      // This is a workaround to trigger the root widget to rebuild.
      SailApp.sailAppKey = GlobalKey();
    });
  }

  SailThemeData _themeDataFromTheme(SailThemeValues theme) {
    switch (theme) {
      case SailThemeValues.light:
        return SailThemeData.lightTheme(_sidechain.chain.color);
      case SailThemeValues.dark:
        return SailThemeData.darkTheme(_sidechain.chain.color);
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
          color: _sidechain.chain.color,
          child: SailTheme(
            data: SailThemeData.lightTheme(_sidechain.chain.color),
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
