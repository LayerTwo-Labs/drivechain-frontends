import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/settings/secure_store.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('file-storage-');
  });

  tearDown(() => dir.delete(recursive: true));

  // BitWindow and a sidechain app open the same file at the same time.
  test('a second handle reads what the first one wrote', () async {
    final first = FileStorage.fromDirectory(dir);
    final second = FileStorage.fromDirectory(dir);
    expect(await second.getString('names'), isNull);

    await first.setString('names', 'ecash');

    expect(await second.getString('names'), 'ecash');
  });

  test('a write keeps a key the other handle saved', () async {
    final first = FileStorage.fromDirectory(dir);
    final second = FileStorage.fromDirectory(dir);
    await first.setString('theme', 'dark');
    await second.getString('theme');

    await first.setString('names', 'ecash');
    await second.setString('font', 'large');

    expect(await first.getString('theme'), 'dark');
    expect(await first.getString('names'), 'ecash');
    expect(await first.getString('font'), 'large');
  });

  test('two writes on one handle keep both keys', () async {
    final store = FileStorage.fromDirectory(dir);

    await Future.wait([store.setString('a', '1'), store.setString('b', '2')]);

    expect(await store.getString('a'), '1');
    expect(await store.getString('b'), '2');
  });

  // Each app runs as its own process, so an in-process chain is not sufficient.
  test('two processes keep the keys of each other', () async {
    const count = 15;
    final runs = await Future.wait([
      for (final prefix in ['a', 'b'])
        Process.run(
          'dart',
          ['test/fixtures/settings_writer.dart', dir.path, prefix, '$count'],
          workingDirectory: Directory.current.path,
        ),
    ]);
    for (final run in runs) {
      expect(run.exitCode, 0, reason: run.stderr.toString());
    }

    final store = FileStorage.fromDirectory(dir);
    for (var i = 0; i < count; i++) {
      expect(await store.getString('a-$i'), '$i');
      expect(await store.getString('b-$i'), '$i');
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('a delete leaves the other keys', () async {
    final store = FileStorage.fromDirectory(dir);
    await store.setString('a', '1');
    await store.setString('b', '2');

    await store.delete('a');

    expect(await store.getString('a'), isNull);
    expect(await store.getString('b'), '2');
  });
}
