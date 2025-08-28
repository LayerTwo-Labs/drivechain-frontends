import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailAppBar {
  static PreferredSizeWidget build(BuildContext context, {required title}) {
    final colors = SailTheme.of(context).colors;

    return AppBar(
      elevation: 0,
      titleSpacing: SailStyleValues.padding20,
      automaticallyImplyLeading: true,
      backgroundColor: colors.background,
      foregroundColor: colors.icon,
      centerTitle: true,
      title: title,
    );
  }
}
