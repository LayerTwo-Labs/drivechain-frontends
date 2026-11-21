import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/widgets/wallet_backup_restore.dart';

void main() {
  late Directory root;

  setUp(() async => root = await Directory.systemTemp.createTemp('backup-share'));
  tearDown(() async => root.delete(recursive: true));

  test('writes the backup into a cleared folder and shares that file', () async {
    final dir = Directory(path.join(root.path, 'wallet-backup'));
    await dir.create();
    await File(path.join(dir.path, 'old-backup.zip')).writeAsString('old');
    final shared = <String>[];

    final written = await shareWalletBackup(
      fetch: () async => [1, 2, 3],
      share: (p) async => shared.add(p),
      dir: dir,
      fileName: 'wallet-backup-now.zip',
    );

    expect(shared, [written]);
    expect(path.basename(written), 'wallet-backup-now.zip');
    expect(await File(written).readAsBytes(), [1, 2, 3]);
    expect(dir.listSync().map((e) => path.basename(e.path)), ['wallet-backup-now.zip']);
  });

  test('a failed share reaches the caller', () async {
    final dir = Directory(path.join(root.path, 'wallet-backup'));

    await expectLater(
      shareWalletBackup(
        fetch: () async => [1],
        share: (p) async => throw StateError('no app can take this file'),
        dir: dir,
        fileName: 'b.zip',
      ),
      throwsStateError,
    );
  });
}
