import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  test('formatDate reuses one DateFormat per pattern and locale', () {
    expect(
      identical(cachedDateFormat('yyyy MMM dd HH:mm', 'en_US'), cachedDateFormat('yyyy MMM dd HH:mm', 'en_US')),
      isTrue,
    );
  });

  test('formatDate prints what a new DateFormat prints', () {
    final date = DateTime.utc(2026, 11, 19, 13, 5, 9);
    final locale = Intl.getCurrentLocale();
    final pattern = ['en_US', 'en_PH', 'en_CA', 'en_AU', 'en_NZ', 'en_IE', 'en_IN'].contains(locale)
        ? 'yyyy MMM dd hh:mm a'
        : 'yyyy MMM dd HH:mm';
    expect(formatDate(date), DateFormat(pattern, locale).format(date.toLocal()));
  });
}
