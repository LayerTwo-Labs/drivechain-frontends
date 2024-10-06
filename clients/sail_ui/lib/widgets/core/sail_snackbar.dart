import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  int duration = 3,
}) {
  if (!context.mounted) return;
  final theme = SailTheme.of(context);
  final messenger = ScaffoldMessenger.of(context);

  messenger.showSnackBar(
    SnackBar(
      duration: Duration(seconds: duration),
      behavior: SnackBarBehavior.fixed,
      backgroundColor: theme.colors.backgroundSecondary,
      content: SailPadding(
        padding: const EdgeInsets.symmetric(
          vertical: SailStyleValues.padding10,
        ),
        child: SailText.primary13(message),
      ),
    ),
  );
}
