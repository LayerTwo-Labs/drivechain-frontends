// class for connecting to a basic bitcoin core rpc interface
// also includes functions for checking whether the connection
// is live, and if not, what error message the node returned
import 'dart:async';
import 'dart:io';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidesail/app.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/providers/process_provider.dart';

// when you implement this class, you should extend a ChangeNotifier, to get
// a proper implementation of notifyListeners(), e.g:
// YourClass extends ChangeNotifier implements RPCConnection
abstract class RPCConnection extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  RPCConnection({
    required this.conf,
  });

  // ping method that tests whether the connection is successful
  // should throw if call is not successful
  Future<void> ping();

  bool initializingBinary = false;

  Future<(bool, String?)> testConnection() async {
    try {
      await ping();
      connectionError = null;
      connected = true;
    } catch (error) {
      log.t('could not ping: ${error.toString()}!');

      // Only update the error message if we're finished with binary init
      if (!initializingBinary) {
        String msg = error.toString();

        if (error is SocketException) {
          msg = error.osError?.message ?? 'could not connect at ${conf.host}:${conf.port}';
        } else if (error is HTTPException) {
          // gotta parse out the error...

          // Looks like this: SocketException: Connection refused (OS Error: Connection refused, errno = 61), address = localhost, port = 55248

          msg = error.message;
          RegExp regExp = RegExp(r'\(([^)]+)\)');
          final match = regExp.firstMatch(error.message);
          if (match != null) {
            msg = match.group(1)!;
          }
        }

        connectionError = msg;
      }
      connected = false;
    } finally {
      notifyListeners();
    }

    return (connected, connectionError);
  }

  // values for tracking connection state, and error (if any)
  SingleNodeConnectionSettings conf;
  String? connectionError;
  bool connected = false;

  Future<void> initBinary(
    BuildContext context,
    String binary,
    List<String> args,
  ) async {
    initializingBinary = true;
    notifyListeners();

    final processes = GetIt.I.get<ProcessProvider>();

    log.d('init binaries: checking $binary connection ${conf.host}:${conf.port}');

    // If we managed to connect to an already running daemon, we're finished here!
    if (connected) {
      log.d('init binaries: $binary is already running, not doing anything');
      initializingBinary = false;
      notifyListeners();
      return;
    }

    if (!context.mounted) {
      initializingBinary = false;
      notifyListeners();
      return;
    }

    // cancel any timers, to not override error message
    // resulting from the process not being able to start
    _connectionTimer?.cancel();

    log.d('init binaries: starting $binary ${args.join(" ")}');

    int pid;
    try {
      pid = await processes.start(context, binary, args);
      log.d('init binaries: started $binary with PID $pid');
    } catch (err) {
      log.e('init binaries: could not start $binary daemon', error: err);
      initializingBinary = false;
      connectionError = 'could not start $binary daemon: $err';
      connected = false;
      notifyListeners();
      return;
    }

    // Add timeout?
    log.i('init binaries: waiting for $binary connection');

    const timeout = Duration(seconds: 5);
    try {
      await Future.any([
        // Happy case: able to connect
        waitForBoolToBeTrue(() async {
          final (connected, _) = await testConnection();
          return connected;
        }),

        Future.delayed(timeout).then(
          (_) => throw "'$binary' connection timed out after ${timeout.inSeconds}s",
        ),
        // Timeout case!
      ]);

      log.i('init binaries: $binary connected');

      initializingBinary = false;
      log.i('init binaries: starting connection timer for $binary');
      startConnectionTimer();
    } catch (err) {
      log.e("init binaries: couldn't connect to $binary", error: err);

      // We've quit! Assuming there's error logs, somewhere.
      if (!processes.running(pid)) {
        final logs = await processes.stderr(pid).toList();
        log.e('$binary exited before we could connect, dumping logs');
        for (var line in logs) {
          log.e('$binary: $line');
        }

        var lastLine = _stripFromString(logs.last, ': ');
        connectionError = lastLine;
      } else {
        connectionError = err.toString();
      }
    }

    notifyListeners();
  }

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the connection drops/begins
  Timer? _connectionTimer;
  void startConnectionTimer() {
    _connectionTimer?.cancel();
    _connectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await testConnection();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectionTimer?.cancel();
  }
}

String _stripFromString(String input, String whatToStrip) {
  int startIndex = 0, endIndex = input.length;

  for (int i = 0; i <= input.length; i++) {
    if (i == input.length) {
      return '';
    }
    if (!whatToStrip.contains(input[i])) {
      startIndex = i;
      break;
    }
  }

  for (int i = input.length - 1; i >= 0; i--) {
    if (!whatToStrip.contains(input[i])) {
      endIndex = i;
      break;
    }
  }

  return input.substring(startIndex, endIndex + 1);
}
