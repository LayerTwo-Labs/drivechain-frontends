import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> _sources() => Directory(
  'lib',
).listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart') && !f.path.contains('/gen/'));

void main() {
  test('pages take their radii from the theme chrome', () {
    final offenders = [
      for (final file in _sources())
        if (file.readAsStringSync().contains('SailStyleValues.borderRadius')) file.path,
    ];

    expect(offenders, isEmpty);
  });

  test('pages draw icons from the sail_ui icon set', () {
    final offenders = [
      for (final file in _sources())
        if (RegExp(r'\bIcons\.[a-z]').hasMatch(file.readAsStringSync())) file.path,
    ];

    expect(offenders, isEmpty);
  });
}
