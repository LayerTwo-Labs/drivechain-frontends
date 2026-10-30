import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  group('stripLogTimestamp', () {
    test('keeps a line with no timestamp whole', () {
      expect(stripLogTimestamp('Error: wallet error'), 'Error: wallet error');
      expect(stripLogTimestamp('short'), 'short');
    });

    test('removes a Bitcoin Core timestamp', () {
      expect(
        stripLogTimestamp('2026-10-27T21:25:10Z Bitcoin Core version v29.0'),
        'Bitcoin Core version v29.0',
      );
    });

    test('removes a timestamp with fractional seconds', () {
      expect(
        stripLogTimestamp('2026-10-27T21:25:10.123456Z  INFO thunder: starting'),
        'INFO thunder: starting',
      );
    });
  });
}
