import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

enum BThemeType { light }

class SailTheme extends StatelessWidget {
  final Widget child;
  final SailThemeData data;

  static final kFallbackTheme = SailThemeData.lightTheme(SailColorScheme.orange, true);

  const SailTheme({super.key, required this.child, required this.data});

  static SailThemeData of(BuildContext context) {
    final _InheritedTheme? inheritedTheme = context.dependOnInheritedWidgetOfExactType<_InheritedTheme>();

    final SailThemeData theme = inheritedTheme?.theme.data ?? kFallbackTheme;
    return theme;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedTheme(theme: this, child: child);
  }
}

class _InheritedTheme extends InheritedWidget {
  final SailTheme theme;

  const _InheritedTheme({required super.child, required this.theme});

  @override
  bool updateShouldNotify(covariant _InheritedTheme oldWidget) {
    return theme.data.colors != oldWidget.theme.data.colors;
  }
}
