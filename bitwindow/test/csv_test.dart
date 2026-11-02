import 'package:bitwindow/utils/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('joins fields with commas and rows with CRLF, with no CRLF at the end', () {
    expect(
      encodeCsv([
        ['a', 'b'],
        ['1', '2'],
      ]),
      'a,b\r\n1,2',
    );
  });

  test('gives an empty string for no rows', () {
    expect(encodeCsv([]), '');
  });

  test('writes an empty field as nothing', () {
    expect(
      encodeCsv([
        ['', 'x', ''],
      ]),
      ',x,',
    );
  });

  test('leaves a plain field without quotes', () {
    expect(
      encodeCsv([
        ['-0.00010000', 'bc1qxyz', '2026-11-02 10:00:00'],
      ]),
      '-0.00010000,bc1qxyz,2026-11-02 10:00:00',
    );
  });

  test('quotes a field with a comma, a line break, or a quote', () {
    expect(
      encodeCsv([
        ['a,b', 'line\none', 'cr\rhere', 'say "hi"'],
      ]),
      '"a,b","line\none","cr\rhere","say ""hi"""',
    );
  });

  test('quotes a field with a space at the start or the end', () {
    expect(
      encodeCsv([
        [' lead', 'trail ', 'mid dle'],
      ]),
      '" lead","trail ",mid dle',
    );
  });
}
