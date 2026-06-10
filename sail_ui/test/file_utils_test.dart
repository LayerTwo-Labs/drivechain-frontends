import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/utils/file_utils.dart';

void main() {
  test('diagnoseUncreatablePath names a dangling symlink', () async {
    final tmp = await Directory.systemTemp.createTemp('file_utils_test');
    addTearDown(() => tmp.delete(recursive: true));

    final link = Link('${tmp.path}/share');
    await link.create('${tmp.path}/does-not-exist');

    final diagnosis = diagnoseUncreatablePath('${link.path}/com.layertwolabs.bitwindow');
    expect(diagnosis, contains('share'));
    expect(diagnosis, contains('does not exist'));
  });

  test('diagnoseUncreatablePath names a file blocking the path', () async {
    final tmp = await Directory.systemTemp.createTemp('file_utils_test');
    addTearDown(() => tmp.delete(recursive: true));

    final file = File('${tmp.path}/share');
    await file.writeAsString('not a dir');

    final diagnosis = diagnoseUncreatablePath('${file.path}/com.layertwolabs.bitwindow');
    expect(diagnosis, contains('is a file'));
  });

  test('diagnoseUncreatablePath returns null on a healthy path', () async {
    final tmp = await Directory.systemTemp.createTemp('file_utils_test');
    addTearDown(() => tmp.delete(recursive: true));

    expect(diagnoseUncreatablePath('${tmp.path}/new/sub/dir'), isNull);
  });
}
