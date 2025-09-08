import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailAppBar {
  static PreferredSizeWidget build(BuildContext context, {required title}) {
    final colors = SailTheme.of(context).colors;

    return AppBar(
      elevation: 0,
      backgroundColor: colors.background,
      foregroundColor: colors.icon,
      centerTitle: false,
      title: title,
      leading: Navigator.canPop(context)
          ? SailButton(
              variant: ButtonVariant.icon,
              icon: SailSVGAsset.chevronLeft,
              onPressed: () async => Navigator.pop(context),
              iconHeight: 14,
              iconWidth: 14,
              small: true,
            )
          : null,
      toolbarHeight: 25,
    );
  }
}
