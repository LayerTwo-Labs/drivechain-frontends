import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Date picker themed with the Sail colors.
Future<DateTime?> showSailDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: _themedPickerBuilder,
  );
}

/// Date range picker themed with the Sail colors.
Future<({DateTime start, DateTime end})?> showSailDateRangePicker({
  required BuildContext context,
  ({DateTime start, DateTime end})? initialRange,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final picked = await showDateRangePicker(
    context: context,
    initialDateRange: initialRange != null ? DateTimeRange(start: initialRange.start, end: initialRange.end) : null,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: _themedPickerBuilder,
  );
  if (picked == null) return null;
  return (start: picked.start, end: picked.end);
}

Widget _themedPickerBuilder(BuildContext context, Widget? child) {
  final theme = SailTheme.of(context);
  final scheme = theme.isLightMode()
      ? ColorScheme.light(
          primary: theme.colors.primary,
          onPrimary: theme.colors.background,
          surface: theme.colors.background,
          onSurface: theme.colors.text,
        )
      : ColorScheme.dark(
          primary: theme.colors.primary,
          onPrimary: theme.colors.background,
          surface: theme.colors.background,
          onSurface: theme.colors.text,
        );

  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: scheme,
      dialogTheme: DialogThemeData(backgroundColor: theme.colors.background),
    ),
    child: child!,
  );
}
