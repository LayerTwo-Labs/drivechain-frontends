import 'package:intl/intl.dart';

extension FormatTime on DateTime {
  String format() {
    return DateFormat().format(toLocal());
  }
}
