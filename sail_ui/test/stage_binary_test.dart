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

  group('linkBinary', () {
    test('points the destination at the source', () async {
      final dest = File('${dir.path}/bitwindowd');
      final src = await source([1, 2, 3]);

      await linkBinary(dest, src);

      expect(await Link(dest.path).target(), src.path);
      expect(await dest.readAsBytes(), [1, 2, 3]);
    });

    test('replaces an existing copy, and an open handle keeps the old bytes', () async {
      final dest = File('${dir.path}/drivechaind');
      await dest.writeAsBytes([9, 9, 9]);
      final running = await dest.open();
      addTearDown(running.close);

      await linkBinary(dest, await source([1, 2, 3]));

      expect(await dest.readAsBytes(), [1, 2, 3]);
      expect(await running.read(3), [9, 9, 9], reason: 'the link changed the inode of a running binary');
      expect(tempFiles(dir), isEmpty);
    });

    test('leaves no temp link behind after a failed rename', () async {
      final dest = Directory('${dir.path}/hwi-daemon');
      await dest.create();
      await File('${dest.path}/blocker').writeAsString('x');

      await expectLater(linkBinary(File(dest.path), await source([1])), throwsA(isA<FileSystemException>()));

      expect(dir.listSync().map((e) => e.path), [dest.path]);
    });
  }, skip: Platform.isWindows);

  group('stageEmbeddedBinaries', () {
    test('copies the host-arch daemon from the bundle to its canonical name', () async {
      final bundle = Directory('${srcDir.path}/bin')..createSync();
      final assetName = embeddedAssetName('hwi-daemon', isMacOS: Platform.isMacOS, arch: currentArch());
      final exe = Platform.isWindows ? '.exe' : '';
      File('${bundle.path}/$assetName$exe')
        ..createSync(recursive: true)
        ..writeAsBytesSync([4, 5, 6]);
      final out = Directory('${dir.path}/out');

      await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out, link: false);

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
        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out, link: false);
        // Same size as the bundle file, so only a copy can bring back [4, 5, 6].
        staged.writeAsBytesSync([7, 7, 7]);
      });

      test('writes nothing when the bundle file did not change', () async {
        final reported = <String>[];
        await stageEmbeddedBinaries(
          Logger(level: Level.off),
          bundle,
          out,
          onStaged: (name, _) => reported.add(name),
          link: false,
        );

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
          link: false,
        );

        expect(reported, [('hwi-daemon', staged.path)]);
      });

      test('copies a bundle file with a new modification time', () async {
        asset.setLastModifiedSync(asset.lastModifiedSync().add(const Duration(seconds: 5)));

        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out, link: false);

        expect(staged.readAsBytesSync(), [4, 5, 6]);
      });

      test('copies a bundle file with a new size', () async {
        final modified = asset.lastModifiedSync();
        asset.writeAsBytesSync([4, 5, 6, 7]);
        asset.setLastModifiedSync(modified);

        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out, link: false);

        expect(staged.readAsBytesSync(), [4, 5, 6, 7]);
      });

      test('copies when the stamp is missing', () async {
        File('${staged.path}.stamp').deleteSync();

        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out, link: false);

        expect(staged.readAsBytesSync(), [4, 5, 6]);
      });

      test('copies when the staged binary is missing', () async {
        staged.deleteSync();

        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out, link: false);

        expect(staged.readAsBytesSync(), [4, 5, 6]);
      });
    });

    group('with links', () {
      late Directory bundle;
      late File asset;
      late File staged;
      late Directory out;

      Future<List<String>> stage() async {
        final reported = <String>[];
        await stageEmbeddedBinaries(
          Logger(level: Level.off),
          bundle,
          out,
          onStaged: (name, _) => reported.add(name),
          link: true,
        );
        return reported;
      }

      setUp(() async {
        bundle = Directory('${srcDir.path}/bin')..createSync();
        asset =
            File('${bundle.path}/${embeddedAssetName('hwi-daemon', isMacOS: Platform.isMacOS, arch: currentArch())}')
              ..createSync(recursive: true)
              ..writeAsBytesSync([4, 5, 6]);
        out = Directory('${dir.path}/out');
        staged = File('${out.path}/hwi-daemon');
      });

      test('links the canonical name to the bundle file and copies no bytes', () async {
        expect(await stage(), ['hwi-daemon']);

        expect(await Link(staged.path).target(), asset.path);
        expect(out.listSync(followLinks: false).whereType<File>().map((f) => f.path), ['${staged.path}.stamp']);
      });

      test('a second start changes nothing', () async {
        await stage();

        expect(await stage(), isEmpty);
      });

      test('reports the binary again after an app update', () async {
        await stage();
        asset.setLastModifiedSync(asset.lastModifiedSync().add(const Duration(seconds: 5)));

        expect(await stage(), ['hwi-daemon']);
      });

      test('replaces a copy that an older app version wrote', () async {
        await stageEmbeddedBinaries(Logger(level: Level.off), bundle, out, link: false);

        expect(await stage(), ['hwi-daemon']);

        expect(await Link(staged.path).target(), asset.path);
      });

      test('links to a second app copy whose files match the stamp', () async {
        await stage();
        final copy = Directory('${srcDir.path}/copy')..createSync();
        final copyAsset = File(
          '${copy.path}/bin/${embeddedAssetName('hwi-daemon', isMacOS: Platform.isMacOS, arch: currentArch())}',
        )..createSync(recursive: true);
        copyAsset
          ..writeAsBytesSync([4, 5, 6])
          ..setLastModifiedSync(asset.lastModifiedSync());
        bundle = Directory('${copy.path}/bin');

        expect(await stage(), ['hwi-daemon']);

        expect(await Link(staged.path).target(), copyAsset.path);
      });

      test('links again when the app moved', () async {
        await stage();
        final moved = Directory('${srcDir.path}/moved')..createSync();
        bundle = bundle.renameSync('${moved.path}/bin');
        asset = File(
          '${bundle.path}/${embeddedAssetName('hwi-daemon', isMacOS: Platform.isMacOS, arch: currentArch())}',
        );

        expect(await stage(), ['hwi-daemon']);

        expect(await Link(staged.path).target(), asset.path);
        expect(staged.readAsBytesSync(), [4, 5, 6]);
      });
    }, skip: Platform.isWindows);
  });
}
