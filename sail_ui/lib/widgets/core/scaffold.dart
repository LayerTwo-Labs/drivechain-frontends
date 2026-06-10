import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailScaffold extends StatelessWidget {
  final Widget body;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;

  const SailScaffold({super.key, required this.body, this.backgroundColor, this.appBar});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor != null
          ? backgroundColor!
          : Scaffold.maybeOf(context)?.widget.backgroundColor ?? theme.colors.background,
      body: body,
    );
  }
}
