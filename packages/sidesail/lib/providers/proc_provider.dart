import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class ProcessProvider extends ChangeNotifier {
  ProcessProvider();

  Logger get log => GetIt.I.get<Logger>();

  // List of currently running processes.
  List<int> pids = [];

  final Map<int, int> _exitCodes = {};
  final List<int> _runningProcesses = [];

  final Map<int, Stream<String>> _stdoutStreams = {};
  final Map<int, Stream<String>> _stderrStreams = {};

  Stream<String> stdout(int pid) => _stdoutStreams[pid] ?? const Stream.empty();
  Stream<String> stderr(int pid) => _stderrStreams[pid] ?? const Stream.empty();
  bool running(int pid) => _runningProcesses.contains(pid);

  // Starts a binary located in the asset bundle included with the app.
  Future<int> start(BuildContext context, String binary, List<String> args) async {
    if (Platform.isWindows) {
      binary = '$binary.exe';
    }
    // We're NOT looking up here based on platform and architecture. That is instead
    // handled at app bundling time, where it's up the person/process cutting the
    // release to place the appropriate binaries in the correct place.
    final binResource = await DefaultAssetBundle.of(context).load(
      // Assets don't operate with platform path separators, just /
      'assets/bin/$binary',
    );

    final temp = await getTemporaryDirectory();

    final ts = DateTime.now();
    // Add a random element to the file path. Windows doesn't like
    // it when two processes open the same file...
    final randDir = Directory(
      filePath([
        temp.path,
        // Add a random element to the file path. Windows doesn't like
        // it when two processes open the same file...
        ts.millisecondsSinceEpoch.toString(),
      ]),
    );
    await randDir.create();

    final file = File(
      filePath([
        randDir.path,
        binary,
      ]),
    );

    // Have to convert the ByteData -> List<int>. Side note: why tf does writeAsBytes
    // operate on a list of numbers? Jesus
    // https://stackoverflow.com/a/50121777
    final buffer = binResource.buffer;
    await file.writeAsBytes(
      buffer.asUint8List(binResource.offsetInBytes, binResource.lengthInBytes),
    );

    // Windows doesn't do executable permissions, apparently
    if (!Platform.isWindows) {
      // Must be executable before we can start.
      await Process.run('chmod', ['+x', file.path]);
    }

    log.d('starting $binary with args $args');

    final process = await Process.start(
      file.path,
      args,
      mode: ProcessStartMode.normal, // when the flutter app quits, this process quit
    );
    _runningProcesses.add(process.pid);

    // Let output streaming chug in the background

    // Proper logs are written here
    _stdoutStreams[process.pid] = process.stdout.transform(utf8.decoder);

    // Error messages while starting up are written here
    _stderrStreams[process.pid] = process.stderr.transform(utf8.decoder);

    // By default, this doesn't resolve to anything
    var processExited = Completer<bool>();

    // Register a handler for when the process stops.
    unawaited(
      process.exitCode.then((code) async {
        var level = Level.error;
        // Node software exited with a success code. Someone called
        // `drivechain-cli stop`?
        if (code == 0) {
          level = Level.info;
        }

        final errLogs = await (_stderrStreams[process.pid] ?? const Stream.empty()).toList();
        _stderrStreams[process.pid] = Stream.fromIterable(errLogs);

        log.log(level, '"$binary" exited with code $code: ${errLogs.last}');

        // Resolve the process exit future
        processExited.complete(true);

        // Forward to listeners that the process finished.
        _exitCodes[process.pid] = code;
        _runningProcesses.remove(process.pid);
        notifyListeners();
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
      final errLogs = await (_stderrStreams[process.pid] ?? const Stream.empty()).toList();
      _stderrStreams[process.pid] = Stream.fromIterable(errLogs);
      throw '"$binary" exited with code ${_exitCodes[process.pid]}: ${errLogs.last}';
    }

    log.d('started "$binary" with pid ${process.pid}');

    notifyListeners();
    return process.pid;
  }

  @override
  void dispose() {
    super.dispose();

    log.d('dispose process provider: killing processes $_runningProcesses');
    _runningProcesses.forEach(Process.killPid);
  }
}

/// Join a list of filepath segments based on the underlying platform
/// path separator
String filePath(List<String> segments) {
  return segments.where((element) => element.isNotEmpty).join(Platform.pathSeparator);
}
