import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/android_daemons.dart';

void main() {
  late Directory root;
  late Directory binDir;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('android_daemons');
    binDir = await Directory(path.join(root.path, 'bin')).create();
  });

  tearDown(() => root.delete(recursive: true));

  Future<String> nativeDirWith(String name) async {
    final dir = await Directory(path.join(root.path, name)).create();
    for (final daemon in androidDaemons) {
      await File(path.join(dir.path, 'lib$daemon.so')).writeAsString(daemon);
    }
    return dir.path;
  }

  test('links each daemon to its lib .so', () async {
    final nativeDir = await nativeDirWith('lib-a');

    await linkNativeBinaries(binDir, nativeDir, androidDaemons);

    for (final daemon in androidDaemons) {
      expect(await Link(path.join(binDir.path, daemon)).target(), path.join(nativeDir, 'lib$daemon.so'));
    }
  });

  test('moves a link when an APK update moves the native folder', () async {
    await linkNativeBinaries(binDir, await nativeDirWith('lib-a'), androidDaemons);
    final updated = await nativeDirWith('lib-b');

    await linkNativeBinaries(binDir, updated, androidDaemons);

    expect(await Link(path.join(binDir.path, 'bitwindowd')).target(), path.join(updated, 'libbitwindowd.so'));
  });

  test('replaces a copied binary with a link', () async {
    await File(path.join(binDir.path, 'drivechaind')).writeAsString('old copy');
    final nativeDir = await nativeDirWith('lib-a');

    await linkNativeBinaries(binDir, nativeDir, androidDaemons);

    expect(FileSystemEntity.isLinkSync(path.join(binDir.path, 'drivechaind')), isTrue);
  });

  test('fails when the APK has no daemon', () async {
    final empty = await Directory(path.join(root.path, 'empty')).create();

    expect(
      () => linkNativeBinaries(binDir, empty.path, androidDaemons),
      throwsA(isA<FileSystemException>()),
    );
  });
}
