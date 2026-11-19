import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _themeDefinitions = {
  'lib/theme/theme_registry.dart',
  'lib/theme/ecash_theme.dart',
  'lib/style/style_values.dart',
};

void main() {
  test('widgets take their radii from the theme chrome', () {
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.dart') &&
            !file.path.contains('/gen/') &&
            !_themeDefinitions.contains(file.path) &&
            file.readAsStringSync().contains('SailStyleValues.borderRadius'))
          file.path,
    ];

    expect(offenders, isEmpty);
  });
}
