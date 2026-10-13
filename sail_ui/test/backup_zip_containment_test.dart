import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/widgets/wallet_backup_restore.dart';

void main() {
  late Directory zipDir;

  setUp(() async {
    zipDir = await Directory.systemTemp.createTemp('backup_zip_test_');
  });

  tearDown(() async {
    await zipDir.delete(recursive: true);
  });

  Future<File> writeZip(Map<String, String> entries) async {
    final archive = Archive();
    for (final entry in entries.entries) {
      final data = utf8.encode(entry.value);
      archive.addFile(ArchiveFile(entry.key, data.length, data));
    }
    final zipFile = File(path.join(zipDir.path, 'backup.zip'));
    await zipFile.writeAsBytes(ZipEncoder().encode(archive));
    return zipFile;
  }

  const walletJSON = '{"wallets":[{"master":{},"l1":{}}]}';

  test('rejects an entry that leaves the temp dir', () async {
    final escapeName = 'escape-${Random().nextInt(1 << 32)}.txt';
    final zipFile = await writeZip({'wallet.json': walletJSON, '../$escapeName': 'pwned'});

    final result = await validateBackupZip(zipFile: zipFile, log: Logger());

    final escapedToSystemTemp = File(path.join(Directory.systemTemp.path, escapeName));
    final escapedToZipParent = File(path.join(zipDir.parent.path, escapeName));
    final escaped = escapedToSystemTemp.existsSync() || escapedToZipParent.existsSync();
    for (final file in [escapedToSystemTemp, escapedToZipParent]) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    expect(result.isValid, isFalse);
    expect(result.errorMessage, contains('outside the archive'));
    expect(escaped, isFalse);
  });

  test('accepts a normal backup', () async {
    final zipFile = await writeZip({'wallet.json': walletJSON, 'multisig/multisig.json': '{}'});

    final result = await validateBackupZip(zipFile: zipFile, log: Logger());

    expect(result.isValid, isTrue);
    final tempDir = result.tempDir!;
    addTearDown(() => tempDir.delete(recursive: true));
    expect(File(path.join(tempDir.path, 'wallet.json')).existsSync(), isTrue);
    expect(File(path.join(tempDir.path, 'multisig', 'multisig.json')).existsSync(), isTrue);
  });
}
