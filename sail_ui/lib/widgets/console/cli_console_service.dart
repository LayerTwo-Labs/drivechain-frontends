import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

/// Console view backed by the on-disk CLI binaries (bitcoin-cli, …) plus
/// a synthetic enforcer-cli powered by the bitwindowd JSON bridge. The real
/// `bitcoin-cli` is shipped alongside `bitcoind` in the Bitcoin Core archive
/// and discovered on disk; the enforcer ships no CLI of its own, hence the
/// JSON-bridge wrapper.
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
              'No CLI services available.',
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
  static const _helpTimeout = Duration(seconds: 10);

  /// Real CLI binaries we discover on disk and exec. Every binary downloaded
  /// by the orchestrator lands in BitWindow's `assets/bin/` (the Bitcoin Core
  /// archive ships `bitcoin-cli`, `bitcoin-util`, etc. alongside `bitcoind`).
  /// The enforcer is intentionally absent — it has no native CLI; we expose
  /// it via the synthetic [_buildEnforcerService] instead.
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
    'Drivechaind': 'drivechain-cli',
  };

  /// The orchestrator binary each CLI ships with. Every Core variant owns a
  /// folder, so only the folder the daemon runs from holds the matching CLI.
  static const _cliToBinary = {
    'bitcoin-cli': 'bitcoind',
    'bitwindow-cli': 'bitwindowd',
    'thunder-cli': 'thunder',
    'truthcoin-cli': 'truthcoin',
    'photon-cli': 'photon',
    'bitnames-cli': 'bitnames',
    'bitassets-cli': 'bitassets',
    'coinshift-cli': 'coinshift',
    'zside-cli': 'zside',
    'drivechain-cli': 'drivechaind',
  };

  /// Discover available CLI executables on disk. Returns map of cli name →
  /// absolute path, each taken from the folder its daemon runs from.
  static Future<Map<String, String>> discoverCLIs() async {
    final available = <String, String>{};
    final exeSuffix = Platform.isWindows ? '.exe' : '';

    final bindir = binDir(GetIt.I.get<BinaryProvider>().appDir.path);
    if (!bindir.existsSync()) {
      return available;
    }

    final daemonDirs = await _daemonDirs();

    for (final cliName in _binaryToCLI.values) {
      final filename = '$cliName$exeSuffix';
      final found = _besideDaemon(daemonDirs[_cliToBinary[cliName]], filename) ?? _findExecutable(bindir, filename);
      if (found != null) {
        await _ensureExecutable(found);
        available[cliName] = found.path;
      }
    }

    return available;
  }

  /// The directory each daemon runs from, by orchestrator binary name. An
  /// unreachable daemon returns an empty map, and the caller searches instead.
  static Future<Map<String, String>> _daemonDirs() async {
    if (!GetIt.I.isRegistered<OrchestratorRPC>()) {
      return {};
    }
    try {
      // forceBackend reports the real daemon, not the Flutter test build.
      final resp = await GetIt.I.get<OrchestratorRPC>().listBinaries(forceBackend: true);
      return {
        for (final b in resp.binaries)
          if (b.binaryPath.isNotEmpty) b.name: path.dirname(b.binaryPath),
      };
    } catch (e) {
      GetIt.I.get<Logger>().w('discoverCLIs: the orchestrator did not report binary paths: $e');
      return {};
    }
  }

  static File? _besideDaemon(String? daemonDir, String filename) {
    if (daemonDir == null) {
      return null;
    }
    final beside = File(path.join(daemonDir, filename));
    return beside.existsSync() ? beside : null;
  }

  static File? _findExecutable(Directory bindir, String filename) {
    final direct = File(path.join(bindir.path, filename));
    if (direct.existsSync()) {
      return direct;
    }

    final matches = <File>[];
    for (final entity in bindir.listSync()) {
      if (entity is! Directory) {
        continue;
      }
      final inSubdir = File(path.join(entity.path, filename));
      if (inSubdir.existsSync()) {
        matches.add(inSubdir);
      }
    }
    // listSync gives no order, so a pick between two variants is arbitrary.
    return matches.length == 1 ? matches.first : null;
  }

  static Future<void> _ensureExecutable(File f) async {
    if (Platform.isMacOS || Platform.isLinux) {
      await Process.run('chmod', ['+x', f.path]);
    }
  }

  /// Build console services: real CLI binaries on disk, plus the synthetic
  /// enforcer-cli (gRPC has no native CLI client we can ship).
  static Future<List<ConsoleService>> buildServices() async {
    final services = <ConsoleService>[];

    final clis = await discoverCLIs();
    services.addAll(
      await Future.wait(
        clis.entries.map((entry) async {
          final commands = await _loadCommands(entry.key, entry.value);
          return ConsoleService(
            name: entry.key,
            commands: [entry.key, ...commands],
            execute: (command, args) {
              // Drop a leading cli-name (explicit form) so `bitcoin-cli generate 1`
              // and bare `generate 1` produce the same argv to the binary.
              final effectiveArgs = command == entry.key ? args : [command, ...args];
              return _execProcess(entry.key, entry.value, effectiveArgs);
            },
          );
        }),
      ),
    );

    final enforcer = _buildEnforcerService();
    if (enforcer != null) {
      services.add(enforcer);
    }

    return services;
  }

  /// The command list the binary reports, so the console can complete it. A
  /// daemon that is down reports none, and the console still runs commands.
  static Future<List<String>> _loadCommands(String cli, String exePath) async {
    try {
      final result = await Process.run(
        exePath,
        _wrapArgs(cli, ['help']),
        runInShell: false,
      ).timeout(_helpTimeout);
      return _parseHelp('${result.stdout}\n${result.stderr}');
    } catch (_) {
      return const [];
    }
  }

  /// Reads command names out of a `help` listing. Bitcoin Core prints one
  /// command per unindented line under `== Group ==` headers; a Go or Rust CLI
  /// prints them indented under a `COMMANDS:` header.
  static List<String> _parseHelp(String out) {
    final names = <String>{};
    final sectionHeader = RegExp(r'^[A-Za-z][A-Za-z ]*:$');
    final commandName = RegExp(r'^[a-z][a-z0-9_-]*$');
    var inCommandSection = false;

    for (final raw in out.split('\n')) {
      final line = raw.trimRight();
      if (line.isEmpty || line.startsWith('==')) {
        continue;
      }
      final trimmed = line.trim();
      if (sectionHeader.hasMatch(trimmed)) {
        inCommandSection = trimmed.toLowerCase() == 'commands:';
        continue;
      }
      // An indented line is a command only inside a COMMANDS: section. Outside
      // one it is a continuation of the line above.
      if (line.startsWith(' ') && !inCommandSection) {
        continue;
      }
      final token = trimmed.split(RegExp(r'\s+')).first;
      if (commandName.hasMatch(token)) {
        names.add(token);
      }
    }

    final sorted = names.toList()..sort();
    return sorted;
  }

  /// Synthetic `enforcer-cli` powered by the bitwindowd JSON bridge at
  /// `localhost:30301/<method>` — bridge-transcodes JSON to the enforcer's
  /// gRPC. Usage:
  ///
  /// `enforcer-cli cusf.mainchain.v1.ValidatorService/GetChainTip`
  /// `enforcer-cli cusf.mainchain.v1.ValidatorService/GetSidechains {}`
  static ConsoleService? _buildEnforcerService() {
    if (!GetIt.I.isRegistered<EnforcerRPC>()) {
      return null;
    }
    final rpc = GetIt.I.get<EnforcerRPC>();
    final commands = <String>['enforcer-cli', ...rpc.getMethods()];
    return ConsoleService(
      name: 'enforcer-cli',
      commands: commands,
      execute: (command, args) async {
        String method;
        List<String> rest;
        if (command == 'enforcer-cli') {
          if (args.isEmpty) {
            return 'usage: enforcer-cli <Service/Method> [json_body]';
          }
          method = args.first;
          rest = args.sublist(1);
        } else {
          method = command;
          rest = args;
        }

        final body = rest.isEmpty ? '{}' : rest.join(' ');
        try {
          final result = await rpc.callRAW(method, body).timeout(_commandTimeout);
          return _formatJson(result);
        } on TimeoutException {
          throw 'rpc timed out after ${_commandTimeout.inMinutes}m';
        }
      },
    );
  }

  static String _formatJson(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      try {
        return const JsonEncoder.withIndent('  ').convert(jsonDecode(value));
      } catch (_) {
        return value;
      }
    }
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  static Future<String> _execProcess(
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
    if (stdout is String && stdout.isNotEmpty) {
      out.write(stdout);
    }
    if (stderr is String && stderr.isNotEmpty) {
      if (out.isNotEmpty) {
        out.write('\n');
      }
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
