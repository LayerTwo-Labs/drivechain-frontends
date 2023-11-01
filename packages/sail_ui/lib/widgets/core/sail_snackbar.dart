import 'package:flutter/material.dart';
import 'package:sail_ui/style/style.dart';
import 'package:sail_ui/theme/theme_data.dart';
import 'package:sail_ui/widgets/core/sail_padding.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

void showSnackBar(
  SailThemeData theme,
  ScaffoldMessengerState messenger,
  String message,
) {
  if (!messenger.mounted) return;

  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.fixed,
      backgroundColor: theme.colors.background,
      content: SailPadding(
        padding: const EdgeInsets.symmetric(
          vertical: SailStyleValues.padding10,
        ),
        child: SailText.primary14(message),
      ),
    ),
  );
}
