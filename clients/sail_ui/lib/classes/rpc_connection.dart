// class for connecting to a basic bitcoin core rpc interface
// also includes functions for checking whether the connection
// is live, and if not, what error message the node returned
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

// when you implement this class, you should extend a ChangeNotifier, to get
// a proper implementation of notifyListeners(), e.g:
// YourClass extends ChangeNotifier implements RPCConnection
abstract class RPCConnection extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  RPCConnection({
    required this.conf,
  });

  /// Args to pass to the binary on startup.
  List<String> binaryArgs(
    NodeConnectionSettings mainchainConf,
  );

  // attempt to stop the binary gracefully
  Future<void> stop();

  // used to ping the node to check if the connection is live
  // for bitcoin core based binaries, returns the block height
  Future<int> ping();

  bool initializingBinary = false;
  bool _isTesting = false;

  Future<(bool, String?)> testConnection() async {
    try {
      if (_isTesting) {
        return (connected, connectionError);
      }
      _isTesting = true;

      final newBlockCount = await ping();
      connectionError = null;
      connected = true;

      if (blockCount != newBlockCount) {
        blockCount = newBlockCount;
        notifyListeners();
      } else {
        // nothing has changed, don't notify any listeners!
        return (connected, connectionError);
      }
    } catch (error) {
      // Only update the error message if we're finished with binary init
      if (!initializingBinary) {
        String? newError = error.toString();

        if (newError.contains('Connection refused')) {
          if (connectionError != null) {
            // an error is already set, and we don't want to override it with
            // a generic non-informative message!
            newError = connectionError!;
          } else {
            // don't show a generic Connection refused as the first error
            newError = null;
          }
        } else if (error is SocketException) {
          newError = error.osError?.message ?? 'could not connect at ${conf.host}:${conf.port}';
        } else if (error is HttpException) {
          // gotta parse out the error...

          // Looks like this: SocketException: Connection refused (OS Error: Connection refused, errno = 61), address = localhost, port = 55248

          newError = error.message;
          RegExp regExp = RegExp(r'\(([^)]+)\)');
          final match = regExp.firstMatch(error.message);
          if (match != null) {
            newError = match.group(1)!;
          }
        }

        if (connectionError != newError) {
          // we have a new error on our hands!
          log.e('could not test connection: ${error.toString()}!');
          notifyListeners();
        }

        connectionError = newError;
      }
      connected = false;
    } finally {
      _isTesting = false;
    }

    return (connected, connectionError);
  }

  // values for tracking connection state, and error (if any)
  NodeConnectionSettings conf;
  String? connectionError;
  bool connected = false;
  int blockCount = 0;

  Future<void> initBinary(
    BuildContext context,
    String binary, {
    List<String>? arg,
  }) async {
    final args = binaryArgs(conf);
    args.addAll(arg ?? []);

    final processes = GetIt.I.get<ProcessProvider>();

    initializingBinary = true;
    notifyListeners();

    log.d('init binaries: checking $binary connection ${conf.host}:${conf.port}');

    _startConnectionTimer();
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

    log.d('init binaries: starting $binary ${args.join(" ")}');

    int pid;
    try {
      pid = await processes.start(
        context,
        binary,
        args,
        stop,
      );
      log.d('init binaries: started $binary with PID $pid');
    } catch (err) {
      log.e('init binaries: could not start $binary daemon', error: err);
      initializingBinary = false;
      connectionError = 'could not start $binary daemon: $err';
      connected = false;
      notifyListeners();
      return;
    }

    log.i('init binaries: waiting for $binary connection');

    // zcash can take a long time. initial sync as well
    const timeout = Duration(seconds: 5 * 60);
    try {
      await Future.any([
        // Happy case: able to connect. we start a poller at the
        // beginning of this function that sets the connected variable
        // we return here
        waitForBoolToBeTrue(() async {
          return connected;
        }),

        // Not so happy case: process exited
        // Throw an error, which causes the error message to be shown
        // in the daemon status chip
        waitForBoolToBeTrue(() async {
          final res = processes.exited(pid);
          return res != null;
        }).then(
          (_) => {
            throw processes.exited(pid)?.message ?? "'$binary' exited",
          },
        ),

        Future.delayed(timeout).then(
          (_) => throw "'$binary' connection timed out after ${timeout.inSeconds}s",
        ),
        // Timeout case!
      ]);

      log.i('init binaries: $binary connected');
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

    initializingBinary = false;

    notifyListeners();
  }

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the connection drops/begins
  Timer? _connectionTimer;
  void _startConnectionTimer() {
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
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

Future<void> waitForBoolToBeTrue(
  Future<bool> Function() boolGetter, {
  Duration pollInterval = const Duration(milliseconds: 100),
}) async {
  bool result = await boolGetter();
  if (!result) {
    await Future.delayed(pollInterval);
    await waitForBoolToBeTrue(boolGetter, pollInterval: pollInterval);
  }
}

class BlockchainInfo {
  // indicates whether the chain is currently downloading the chain
  // for the first time
  final bool initialBlockDownload;
  final int blockHeight;

  BlockchainInfo({
    required this.initialBlockDownload,
    required this.blockHeight,
  });

  factory BlockchainInfo.fromMap(Map<String, dynamic> map) {
    return BlockchainInfo(
      initialBlockDownload: map['initialblockdownload'] ?? '',
      blockHeight: map['blocks'] ?? 0,
    );
  }

  static BlockchainInfo fromJson(String json) => BlockchainInfo.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'initialblockdownload': initialBlockDownload,
      };
}
