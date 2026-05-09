import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  group('formatDataSizeFromMB', () {
    test('returns empty for negative values', () {
      expect(formatDataSizeFromMB(-1), '');
    });

    test('renders sub-megabyte values in KB', () {
      expect(formatDataSizeFromMB(0.5), '512 KB');
      expect(formatDataSizeFromMB(0.1), '102 KB');
    });

    test('renders megabyte values without decimals when large', () {
      expect(formatDataSizeFromMB(50), '50 MB');
      expect(formatDataSizeFromMB(200), '200 MB');
    });

    test('keeps one decimal under 10 MB', () {
      expect(formatDataSizeFromMB(2.5), '2.5 MB');
      expect(formatDataSizeFromMB(9.9), '9.9 MB');
    });

    test('switches to GB at 1024 MB', () {
      expect(formatDataSizeFromMB(1024), '1.00 GB');
      expect(formatDataSizeFromMB(2048), '2.00 GB');
      expect(formatDataSizeFromMB(5120), '5.00 GB');
    });
  });
}
