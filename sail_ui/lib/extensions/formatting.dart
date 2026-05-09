import 'package:intl/intl.dart';

extension FormatTime on DateTime {
  String format() {
    return DateFormat().format(toLocal());
  }
}

String formatWithThousandSpacers(dynamic value) {
  String stringValue = value.toString();
  return stringValue.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]} ',
  );
}

/// Renders a download size in a unit that fits the magnitude. The orchestrator
/// reports progress in megabytes, so [valueMB] is in megabytes; this picks
/// KB / MB / GB based on size and rounds to a sensible number of decimals.
String formatDataSizeFromMB(num valueMB) {
  if (valueMB < 0) return '';
  if (valueMB < 1) {
    final kb = valueMB * 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }
  if (valueMB < 1024) {
    final fixed = valueMB < 10 ? valueMB.toStringAsFixed(1) : valueMB.toStringAsFixed(0);
    return '$fixed MB';
  }
  final gb = valueMB / 1024;
  return '${gb.toStringAsFixed(2)} GB';
}
