import 'package:flutter/material.dart';
import 'package:sail_ui/theme/theme.dart';

Future<T?> showThemedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final theme = SailTheme.of(context);
  return showDialog(
    context: context,
    barrierColor: theme.colors.background.withOpacity(0.4),
    builder: builder,
  );
}
