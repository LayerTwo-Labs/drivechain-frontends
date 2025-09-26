import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:xterm/xterm.dart';

class IntegratedConsoleView extends StatefulWidget {
  const IntegratedConsoleView({super.key});

  @override
  State<IntegratedConsoleView> createState() => _IntegratedConsoleViewState();
}

class _IntegratedConsoleViewState extends State<IntegratedConsoleView> {
  // set up a terminal
  final terminal = Terminal(maxLines: 1000);
  final terminalController = TerminalController();
  // using flutter_pty to start a shell session
  late final Pty pty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then((_) {
      if (mounted) _startPty();
    });
  }

  void _startPty() async {
    // Display welcome message BEFORE starting the shell
    final environment = await _setupTerminal();

    pty = Pty.start(
      _getShell(),
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
      environment: environment,
    );

    pty.output.cast<List<int>>().transform(Utf8Decoder()).listen(terminal.write);

    unawaited(
      pty.exitCode.then((code) {
        terminal.write('the process exited with exit code $code');
      }),
    );

    terminal.onOutput = (data) {
      final processedData = _processCommand(data);
      pty.write(const Utf8Encoder().convert(processedData));
    };

    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };
  }

  String _processCommand(String data) {
    // Check if the command starts with bitcoin-cli and doesn't already have the required params
    final trimmed = data.trim();
    if (trimmed.startsWith('bitcoin-cli') && !trimmed.contains('-rpcuser=')) {
      // Insert the default parameters after bitcoin-cli
      final parts = trimmed.split(' ');
      if (parts.isNotEmpty && parts[0] == 'bitcoin-cli') {
        final network = GetIt.I.get<SettingsProvider>().network;
        final confFile = BitcoinCore().confFile();
        parts.insert(3, '-conf=$confFile');

        switch (network) {
          case Network.NETWORK_REGTEST:
            parts.insert(4, '-regtest');
            break;

          case Network.NETWORK_TESTNET:
            parts.insert(4, '-testnet');
            break;

          case Network.NETWORK_SIGNET:
            parts.insert(4, '-signet');
            break;

          case Network.NETWORK_MAINNET:
            break;

          default:
            parts.insert(4, '-regtest');
            break;
        }

        return '${parts.join(' ')}\n';
      }
    }

    if (trimmed.startsWith('enforcer-cli')) {
      // TODO: CREATE AN ALIAS for enforcier-cli
      // WHEN THE USER TYPES IN enforcer-cli, TRANSLATE IT TO grpcurl -plaintext localhost:50051
    }

    return data;
  }

  Future<Map<String, String>> _setupTerminal() async {
    final env = Map<String, String>.from(Platform.environment);
    // Setup the PATH variable, adding any binaries we found in frontend-folders
    final currentPath = env['PATH'] ?? '';
    final extraBinaryPaths = await _getFrontendBinaryPaths();
    final newPath = extraBinaryPaths.isEmpty ? currentPath : '${extraBinaryPaths.join(':')}:$currentPath';

    // Set up shell prompt to show we're in console mode
    env['PATH'] = newPath;
    env['PS1'] = r'Console> ';

    return env;
  }

  Future<List<String>> _getFrontendBinaryPaths() async {
    final paths = <String>[];
    final Map<String, bool> availableCLIs = {};

    final allBinaries = [BitWindow(), Thunder(), BitNames(), BitAssets(), ZSide()];
    final binaryToCLI = {
      'BitcoinCore': 'bitcoin-cli',
      'Enforcer': 'drivechain-cli',
      'BitWindow': 'bitwindow-cli',
      'Thunder': 'thunder-cli',
      'BitNames': 'bitnames-cli',
      'BitAssets': 'bitassets-cli',
      'ZSide': 'zside-cli',
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
            final fileName = entity.path.split('/').last;

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

    final binaryPaths = paths.where((p) => Directory(p).existsSync()).toList();

    // enforcer-cli is just a grpcurl-wrapper, so they always have it
    availableCLIs['enforcer-cli'] = true;
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
        '\r\n\x1b[93mTo get started, try typing `bitcoin-cli help` or `bitcoin-cli getblockchaininfo`\x1b[0m\r\n\r\n',
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
    pty.kill();
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
