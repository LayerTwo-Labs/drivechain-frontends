import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sidechain_core/extensions/formatting.dart';

void main() {
  test('format reuses one DateFormat per locale', () {
    expect(identical(defaultDateFormat('en_US'), defaultDateFormat('en_US')), isTrue);
  });

  test('format prints what a new DateFormat prints', () {
    final date = DateTime.utc(2026, 11, 19, 13, 5, 9);
    expect(date.format(), DateFormat().format(date.toLocal()));
  });
}
