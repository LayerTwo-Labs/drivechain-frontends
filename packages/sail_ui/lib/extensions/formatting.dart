import 'package:intl/intl.dart';

extension FormatTime on DateTime {
  String format() {
    return DateFormat().format(toLocal());
  }
}

String formatWithThousandSpacers(dynamic value) {
  String stringValue = value.toString();
  return stringValue.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
}
