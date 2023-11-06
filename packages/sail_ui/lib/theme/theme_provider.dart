import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/theme/theme_data.dart';

class SailThemeProvider extends StatefulWidget {
  final WidgetBuilder builder;

  const SailThemeProvider({
    super.key,
    required this.builder,
  });

  @override
  State<SailThemeProvider> createState() => SailThemeProviderState();
  static SailThemeProviderState of(BuildContext context) {
    final SailThemeProviderState? result = context.findAncestorStateOfType<SailThemeProviderState>();
    if (result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'SailThemeProviderState.of() called with a context that does not contain a SailThemeProvider.',
      ),
    ]);
  }
}

class SailThemeProviderState extends State<SailThemeProvider> {
  SailThemeData theme = SailThemeData(
    name: 'light',
    colors: SailColor.lightTheme(SailColorScheme.orange),
  );

  @override
  Widget build(BuildContext context) {
    return SailTheme(
      data: theme,
      child: widget.builder(context),
    );
  }
}
