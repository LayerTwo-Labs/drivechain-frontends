import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';

class ProcessProvider extends ChangeNotifier {
  final Directory? appDir;

  ProcessProvider({
    this.appDir,
  });

  Logger get log => GetIt.I.get<Logger>();

  final Map<String, ExitTuple> _exitTuples = {};
  ExitTuple? exited(Binary binary) => _exitTuples[binary.name];

  final Map<String, SailProcess> runningProcesses = {};

  final Map<String, Stream<String>> _stdoutStreams = {};
  final Map<String, Stream<String>> _stderrStreams = {};

  Stream<String> stdout(Binary binary) => _stdoutStreams[binary.name] ?? const Stream.empty();
  Stream<String> stderr(Binary binary) => _stderrStreams[binary.name] ?? const Stream.empty();
  bool running(Binary binary) => runningProcesses.containsKey(binary.name);

  Future<int> start(
    Binary binary,
    List<String> args,
    Future<void> Function() cleanup,
  ) async {
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
    process.stdout.transform(systemEncoding.decoder).listen((data) {
      stdoutController.add(data);
      if (!isSpam(data)) {
        log.d('${file.path}: $data');
      }
    });

    process.stderr.transform(systemEncoding.decoder).listen((data) {
      stderrController.add(data);
      if (!isSpam(data)) {
        log.e('${file.path}: $data');
      }
    });

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

          var level = Level.info;
          var message = '';
          if (code != 0) {
            // exit code bad, it crashed!
            final errLogs = await (_stderrStreams[binary.name] ?? const Stream<String>.empty()).take(1).toList();
            final outLogs = await (_stdoutStreams[binary.name] ?? const Stream<String>.empty()).take(1).toList();
            if (errLogs.isNotEmpty) {
              log.i('errlogs present, using last message from stderr: ${errLogs.last}');
              message = errLogs.last;
            } else {
              log.i('no errlogs present, using last message from stdout: ${outLogs.last}');
              message = outLogs.last;
            }
          }

          log.log(level, '"${file.path}" exited with code $code');

          // Resolve the process exit future
          processExited.complete(true);

          // Forward to listeners that the process finished.
          _exitTuples[binary.name] = ExitTuple(
            code: code,
            message: message,
          );
          runningProcesses.remove(binary.name);
          // Close the stream controllers
          await stdoutController.close();
          await stderrController.close();
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
    final process = runningProcesses.values.firstWhere(
      (p) => p.binary.name == binary.name,
      orElse: () => throw Exception('Process not found for binary ${binary.name}'),
    );

    await _shutdownSingle(process);

    // Wait for process to exit
    while (runningProcesses.containsKey(binary.name)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  bool isRunning(Binary binary) {
    return runningProcesses.containsKey(binary.name);
  }

  Future<void> shutdown() async {
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
      // If nice shutdown fails or times out, force kill with SIGTERM
      log.e('nice shutdown failed, killing with SIGINT pid=${process.pid}: $error');
      Process.killPid(process.pid, ProcessSignal.sigint);
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

  SailProcess({
    required this.binary,
    required this.pid,
    required this.cleanup,
  });
}

class ExitTuple {
  final int code;
  final String message;

  ExitTuple({
    required this.code,
    required this.message,
  });
}
