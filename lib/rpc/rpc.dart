// class for connecting to a basic bitcoin core rpc interface
// also includes functions for checking whether the connection
// is live, and if not, what error message the node returned
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidesail/app.dart';
import 'package:sidesail/logger.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/providers/proc_provider.dart';

// when you implement this class, you should extend a ChangeNotifier, to get
// a proper implementation of notifyListeners(), e.g:
// YourClass extends ChangeNotifier implements RPCConnection
abstract class RPCConnection extends ChangeNotifier {
  final _log = Logger(level: Level.debug);

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
      _log.t('could not ping: ${error.toString()}!');
      connectionError = error.toString();
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

    final tempDir = await Directory.systemTemp.createTemp(binary);
    final tempLogFile = await File('${tempDir.path}/$binary.debug.log').create(recursive: true);

    // TODO: update this when adding other nodes with different args
    final args = [
      '-debuglogfile=${tempLogFile.path}',
      '-regtest',
    ];

    if (!context.mounted) {
      initializingBinary = false;
      notifyListeners();
      return;
    }

    // cancel any timers, to not override error message
    // resulting from the process not being able to start
    _connectionTimer?.cancel();

    log.d('init binaries: starting $binary $args');

    try {
      final pid = await processes.start(context, binary, args);
      log.d('init binaries: started $binary with PID $pid');
    } catch (err) {
      log.e('init binaries: could not start $binary daemon $err');
      initializingBinary = false;
      connectionError = 'could not start $binary daemon: $err';
      connected = false;
      notifyListeners();
      return;
    }

    // Add timeout?
    log.i('init binaries: waiting for $binary connection');
    await waitForBoolToBeTrue(() async {
      log.d('waiting for successful RPC-connection');
      final (connected, _) = await testConnection();
      return connected;
    });

    initializingBinary = false;
    startConnectionTimer();
    notifyListeners();
    log.i('init binaries: $binary connected');
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
