import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/config/binaries.dart';

class ProcessProvider extends ChangeNotifier {
  final Directory? appDir;

  ProcessProvider({
    this.appDir,
  });

  Logger get log => GetIt.I.get<Logger>();

  final Map<String, ExitTuple> _exitTuples = {};
  ExitTuple? exited(Binary binary) => _exitTuples[binary.binary];

  final Map<String, SailProcess> runningProcesses = {};

  final Map<String, Stream<String>> _stdoutStreams = {};
  final Map<String, Stream<String>> _stderrStreams = {};

  Stream<String> stdout(Binary binary) => _stdoutStreams[binary.binary] ?? const Stream.empty();
  Stream<String> stderr(Binary binary) => _stderrStreams[binary.binary] ?? const Stream.empty();
  bool running(Binary binary) => runningProcesses.containsKey(binary.binary);

  Future<int> start(
    String binary,
    List<String> args,
    Future<void> Function() cleanup,
  ) async {
    final file = await _resolveBinaryPath(binary);

    // Windows doesn't do executable permissions
    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', file.path]);
    }

    log.d('starting ${file.path} with args $args');

    final process = await Process.start(
      file.path,
      args,
      mode: ProcessStartMode.normal, // when the flutter app quits, this process quit
    );
    runningProcesses[binary] = SailProcess(
      binary: binary,
      pid: process.pid,
      cleanup: cleanup,
    );
    _exitTuples.remove(binary);

    // Let output streaming chug in the background

    // Capture stdout and stderr
    final stdoutController = StreamController<String>();
    final stderrController = StreamController<String>();
    process.stdout.transform(utf8.decoder).listen((data) {
      stdoutController.add(data);
      if (!isSpam(data)) {
        log.d('${file.path}: $data');
      }
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      stderrController.add(data);
      if (!isSpam(data)) {
        log.e('${file.path}: $data');
      }
    });

    // Store the streams for later access
    _stdoutStreams[binary] = stdoutController.stream;
    _stderrStreams[binary] = stderrController.stream;

    // By default, this doesn't resolve to anything
    var processExited = Completer<bool>();

    // Register a handler for when the process stops.
    unawaited(
      process.exitCode.then((code) async {
        try {
          log.i('process exit handler for binary=$binary pid=${process.pid} triggered');

          var level = Level.info;
          var message = '';
          if (code != 0) {
            // exit code bad, it crashed!
            final errLogs = await (_stderrStreams[binary] ?? const Stream<String>.empty()).take(1).toList();
            if (errLogs.isNotEmpty) {
              message = errLogs.last;
            }
          }

          log.log(level, '"${file.path}" exited with code $code');

          // Resolve the process exit future
          processExited.complete(true);

          // Forward to listeners that the process finished.
          _exitTuples[binary] = ExitTuple(
            code: code,
            message: message,
          );
          runningProcesses.remove(binary);
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
      final tuple = _exitTuples[binary];
      throw '"${file.path}" exited with code ${tuple?.code}: ${tuple?.message}';
    }

    log.d('started "${file.path}" with pid ${process.pid}');

    notifyListeners();
    return process.pid;
  }

  Future<void> kill(Binary binary) async {
    final process = runningProcesses.values.firstWhere(
      (p) {
        final matched = Binary.fromBinary(p.binary);
        return matched?.runtimeType == binary.runtimeType;
      },
      orElse: () => throw Exception('Process not found for binary ${binary.binary}'),
    );

    await _shutdownSingle(process);

    // Wait for process to exit
    while (runningProcesses.containsKey(binary.binary)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  bool isRunning(Binary binary) {
    return runningProcesses.values.any((p) {
      final matched = Binary.fromBinary(p.binary);
      return matched?.runtimeType == binary.runtimeType;
    });
  }

  Future<void> shutdown() async {
    log.d('dispose process provider: killing processes $runningProcesses');
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
      log.d('nice shutdown successful for pid=${process.pid}');
    } catch (error) {
      // If nice shutdown fails or times out, force kill with SIGTERM
      log.e('nice shutdown failed, killing with SIGTERM pid=${process.pid}: $error');
      Process.killPid(process.pid, ProcessSignal.sigterm);
    } finally {
      runningProcesses.remove(process.binary);
      notifyListeners();
    }
  }

  Future<File> _resolveBinaryPath(String binary) async {
    // First find all possible paths the binary might be in,
    // such as .exe, .app, /assets/bin, $datadir/assets etc.
    final possiblePaths = _getPossibleBinaryPaths(binary);

    // Check if binary exists in any of the possible paths
    for (final binaryPath in possiblePaths) {
      if (Directory(binaryPath).existsSync() || File(binaryPath).existsSync()) {
        var resolvedPath = binaryPath;
        // Handle .app bundles on macOS
        if (Platform.isMacOS && (binary.endsWith('.app') || binaryPath.endsWith('.app'))) {
          resolvedPath = path.join(
            binaryPath,
            'Contents',
            'MacOS',
            path.basenameWithoutExtension(binaryPath),
          );
        }
        return File(resolvedPath);
      }
    }

    return _fileFromAssetsBundle(binary, possiblePaths);
  }

  Future<File> _fileFromAssetsBundle(String binary, List<String> possiblePaths) async {
    // If not found in datadir/assets, try loading from bundled assets
    ByteData? binResource;
    String? foundPath;

    for (final assetPath in possiblePaths) {
      try {
        binResource = await rootBundle.load('assets/bin/$assetPath');
        foundPath = assetPath;
        break;
      } catch (e) {
        continue;
      }
    }

    if (binResource == null || foundPath == null) {
      throw Exception('Could not find binary $binary in any location');
    }

    // Create temp file
    final temp = await getTemporaryDirectory();
    final ts = DateTime.now();
    final randDir = Directory(
      filePath([temp.path, ts.millisecondsSinceEpoch.toString()]),
    );
    await randDir.create();

    final file = File(filePath([randDir.path, foundPath]));

    final buffer = binResource.buffer;
    await file.writeAsBytes(
      buffer.asUint8List(binResource.offsetInBytes, binResource.lengthInBytes),
    );

    return file;
  }

  List<String> _getPossibleBinaryPaths(String baseBinary) {
    final paths = <String>[baseBinary];
    // Add platform-specific extensions
    if (Platform.isWindows) {
      paths.add('$baseBinary.exe');
    }

    if (appDir != null) {
      final assetPath = path.join(appDir!.path, 'assets');
      // Add asset directory variants
      paths.addAll([
        path.join(assetPath, baseBinary),
        if (Platform.isWindows) path.join(assetPath, '$baseBinary.exe'),
      ]);
    }

    return paths;
  }
}

bool isSpam(String data) {
  if (data.contains('tower_http::trace::on_response')) {
    return true;
  }

  if (data.contains('tower_http') && data.contains('registry')) {
    return true;
  }

  return false;
}

class SailProcess {
  final String binary;
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
