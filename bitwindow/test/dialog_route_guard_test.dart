import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _directDialog = RegExp(r'\b(showDialog|showGeneralDialog|showCupertinoDialog)\s*(<[^>]*>)?\(');

List<String> _offenders(String dir) => [
  for (final file in Directory(dir).listSync(recursive: true).whereType<File>())
    if (file.path.endsWith('.dart') &&
        !file.path.endsWith('sail_dialogs.dart') &&
        _directDialog.hasMatch(file.readAsStringSync()))
      file.path,
];

void main() {
  test('bitwindow opens every dialog through the helpers that make a sheet on a phone', () {
    expect(_offenders('lib'), isEmpty);
  });
}
