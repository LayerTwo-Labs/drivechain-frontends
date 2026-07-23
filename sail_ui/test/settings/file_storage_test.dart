import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/settings/secure_store.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('sail-settings-test-');
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('concurrent instances serialize without dropping settings', () async {
    final first = FileStorage.fromDirectory(directory);
    final second = FileStorage.fromDirectory(directory);
    await Future.wait([
      for (var index = 0; index < 40; index++)
        (index.isEven ? first : second).setString(
          'key-$index',
          'value-$index',
        ),
    ]);

    final reopened = FileStorage.fromDirectory(directory);
    for (var index = 0; index < 40; index++) {
      expect(await reopened.getString('key-$index'), 'value-$index');
    }
    expect(await first.getString('key-39'), 'value-39');
  });

  test('corrupt primary recovers the last complete file generation', () async {
    final storage = FileStorage.fromDirectory(directory);
    await storage.setString('first', 'committed');
    await storage.setString('second', 'newest');
    final primary = File('${directory.path}${Platform.pathSeparator}settings.json');
    await primary.writeAsString('{"torn"', flush: true);

    final recovered = FileStorage.fromDirectory(directory);
    expect(await recovered.getString('first'), 'committed');
    expect(await recovered.getString('second'), isNull);
    await recovered.setString('after-recovery', 'safe');

    final reopened = FileStorage.fromDirectory(directory);
    expect(await reopened.getString('first'), 'committed');
    expect(await reopened.getString('after-recovery'), 'safe');
  });

  test('corrupt primary and recovery copy fail closed', () async {
    final storage = FileStorage.fromDirectory(directory);
    await storage.setString('first', 'committed');
    await storage.setString('second', 'newest');
    final primary = File('${directory.path}${Platform.pathSeparator}settings.json');
    final backup = File('${primary.path}.bak');
    await primary.writeAsString('bad primary', flush: true);
    await backup.writeAsString('bad backup', flush: true);

    await expectLater(
      FileStorage.fromDirectory(directory).getString('first'),
      throwsA(isA<FileSystemException>()),
    );
  });

  test('delete is durable and preserves unrelated values', () async {
    final storage = FileStorage.fromDirectory(directory);
    await storage.setString('keep', 'yes');
    await storage.setString('remove', 'secret');
    await storage.delete('remove');

    final reopened = FileStorage.fromDirectory(directory);
    expect(await reopened.getString('keep'), 'yes');
    expect(await reopened.getString('remove'), isNull);
  });
}
