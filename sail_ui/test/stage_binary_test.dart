import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

List<String> tempFiles(Directory dir) =>
    dir.listSync(recursive: true).map((e) => e.path).where((p) => p.endsWith('.new')).toList();

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('stage_binary_test');
  });

  tearDown(() async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  group('stageBinary', () {
    test('writes the new bytes to the destination', () async {
      final dest = File('${dir.path}/bitwindowd');

      await stageBinary(dest, [1, 2, 3]);

      expect(await dest.readAsBytes(), [1, 2, 3]);
    });

    test('replaces an existing binary', () async {
      final dest = File('${dir.path}/bitwindowd');
      await dest.writeAsBytes([9, 9]);

      await stageBinary(dest, [1, 2, 3]);

      expect(await dest.readAsBytes(), [1, 2, 3]);
    });

    test('an already open handle keeps the old bytes', () async {
      final dest = File('${dir.path}/drivechaind');
      await dest.writeAsBytes([9, 9, 9]);
      final running = await dest.open();
      addTearDown(running.close);

      await stageBinary(dest, [1, 2, 3]);

      expect(await running.read(3), [9, 9, 9], reason: 'the write changed the inode of a running binary');
    });

    test('marks the destination as executable', () async {
      final dest = File('${dir.path}/drivechain-cli');

      await stageBinary(dest, [1]);

      final stat = await dest.stat();
      expect(stat.mode & 0x40, 0x40, reason: 'the owner execute bit is not set');
    }, skip: Platform.isWindows);

    test('takes a temp path of its own for every call', () async {
      final dest = File('${dir.path}/bitwindowd');

      await Future.wait([
        stageBinary(dest, List.filled(4096, 1)),
        stageBinary(dest, List.filled(4096, 2)),
      ]);

      final staged = await dest.readAsBytes();
      expect(staged.toSet().length, 1, reason: 'two calls shared one temp file and staged a torn binary');
      expect(tempFiles(dir), isEmpty);
    });

    test('leaves no temp file behind after a failed rename', () async {
      final dest = Directory('${dir.path}/hwi-daemon');
      await dest.create();
      await File('${dest.path}/blocker').writeAsString('x');

      await expectLater(stageBinary(File(dest.path), [1, 2, 3]), throwsA(isA<FileSystemException>()));

      expect(tempFiles(dir), isEmpty);
    });
  });
}
