import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:sail_ui/sail_ui.dart';

void main() {
  late Directory tempAppDir;

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('cli-console-test-');
    await Directory(p.join(tempAppDir.path, 'assets', 'bin')).create(recursive: true);
    GetIt.I.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: tempAppDir, binaries: const []),
    );
  });

  tearDown(() async {
    await GetIt.I.unregister<BinaryProvider>();
    if (tempAppDir.existsSync()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  Future<File> seed(String relPath) async {
    final f = File(p.join(tempAppDir.path, 'assets', 'bin', relPath));
    await f.create(recursive: true);
    await f.writeAsBytes([0]);
    if (Platform.isMacOS || Platform.isLinux) {
      await Process.run('chmod', ['+x', f.path]);
    }
    return f;
  }

  test('discoverCLIs finds CLIs at the BitWindow appDir, not per-binary frontends', () async {
    final cli = await seed('bitcoin-cli${Platform.isWindows ? '.exe' : ''}');
    final results = await CLIConsole.discoverCLIs();
    expect(results['bitcoin-cli'], cli.path);
  });

  test('discoverCLIs picks up CLIs nested one level under appDir/assets/bin', () async {
    // Mirrors the Core variant layout: assets/bin/<variant>/bitcoin-cli.
    final cli = await seed('drivechain/bitcoin-cli${Platform.isWindows ? '.exe' : ''}');
    final results = await CLIConsole.discoverCLIs();
    expect(results['bitcoin-cli'], cli.path);
  });

  test('discoverCLIs returns empty when no executables exist', () async {
    final results = await CLIConsole.discoverCLIs();
    expect(results, isEmpty);
  });

  test('discoverCLIs returns empty when assets/bin is missing', () async {
    await Directory(p.join(tempAppDir.path, 'assets', 'bin')).delete(recursive: true);
    final results = await CLIConsole.discoverCLIs();
    expect(results, isEmpty);
  });
}
