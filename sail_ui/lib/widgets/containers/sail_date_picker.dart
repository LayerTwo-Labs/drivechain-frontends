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
  if (picked == null) {
    return null;
  }
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

/// True when [time] falls on a calendar day inside [range], both ends included.
bool isInDateRange(DateTime time, ({DateTime start, DateTime end}) range) {
  final start = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(range.end.year, range.end.month, range.end.day + 1);
  return !time.isBefore(start) && time.isBefore(end);
}

/// Filter icon for a table header. A tap picks a range, or clears the active one.
class DateFilter extends StatelessWidget {
  final ({DateTime start, DateTime end})? range;
  final void Function(({DateTime start, DateTime end})? range) onChanged;

  const DateFilter({super.key, required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final active = range != null;
    return SailTappable(
      onTap: () async {
        if (active) {
          onChanged(null);
          return;
        }
        final picked = await showSailDateRangePicker(
          context: context,
          firstDate: DateTime(2009, 1, 3),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: SailSVG.icon(
        active ? SailSVGAsset.filterX : SailSVGAsset.filter,
        color: active ? context.sailTheme.colors.orange : context.sailTheme.colors.textSecondary,
        width: 16,
      ),
    );
  }
}
