import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

List<String> tempFiles(Directory dir) =>
    dir.listSync(recursive: true).map((e) => e.path).where((p) => p.endsWith('.new')).toList();

void main() {
  late Directory dir;
  late Directory srcDir;
  var sources = 0;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('stage_binary_test');
    srcDir = await Directory.systemTemp.createTemp('stage_binary_src');
  });

  tearDown(() async {
    for (final d in [dir, srcDir]) {
      if (await d.exists()) {
        await d.delete(recursive: true);
      }
    }
  });

  Future<File> source(List<int> bytes) async {
    final f = File('${srcDir.path}/src${sources++}');
    await f.writeAsBytes(bytes);
    return f;
  }

  group('stageBinary', () {
    test('writes the new bytes to the destination', () async {
      final dest = File('${dir.path}/bitwindowd');

      await stageBinary(dest, await source([1, 2, 3]));

      expect(await dest.readAsBytes(), [1, 2, 3]);
    });

    test('replaces an existing binary', () async {
      final dest = File('${dir.path}/bitwindowd');
      await dest.writeAsBytes([9, 9]);

      await stageBinary(dest, await source([1, 2, 3]));

      expect(await dest.readAsBytes(), [1, 2, 3]);
    });

    test('an already open handle keeps the old bytes', () async {
      final dest = File('${dir.path}/drivechaind');
      await dest.writeAsBytes([9, 9, 9]);
      final running = await dest.open();
      addTearDown(running.close);

      await stageBinary(dest, await source([1, 2, 3]));

      expect(await running.read(3), [9, 9, 9], reason: 'the write changed the inode of a running binary');
    });

    test('marks the destination as executable', () async {
      final dest = File('${dir.path}/drivechain-cli');

      await stageBinary(dest, await source([1]));

      final stat = await dest.stat();
      expect(stat.mode & 0x40, 0x40, reason: 'the owner execute bit is not set');
    }, skip: Platform.isWindows);

    test('takes a temp path of its own for every call', () async {
      final dest = File('${dir.path}/bitwindowd');

      await Future.wait([
        stageBinary(dest, await source(List.filled(4096, 1))),
        stageBinary(dest, await source(List.filled(4096, 2))),
      ]);

      final staged = await dest.readAsBytes();
      expect(staged.toSet().length, 1, reason: 'two calls shared one temp file and staged a torn binary');
      expect(tempFiles(dir), isEmpty);
    });

    test('moves the old binary aside, and a later start deletes it', () async {
      final dest = File('${dir.path}/drivechaind.exe');
      await dest.writeAsBytes([9, 9]);

      await stageBinary(dest, await source([1, 2, 3]), moveAside: true);

      expect(await dest.readAsBytes(), [1, 2, 3]);
      final aside = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.old')).toList();
      expect(aside, hasLength(1));
      expect(await aside.single.readAsBytes(), [9, 9]);

      await removeAsideBinaries(dir);

      expect(dir.listSync().map((e) => e.path), [dest.path]);
    });

    test('leaves no temp file behind after a failed rename', () async {
      final dest = Directory('${dir.path}/hwi-daemon');
      await dest.create();
      await File('${dest.path}/blocker').writeAsString('x');

      await expectLater(stageBinary(File(dest.path), await source([1, 2, 3])), throwsA(isA<FileSystemException>()));

      expect(tempFiles(dir), isEmpty);
    });
  });

  group('stageEmbeddedBinaries', () {
    test('copies the host-arch daemon from the bundle to its canonical name', () async {
      final bundle = Directory('${srcDir.path}/bin')..createSync();
      final assetName = embeddedAssetName('hwi-daemon', isMacOS: Platform.isMacOS, arch: currentArch());
      final exe = Platform.isWindows ? '.exe' : '';
      File('${bundle.path}/$assetName$exe')
        ..createSync(recursive: true)
        ..writeAsBytesSync([4, 5, 6]);
      final out = Directory('${dir.path}/out');

      await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out);

      expect(File('${out.path}/hwi-daemon$exe').readAsBytesSync(), [4, 5, 6]);
      expect(out.listSync().map((e) => e.path).toSet(), {
        '${out.path}/hwi-daemon$exe',
        '${out.path}/hwi-daemon$exe.stamp',
      });
    });

    group('a second start', () {
      late Directory bundle;
      late File asset;
      late File staged;
      late Directory out;
      final exe = Platform.isWindows ? '.exe' : '';

      setUp(() async {
        bundle = Directory('${srcDir.path}/bin')..createSync();
        asset = File(
          '${bundle.path}/${embeddedAssetName('hwi-daemon', isMacOS: Platform.isMacOS, arch: currentArch())}$exe',
        );
        asset
          ..createSync(recursive: true)
          ..writeAsBytesSync([4, 5, 6]);
        out = Directory('${dir.path}/out');
        staged = File('${out.path}/hwi-daemon$exe');
        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out);
        // Same size as the bundle file, so only a copy can bring back [4, 5, 6].
        staged.writeAsBytesSync([7, 7, 7]);
      });

      test('writes nothing when the bundle file did not change', () async {
        final reported = <String>[];
        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out, onStaged: (name, _) => reported.add(name));

        expect(staged.readAsBytesSync(), [7, 7, 7]);
        expect(reported, isEmpty);
      });

      test('reports each binary it wrote', () async {
        File('${staged.path}.stamp').deleteSync();
        final reported = <(String, String)>[];

        await stageEmbeddedBinaries(
          Logger(level: Level.off),
          bundle,
          out,
          onStaged: (name, file) => reported.add((name, file.path)),
        );

        expect(reported, [('hwi-daemon', staged.path)]);
      });

      test('copies a bundle file with a new modification time', () async {
        asset.setLastModifiedSync(asset.lastModifiedSync().add(const Duration(seconds: 5)));

        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out);

        expect(staged.readAsBytesSync(), [4, 5, 6]);
      });

      test('copies a bundle file with a new size', () async {
        final modified = asset.lastModifiedSync();
        asset.writeAsBytesSync([4, 5, 6, 7]);
        asset.setLastModifiedSync(modified);

        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out);

        expect(staged.readAsBytesSync(), [4, 5, 6, 7]);
      });

      test('copies when the stamp is missing', () async {
        File('${staged.path}.stamp').deleteSync();

        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out);

        expect(staged.readAsBytesSync(), [4, 5, 6]);
      });

      test('copies when the staged binary is missing', () async {
        staged.deleteSync();

        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out);

        expect(staged.readAsBytesSync(), [4, 5, 6]);
      });
    });
  });
}
