import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:xterm/xterm.dart';

class IntegratedConsoleView extends StatefulWidget {
  const IntegratedConsoleView({super.key});

  @override
  State<IntegratedConsoleView> createState() => _IntegratedConsoleViewState();
}

class _IntegratedConsoleViewState extends State<IntegratedConsoleView> {
  final terminal = Terminal(maxLines: 1000);
  final terminalController = TerminalController();
  Pty? pty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then((_) {
      if (mounted) _startPty();
    });
  }

  void _startPty() async {
    try {
      final environment = await _setupTerminal();

      final started = Pty.start(
        _getShell(),
        columns: terminal.viewWidth,
        rows: terminal.viewHeight,
        environment: environment,
      );
      pty = started;

      // Use systemEncoding so Windows codepages (CP437, CP1252 etc.) decode
      // correctly instead of crashing on non-UTF8 bytes.
      started.output
          .cast<List<int>>()
          .transform(systemEncoding.decoder)
          .listen(
            terminal.write,
            onError: (error) {
              terminal.write('\r\n[terminal output error: $error]\r\n');
            },
          );

      unawaited(
        started.exitCode.then((code) {
          terminal.write('\r\nthe process exited with exit code $code');
        }),
      );

      // Create enforcer-cli alias after shell starts
      Future.delayed(const Duration(milliseconds: 100), () {
        _createEnforcerAlias();
      });

      terminal.onOutput = (data) {
        pty?.write(Uint8List.fromList(systemEncoding.encode(data)));
      };

      terminal.onResize = (w, h, pw, ph) {
        pty?.resize(h, w);
      };
    } catch (e) {
      terminal.write('\r\n[failed to start terminal: $e]\r\n');
    }
  }

  void _createEnforcerAlias() {
    final p = pty;
    if (p == null) return;

    final shell = _getShell();
    final confFile = BitcoinCore().confFile();
    String aliasCommands;

    // Only create bitcoin-cli alias if we're not using the default bitcoin.conf
    final needsBitcoinAlias = path.basename(confFile) != 'bitcoin.conf';

    if (shell.contains('fish')) {
      // Fish shell uses functions instead of aliases for complex commands
      aliasCommands = 'function enforcer-cli; grpcurl -plaintext localhost:50051 \$argv; end\n';
      if (needsBitcoinAlias) {
        aliasCommands += 'function bitcoin-cli; command bitcoin-cli -conf=$confFile \$argv; end\n';
      }
    } else if (shell.contains('bash') || shell.contains('zsh')) {
      // Bash and Zsh use standard alias syntax for simple cases, functions for complex ones
      aliasCommands = "alias enforcer-cli='grpcurl -plaintext localhost:50051'\n";
      if (needsBitcoinAlias) {
        aliasCommands += 'bitcoin-cli() { command bitcoin-cli -conf=$confFile "\$@"; }\n';
      }
    } else {
      // Default to bash-style
      aliasCommands = "alias enforcer-cli='grpcurl -plaintext localhost:50051'\n";
      if (needsBitcoinAlias) {
        aliasCommands += 'bitcoin-cli() { command bitcoin-cli -conf=$confFile "\$@"; }\n';
      }
    }

    p.write(Uint8List.fromList(systemEncoding.encode(aliasCommands)));
  }

  Future<Map<String, String>> _setupTerminal() async {
    final env = Map<String, String>.from(Platform.environment);
    final currentPath = env['PATH'] ?? '';
    final extraBinaryPaths = await _getFrontendBinaryPaths();
    final separator = Platform.isWindows ? ';' : ':';
    final newPath = extraBinaryPaths.isEmpty ? currentPath : '${extraBinaryPaths.join(separator)}$separator$currentPath';

    env['PATH'] = newPath;
    env['PS1'] = r'Console> ';

    return env;
  }

  Future<List<String>> _getFrontendBinaryPaths() async {
    final paths = <String>[];
    final Map<String, bool> availableCLIs = {};

    final allBinaries = [BitWindow(), Thunder(), BitNames(), BitAssets(), ZSide(), GRPCurl()];
    final binaryToCLI = {
      'BitcoinCore': 'bitcoin-cli',
      'BitWindow': 'bitwindow-cli',
      'Thunder': 'thunder-cli',
      'BitNames': 'bitnames-cli',
      'BitAssets': 'bitassets-cli',
      'ZSide': 'zside-cli',
      'GRPCurl': 'grpcurl',
    };

    for (final binary in allBinaries) {
      final bindir = binDir(binary.frontendDir());
      final binaryName = binary.runtimeType.toString();

      if (bindir.existsSync()) {
        paths.add(bindir.path);

        // Check if the actual CLI executable exists
        final cliName = binaryToCLI[binaryName];
        if (cliName != null) {
          final cliFile = File('${bindir.path}/$cliName${Platform.isWindows ? '.exe' : ''}');

          if (cliFile.existsSync()) {
            if (Platform.isMacOS || Platform.isLinux) {
              await Process.run('chmod', ['+x', cliFile.path]);
            }
            availableCLIs[cliName] = true;
          }
        }

        // Also scan subdirectories and check for CLI files
        for (final entity in bindir.listSync()) {
          if (entity is Directory) {
            paths.add(entity.path);

            // Check for CLI files in subdirectories too
            for (final cliEntry in binaryToCLI.entries) {
              final cliName = cliEntry.value;
              final cliFile = File('${entity.path}/$cliName${Platform.isWindows ? '.exe' : ''}');

              if (cliFile.existsSync()) {
                if (Platform.isMacOS || Platform.isLinux) {
                  await Process.run('chmod', ['+x', cliFile.path]);
                }
                availableCLIs[cliName] = true;
              }
            }
          } else if (entity is File) {
            // Check if this file is one of our CLI executables
            final fileName = path.basename(entity.path);

            if (binaryToCLI.values.contains(fileName)) {
              if (Platform.isMacOS || Platform.isLinux) {
                await Process.run('chmod', ['+x', entity.path]);
              }
              availableCLIs[fileName] = true;
            }
          }
        }
      }
    }

    // toSet removes duplicates
    final binaryPaths = paths.where((p) => Directory(p).existsSync()).toSet().toList();

    // enforcer-cli is just a grpcurl-wrapper, so it's available if grpcurl is available
    availableCLIs['enforcer-cli'] = availableCLIs['grpcurl'] ?? false;
    _sendWelcomeMessage(availableCLIs);

    return binaryPaths;
  }

  void _sendWelcomeMessage(Map<String, bool> availableCLIs) {
    final cliDescriptions = {
      'bitcoin-cli': 'Bitcoin Core commands',
      'enforcer-cli': 'Enforcer commands',
      'drivechain-cli': 'Drivechain enforcer commands',
      'thunder-cli': 'Thunder sidechain',
      'bitnames-cli': 'Bitnames sidechain',
      'bitassets-cli': 'BitAssets sidechain',
      'zside-cli': 'ZSide sidechain',
    };

    terminal.write('\r\nWelcome to SideShell, your friendly neighbourhood CLI\r\n');
    terminal.write('\x1b[92mYou have access to:\x1b[0m\r\n');

    if (availableCLIs.isEmpty) {
      terminal.write('  No CLI binaries found. Make sure binaries are downloaded.\r\n');
    } else {
      for (final entry in availableCLIs.entries) {
        if (entry.value) {
          final description = cliDescriptions[entry.key] ?? 'Available commands';
          terminal.write('• ${entry.key} ($description)\r\n');
        }
      }
    }

    if (availableCLIs['bitcoin-cli'] == true) {
      terminal.write(
        '\r\n\x1b[93mTo get started, try typing `bitcoin-cli help` or `enforcer-cli describe`\x1b[0m\r\n\r\n',
      );
    } else {
      terminal.write('\r\n');
    }
  }

  String _getShell() {
    if (Platform.isMacOS || Platform.isLinux) {
      return Platform.environment['SHELL'] ?? 'bash';
    }

    if (Platform.isWindows) {
      return 'cmd.exe';
    }

    throw Exception('unsupported platform ${Platform.operatingSystem}');
  }

  @override
  void dispose() {
    pty?.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TerminalView(
      terminal,
      controller: terminalController,
      autofocus: true,
      backgroundOpacity: 1.0,
      onSecondaryTapDown: (details, offset) async {
        final selection = terminalController.selection;
        if (selection != null) {
          final text = terminal.buffer.getText(selection);
          terminalController.clearSelection();
          await Clipboard.setData(ClipboardData(text: text));
        } else {
          final data = await Clipboard.getData('text/plain');
          final text = data?.text;
          if (text != null) {
            terminal.paste(text);
          }
        }
      },
    );
  }
}
