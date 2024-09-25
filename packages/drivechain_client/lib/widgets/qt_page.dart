import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class QtPage extends StatelessWidget {
  final Widget child;

  const QtPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:context.isDarkMode
          ? context.sailTheme.colors.background // Dark Qt-grey
          : const Color.fromARGB(255, 240, 240, 240), // Light Qt-grey
      child: Padding(
        padding: const EdgeInsets.only(
          left: SailStyleValues.padding12,
          right: SailStyleValues.padding12,
          top: SailStyleValues.padding12,
          bottom: SailStyleValues.padding12,
        ),
        child: child,
      ),
    );
  }
}
