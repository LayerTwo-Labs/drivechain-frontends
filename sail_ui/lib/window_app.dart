import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

SailApp buildSailWindowApp(
  Logger log,
  String windowTitle,
  Widget child,
  Color accentColor,
) {
  return SailApp(
    log: log,
    dense: true,
    builder: (context) => MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
        fontFamily: 'Inter',
      ),
      home: Scaffold(
        backgroundColor: SailTheme.of(context).colors.background,
        body: Column(
          children: [
            Container(
              height: 26,
              color: Colors.grey[200],
              alignment: Alignment.centerLeft,
              child: Center(child: SailText.primary13(windowTitle)),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    ),
    accentColor: accentColor,
  );
}
