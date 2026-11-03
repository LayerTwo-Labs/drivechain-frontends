import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/utils/paper_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixture =
      jsonDecode(File('server/paperpdf/testdata/qr_fixture.json').readAsStringSync()) as Map<String, dynamic>;

  test('the QR matrix of the shared fixture matches the bytes that bitwindowd reads', () {
    final matrix = paperQrMatrix(fixture['data'] as String);

    expect(matrix.size, fixture['size']);
    expect(base64.encode(matrix.modules), fixture['modules']);
  });

  test('the QR matrix is row-major from the top-left module, one byte per module', () {
    final matrix = paperQrMatrix(fixture['data'] as String);
    final rows = (fixture['rows'] as List).cast<String>();

    for (var row = 0; row < matrix.size; row++) {
      for (var col = 0; col < matrix.size; col++) {
        expect(matrix.modules[row * matrix.size + col], rows[row][col] == '#' ? 1 : 0, reason: 'row $row, col $col');
      }
    }
  });
}
