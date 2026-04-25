import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

/// Console view backed by the on-disk CLI binaries (bitcoin-cli, enforcer-cli, …).
/// Discovers binaries on first build, then delegates to [ConsoleView].
class CLIConsoleView extends StatefulWidget {
  const CLIConsoleView({super.key});

  @override
  State<CLIConsoleView> createState() => _CLIConsoleViewState();
}

class _CLIConsoleViewState extends State<CLIConsoleView> {
  late final Future<List<ConsoleService>> _services = CLIConsole.buildServices();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConsoleService>>(
      future: _services,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 1));
        }
        final services = snapshot.data!;
        if (services.isEmpty) {
          return Center(
            child: SailText.primary13(
              'No CLI binaries found. Make sure binaries are downloaded.',
            ),
          );
        }
        return ConsoleView(services: services);
      },
    );
  }
}

class CLIConsole {
  static const _maxOutputBytes = 200 * 1024;
  static const _commandTimeout = Duration(minutes: 5);

  static const _binaryToCLI = {
    'BitcoinCore': 'bitcoin-cli',
    'BitWindow': 'bitwindow-cli',
    'Thunder': 'thunder-cli',
    'Truthcoin': 'truthcoin-cli',
    'Photon': 'photon-cli',
    'BitNames': 'bitnames-cli',
    'BitAssets': 'bitassets-cli',
    'CoinShift': 'coinshift-cli',
    'ZSide': 'zside-cli',
    'GRPCurl': 'grpcurl',
    'Orchestratord': 'orchestratorctl',
  };

  /// Discover available CLI executables on disk. Returns map of cli name → absolute path.
  static Future<Map<String, String>> discoverCLIs() async {
    final available = <String, String>{};
    final exeSuffix = Platform.isWindows ? '.exe' : '';

    for (final binary in allBinaries) {
      final binaryName = binary.runtimeType.toString();
      final cliName = _binaryToCLI[binaryName];
      if (cliName == null) continue;

      final Directory bindir;
      try {
        bindir = binDir(binary.frontendDir());
      } catch (_) {
        continue;
      }
      if (!bindir.existsSync()) continue;

      final found = _findExecutable(bindir, '$cliName$exeSuffix');
      if (found != null) {
        await _ensureExecutable(found);
        available[cliName] = found.path;
      }
    }

    return available;
  }

  static File? _findExecutable(Directory bindir, String filename) {
    final direct = File(path.join(bindir.path, filename));
    if (direct.existsSync()) return direct;

    for (final entity in bindir.listSync()) {
      if (entity is! Directory) continue;
      final inSubdir = File(path.join(entity.path, filename));
      if (inSubdir.existsSync()) return inSubdir;
    }
    return null;
  }

  static Future<void> _ensureExecutable(File f) async {
    if (Platform.isMacOS || Platform.isLinux) {
      await Process.run('chmod', ['+x', f.path]);
    }
  }

  /// Build console services for every detected CLI, plus the enforcer-cli wrapper.
  static Future<List<ConsoleService>> buildServices() async {
    final clis = await discoverCLIs();
    final services = <ConsoleService>[];

    for (final entry in clis.entries) {
      services.add(
        ConsoleService(
          name: entry.key,
          commands: [entry.key],
          execute: (command, args) => _execute(entry.key, entry.value, args),
        ),
      );
    }

    final grpcurl = clis['grpcurl'];
    if (grpcurl != null) {
      services.add(
        ConsoleService(
          name: 'enforcer-cli',
          commands: ['enforcer-cli'],
          execute: (command, args) => _execute('enforcer-cli', grpcurl, args),
        ),
      );
    }

    return services;
  }

  static Future<String> _execute(
    String cli,
    String exePath,
    List<String> args,
  ) async {
    final effectiveArgs = _wrapArgs(cli, args);

    final ProcessResult result;
    try {
      result = await Process.run(
        exePath,
        effectiveArgs,
        runInShell: false,
      ).timeout(_commandTimeout);
    } on TimeoutException {
      throw 'command timed out after ${_commandTimeout.inMinutes}m';
    }

    final out = StringBuffer();
    final stdout = result.stdout;
    final stderr = result.stderr;
    if (stdout is String && stdout.isNotEmpty) out.write(stdout);
    if (stderr is String && stderr.isNotEmpty) {
      if (out.isNotEmpty) out.write('\n');
      out.write(stderr);
    }

    if (result.exitCode != 0 && out.isEmpty) {
      out.write('exit code ${result.exitCode}');
    }

    final text = out.toString();
    if (text.length > _maxOutputBytes) {
      return '${text.substring(0, _maxOutputBytes)}\n'
          '[truncated: output exceeded ${_maxOutputBytes ~/ 1024}KB]';
    }
    return text;
  }

  static List<String> _wrapArgs(String cli, List<String> args) {
    switch (cli) {
      case 'enforcer-cli':
        return ['-plaintext', 'localhost:50051', ...args];
      case 'bitcoin-cli':
        try {
          final conf = BitcoinCore().confFile();
          if (path.basename(conf) != 'bitcoin.conf') {
            return ['-conf=$conf', ...args];
          }
        } catch (_) {}
        return args;
      default:
        return args;
    }
  }
}
