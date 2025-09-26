import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';

class ProcessManager extends ChangeNotifier {
  final Directory appDir;

  ProcessManager({required this.appDir});

  Logger get log => GetIt.I.get<Logger>();

  final Map<String, ExitTuple> _exitTuples = {};
  ExitTuple? exited(Binary binary) => _exitTuples[binary.name];

  final Map<String, SailProcess> runningProcesses = {};

  final Map<String, Stream<String>> _stdoutStreams = {};
  final Map<String, Stream<String>> _stderrStreams = {};
  final Map<String, String> _finalErr = {};

  Stream<String>? stdout(Binary binary) => _stdoutStreams[binary.name];
  Stream<String>? stderr(Binary binary) => _stderrStreams[binary.name];
  bool running(Binary binary) => runningProcesses.containsKey(binary.name);

  Future<int> start(
    Binary binary,
    List<String> args,
    Future<void> Function() cleanup, {
    // Environment variables passed to the process, e.g RUST_BACKTRACE: 1
    Map<String, String> environment = const {},
  }) async {
    final file = await binary.resolveBinaryPath(appDir);

    // Windows doesn't do executable permissions
    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', file.path]);
      log.d('chmoded ${file.path}');
    }

    log.d('starting ${file.path} with args $args');

    final process = await Process.start(
      file.path,
      args,
      mode: ProcessStartMode.normal, // when the flutter app quits, this process quit
      environment: environment,
    );
    runningProcesses[binary.name] = SailProcess(
      binary: binary,
      pid: process.pid,
      cleanup: cleanup,
    );
    _exitTuples.remove(binary.name);

    // Let output streaming chug in the background

    // Capture stdout and stderr
    final stdoutController = StreamController<String>();
    final stderrController = StreamController<String>();

    log.d('Setting up stdout listener for ${file.path}');
    process.stdout
        .transform(systemEncoding.decoder)
        .listen(
          (data) {
            stdoutController.add(data);
            _finalErr[binary.name] = data;
            if (!isSpam(data)) {
              log.d('${file.path.split(Platform.pathSeparator).last}: $data');
            }
          },
          onError: (error, stack) {
            log.e('Stdout stream error: $error\n$stack');
          },
          onDone: () {
            log.d('stdout stream done for ${file.path}');
            stdoutController.close();
          },
        );

    log.d('Setting up stderr listener for ${file.path}');
    process.stderr
        .transform(systemEncoding.decoder)
        .listen(
          (data) {
            stderrController.add(data);
            if (!isSpam(data)) {
              // Strip ANSI color codes from the log output
              final cleanData = data.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
              log.e('${file.path}: $cleanData');
            }
          },
          onError: (error, stack) {
            log.e('Stderr stream error: $error\n$stack');
          },
          onDone: () {
            log.d('stderr stream done for ${file.path}');
            stderrController.close();
          },
        );

    // Store the streams for later access
    _stdoutStreams[binary.name] = stdoutController.stream;
    _stderrStreams[binary.name] = stderrController.stream;

    // By default, this doesn't resolve to anything
    var processExited = Completer<bool>();

    // Register a handler for when the process stops.
    unawaited(
      process.exitCode.then((code) async {
        try {
          log.i('process exit handler for code=$code binary=$binary pid=${process.pid} triggered');
          runningProcesses.remove(binary.name);

          var level = Level.info;
          var message = '';
          if (code != 0) {
            // exit code bad, it crashed!
            final finalErr = _finalErr[binary.name];
            final outLogs = await (_stdoutStreams[binary.name] ?? const Stream<String>.empty()).take(1).toList();
            if (finalErr != null) {
              log.i('finalerr present, using last message from stderr: $finalErr');
              message = finalErr;
            } else {
              log.i('no errlogs present, using last message from stdout: ${outLogs.last}');
              message = outLogs.last;
            }
          }

          log.log(level, '"${file.path}" exited with code $code');

          // Resolve the process exit future
          processExited.complete(true);

          // Forward to listeners that the process finished.
          _exitTuples[binary.name] = ExitTuple(code: code, message: message);
          // Close the stream controllers
          await stdoutController.close();
          await stderrController.close();
          _stderrStreams.remove(binary.name);
          _stdoutStreams.remove(binary.name);
          _finalErr.remove(binary.name);
        } finally {
          notifyListeners();
        }
      }),
    );

