import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/file_utils.dart';

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

  test('revealCommand selects the file on macOS', () {
    final (command, args) = revealCommand(OS.macos, '/data/bitwindow/bitwindow.log');
    expect(command, 'open');
    expect(args, ['-R', '/data/bitwindow/bitwindow.log']);
  });

  // Explorer takes the switch and the path as one argument. A space between
  // them makes it open the default folder.
  test('revealCommand joins the switch and the path on Windows', () {
    final (command, args) = revealCommand(OS.windows, r'C:\data\bitwindow.log');
    expect(command, 'explorer');
    expect(args, [r'/select,C:\data\bitwindow.log']);
  });

  test('revealCommand opens the folder on Linux', () {
    final (command, args) = revealCommand(OS.linux, '/data/bitwindow/bitwindow.log');
    expect(command, 'xdg-open');
    expect(args, ['/data/bitwindow']);
  });

  test('fileManagerName names the file manager of this platform', () {
    final expected = switch (getOS()) {
      OS.macos => 'Finder',
      OS.windows => 'File Explorer',
      OS.linux => 'File Manager',
    };
    expect(fileManagerName(), expected);
  });

  test('diagnoseUncreatablePath returns null on a healthy path', () async {
    final tmp = await Directory.systemTemp.createTemp('file_utils_test');
    addTearDown(() => tmp.delete(recursive: true));

    expect(diagnoseUncreatablePath('${tmp.path}/new/sub/dir'), isNull);
  });
}
