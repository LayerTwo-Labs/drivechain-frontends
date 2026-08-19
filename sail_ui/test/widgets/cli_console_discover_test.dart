import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;

class _FakeOrchestratorRPC extends OrchestratorRPC {
  _FakeOrchestratorRPC(this.paths) : super(host: '127.0.0.1', port: 1);

  /// Binary name → the path the daemon runs.
  final Map<String, String> paths;

  @override
  Future<orch_pb.ListBinariesResponse> listBinaries({bool forceBackend = false}) async {
    return orch_pb.ListBinariesResponse(
      binaries: [
        for (final e in paths.entries) orch_pb.BinaryStatusMsg(name: e.key, binaryPath: e.value),
      ],
    );
  }
}

void main() {
  late Directory tempAppDir;

  setUpAll(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    }
  });

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('cli-console-test-');
    await Directory(p.join(tempAppDir.path, 'assets', 'bin')).create(recursive: true);
    GetIt.I.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: tempAppDir, binaries: const []),
    );
  });

  tearDown(() async {
    if (GetIt.I.isRegistered<OrchestratorRPC>()) {
      await GetIt.I.unregister<OrchestratorRPC>();
    }
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

  test('discoverCLIs takes bitcoin-cli from the folder the daemon runs', () async {
    final suffix = Platform.isWindows ? '.exe' : '';
    final active = await seed('drynet4/bitcoin-cli$suffix');
    await seed('knots/bitcoin-cli$suffix');
    final daemon = await seed('drynet4/bitcoind$suffix');
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestratorRPC({'bitcoind': daemon.path}));

    final results = await CLIConsole.discoverCLIs();

    expect(results['bitcoin-cli'], active.path);
  });

  // Every Core variant ships a bitcoin-cli, and listSync gives no order. A pick
  // between them is arbitrary, and the wrong one speaks another fork.
  test('discoverCLIs drops bitcoin-cli when two variants hold one and no daemon answers', () async {
    final suffix = Platform.isWindows ? '.exe' : '';
    await seed('drynet4/bitcoin-cli$suffix');
    await seed('knots/bitcoin-cli$suffix');

    final results = await CLIConsole.discoverCLIs();

    expect(results['bitcoin-cli'], isNull);
  });
}