    // If the process exits within 0.5 second, it's not really properly started!
    final exited = await Future.any([
      Future.delayed(const Duration(milliseconds: 500), () {
        return false;
      }),
      processExited.future,
    ]);

    if (exited) {
      final tuple = _exitTuples[binary.name];
      throw '"${file.path}" exited with code ${tuple?.code}: ${tuple?.message}';
    }

    log.d('started "${file.path}" with pid ${process.pid}');

    notifyListeners();
    return process.pid;
  }

  Future<void> kill(Binary binary) async {
    final process = runningProcesses.values.firstWhereOrNull((p) => p.binary.name == binary.name);
    if (process == null) {
      log.w('Process not found for binary ${binary.name}');
      return;
    }

    await _shutdownSingle(process);

    // Wait for process to exit
    while (runningProcesses.containsKey(binary.name)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  bool isRunning(Binary binary) {
    return runningProcesses.containsKey(binary.name);
  }

  Future<void> stopAll() async {
    log.d('dispose process provider: killing all processes $runningProcesses');
    await Future.wait(runningProcesses.values.map((process) => _shutdownSingle(process)));
  }

  Future<void> _shutdownSingle(SailProcess process) async {
    log.i('attempting nice shutdown for pid=${process.pid}');

    try {
      // Try nice shutdown with timeout
      await Future.any([
        process.cleanup(),
        Future.delayed(const Duration(seconds: 2)).then((_) => throw TimeoutException('Nice shutdown timed out')),
      ]);
      log.d('nice shutdown successful for pid=${process.pid} binary=${process.binary.name}');
    } catch (error) {
      // If nice shutdown fails or times out, force kill
      log.e('nice shutdown failed, force killing pid=${process.pid}: $error');

      // Cross-platform process killing
      if (Platform.isWindows) {
        // On Windows, use taskkill or just kill without signal
        try {
          await Process.run('taskkill', ['/F', '/PID', '${process.pid}']);
        } catch (e) {
          // Fallback to Process.killPid without signal on Windows
          Process.killPid(process.pid);
        }
      } else {
        // On Unix-like systems, use SIGTERM first, then SIGKILL if needed
        try {
          Process.killPid(process.pid, ProcessSignal.sigterm);
          // Wait a bit for graceful shutdown
          await Future.delayed(const Duration(milliseconds: 500));
          // If still running, use SIGKILL
          Process.killPid(process.pid, ProcessSignal.sigkill);
        } catch (e) {
          log.e('Failed to kill process ${process.pid}: $e');
        }
      }
    } finally {
      runningProcesses.remove(process.binary.name);
      notifyListeners();
    }
  }
}

bool isSpam(String data) {
  if (data.contains('tower_http::trace::on_response')) {
    return true;
  }

  if (data.contains('tower_http') && data.contains('registry')) {
    return true;
  }

  if (data.contains('Ripemd160') && data.contains('bip300301_enforcer')) {
    return true;
  }

  if (data.contains('listed') && data.contains('wallet utxos in') && data.contains('bip300301_enforcer')) {
    return true;
  }

  if (data.contains(': wallet sync complete in')) {
    return true;
  }

  if (data.contains('initial_sync:sync_to_tip:sync_blocks')) {
    if (data.contains('updated current chain tip')) {
      return true;
    }

    // Extract block number (it's after "#" and before the first space)
    final startIndex = data.indexOf('#') + 1;
    final endIndex = data.indexOf(' ', startIndex);
    if (startIndex >= 0 && endIndex > startIndex) {
      final blockNumberStr = data.substring(startIndex, endIndex);
      final blockNumber = int.tryParse(blockNumberStr);

      if (blockNumber != null && blockNumber % 1000 != 0) {
        return true;
      }
    }

    return false;
  }

  // btc-buf prints this for every single bitcoin core request
  if (data.contains('rpc: fetch completed in')) {
    return true;
  }

  return false;
}

class SailProcess {
  final Binary binary;
  final int pid;
  Future<void> Function() cleanup;

  SailProcess({required this.binary, required this.pid, required this.cleanup});
}

class ExitTuple {
  final int code;
  final String message;

  ExitTuple({required this.code, required this.message});
}
