// class for connecting to a basic bitcoin core rpc interface
// also includes functions for checking whether the connection
// is live, and if not, what error message the node returned
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectrpc/connect.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';

// when you implement this class, you should extend a ChangeNotifier, to get
// a proper implementation of notifyListeners(), e.g:
// YourClass extends ChangeNotifier implements RPCConnection
abstract class RPCConnection extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();
  final processes = GetIt.I.get<ProcessProvider>();

  NodeConnectionSettings conf;
  final Binary binary;
  final String logPath;
  // if set to true, the process will be restarted when exiting with a non-zero exit code
  final bool restartOnFailure;

  RPCConnection({
    required this.conf,
    required this.binary,
    required this.logPath,
    required this.restartOnFailure,
  });

  /// Args to pass to the binary on startup.
  Future<List<String>> binaryArgs(
    NodeConnectionSettings mainchainConf,
  );

  // attempt to stop the binary gracefully
  Future<void> stopRPC();

  // used to ping the node to check if the connection is live
  // for bitcoin core based binaries, returns the block height
  Future<int> ping();

  /// Returns confirmed and unconfirmed balance.
  Future<(double, double)> balance();

  /// Fetches the latest blockchain info.
  Future<BlockchainInfo> getBlockchainInfo();

  bool initializingBinary = false;
  bool stoppingBinary = false;
  bool _testing = false;
  bool _shouldNotify = false;

  bool _completedStartup = false;

  Future<(bool, String?)> testConnection() async {
    try {
      if (_testing) {
        return (connected, connectionError);
      }
      _testing = true;
      _shouldNotify = false;

      final newBlockCount = await ping();
      if (!connected || connectionError != null) {
        // We were previously disconnected, or had an error. Wipe that,
        // set the correct new state, and notify listeners
        _shouldNotify = true;
      }
      connected = true;
      connectionError = null;
      _completedStartup = true;
      _restartCount = 0;

      if (blockCount != newBlockCount) {
        // we got a new block count! set it and notify listeners
        blockCount = newBlockCount;
        _shouldNotify = true;
      }
    } catch (error) {
      String? newError = error.toString();

      if (error is ConnectException) {
        // if it's a grpc error, we're talking to a binary that
        // has a grpc server. That is initialized whenever it
        // responds, so we know it's no longer initializing
        newError = extractConnectException(error);
      }
      // If it's not a grpc error however, we're probably talking
      // to a bitcoin core based binary. That will return a bunch of
      // uninteresting errors during initialization, such as "indexing blocks...",
      // As long as it does that, we want to keep showing the orange spinner!

      else if (error is SocketException) {
        newError = error.osError?.message ?? 'could not connect ${binary.connectionString}';
      } else if (error is HttpException) {
        // Error looks like this, lets parse the interesting bits:
        // SocketException: Connection refused (OS Error: Connection refused, errno = 61), address = localhost, port = 55248
        newError = error.message;
        RegExp regExp = RegExp(r'\(([^)]+)\)');
        final match = regExp.firstMatch(error.message);
        if (match != null) {
          newError = match.group(1)!;
        }
      }

      if (newError.contains('Connection refused') ||
          newError.contains('SocketException') ||
          newError.contains('computer refused the network') ||
          newError.contains('Unknown Error') ||
          newError.contains('could not connect at') ||
          newError.contains('forcefully terminated') ||
          stoppingBinary) {
        // don't show a generic Connection refused as the first error or when
        // we're in the middle of stopping
        newError = connectionError;
      }

      // Notify if we were connected or have a new error
      if (connected || connectionError != newError) {
        // we were previously connected, and should notify listeners
        // or we have a new error on our hands that must be shown
        initializingBinary = false;
        _shouldNotify = true;
        // we have a new error on our hands!
        log.e('could not test connection ${binary.connectionString}: ${newError ?? ''}!');
      }
      connected = false;
      connectionError = newError;
    } finally {
      _testing = false;
      if (_shouldNotify) {
        // Only notify listeners if something actually changed
        notifyListeners();
      }
      _shouldNotify = false;
    }

    return (connected, connectionError);
  }

  // values for tracking connection state, and error (if any)
  String? connectionError;
  bool connected = false;
  int blockCount = 0;

  Future<void> initBinary({
    List<String>? arg,
    bool withBootConnectionRetry = false,
  }) async {
    final args = await binaryArgs(conf);
    args.addAll(arg ?? []);

    final processes = GetIt.I.get<ProcessProvider>();

    initializingBinary = true;
    notifyListeners();

    log.i('init binaries: checking connection ${binary.connectionString}');

    try {
      await startConnectionTimer(withBootConnectionRetry: withBootConnectionRetry);
      // If we managed to connect to an already running daemon, we're finished here!
      if (connected) {
        log.i('init binaries: $binary is already running, not doing anything');
        initializingBinary = false;
        notifyListeners();
        return;
      }

      log.i('init binaries: starting ${binary.name}:${binary.binary} ${args.join(" ")}');

      int pid;
      try {
        pid = await processes.start(
          binary.binary,
          args,
          stopRPC,
        );
        log.i('init binaries: started ${binary.connectionString} with PID $pid');
      } catch (err) {
        log.e('init binaries: could not start ${binary.connectionString}', error: err);
        _connectionTimer?.cancel();
        initializingBinary = false;
        connectionError = 'could not start ${binary.connectionString}: $err';
        connected = false;
        notifyListeners();
        return;
      }

      log.i('init binaries: waiting for ${binary.connectionString} connection');

      var timeout = const Duration(seconds: 60);
      if (binary.binary == 'zsided') {
        // zcash can take a long time. initial sync as well
        timeout = const Duration(seconds: 5 * 60);
      }
      try {
        await Future.any([
          // Happy case: able to connect. we start a poller at the
          // beginning of this function that sets the connected variable
          // we return here
          waitForBoolToBeTrue(() async {
            return connected;
          }),

          // A sad case: Binary is running, but not working for some reason
          waitForBoolToBeTrue(() async {
            return connectionError != null && !initializingBinary;
          }),

          // Not so happy case: process exited
          // Throw an error, which causes the error message to be shown
          // in the daemon status chip
          waitForBoolToBeTrue(() async {
            final res = processes.exited(binary);
            if (res != null) {
              log.i('process exited with message: ${res.message}');
              initializingBinary = false;
              connectionError = res.message;
            }
            return res != null;
          }),

          Future.delayed(timeout).then(
            (_) => throw "'$binary' connection timed out after ${timeout.inSeconds}s",
          ),
          // Timeout case!
        ]);

        _startRestartTimer();

        log.i('init binaries: $binary connected');
      } catch (err) {
        log.e("init binaries: couldn't connect to $binary", error: err);

        // We've quit! Assuming there's error logs, somewhere.
        if (!processes.running(binary) && connectionError == null) {
          final logs = await processes.stderr(binary).toList();
          log.e('$binary exited before we could connect, dumping logs');
          for (var line in logs) {
            log.e('$binary: $line');
          }

          var lastLine = _stripFromString(logs.last, ': ');
          connectionError = lastLine;
        } else {
          connectionError ??= err.toString();
        }
      }
    } finally {
      initializingBinary = false;
      notifyListeners();
    }
  }

  Timer? _restartTimer;
  int _restartCount = 0;
  void _startRestartTimer() {
    _restartTimer?.cancel();
    _restartTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (restartOnFailure && _completedStartup) {
        if (initializingBinary) {
          // we're still going from the last loop, don't retry multiple times in parallell!
          return;
        }
        if (stoppingBinary) {
          // we're currently stopping manuelly. Be defensive and don't retry then
          return;
        }

        if (_restartCount > 5) {
          // we've restarted too many times without successfully starting. stop trying, rip
          return;
        }

        final exit = processes.exited(binary);
        if (exit != null && exit.code != 0) {
          // Only attempt restart if the process has exited with non-zero code
          log.w('Process exited unexpectedly with code ${exit.code}, restarting...');
          _restartCount++;
          await initBinary();
        }
      }
    });
  }

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the connection drops/begins
  Timer? _connectionTimer;
  Future<void> startConnectionTimer({bool withBootConnectionRetry = false}) async {
    // Cancel any existing timer before starting a new one
    _connectionTimer?.cancel();

    log.i('checking connection ${binary.connectionString}');

    // the enforcer is kinda brittle when testing connection on launch
    // we want to give it a few tries before we give up and try to start it ourselves
    if (withBootConnectionRetry) {
      // Try up to 5 times with a small delay between attempts
      for (int i = 0; i < 5; i++) {
        await testConnection();
        if (connected) {
          log.i('${binary.connectionString} connected on attempt ${i + 1}');
          break;
        }
        log.i('${binary.connectionString} connection attempt ${i + 1} failed, retrying...');
        await Future.delayed(const Duration(seconds: 1));
      }
    } else {
      await testConnection();
    }

    if (connected) {
      log.i('${binary.connectionString} already running');
    } else {
      log.i('${binary.connectionString} could not connect: error=${connectionError ?? ''}');
    }

    log.i('starting connection timer for ${binary.connectionString}');
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await testConnection();
    });
  }

  // cleanArgs makes sure to NOT add any cli-args that are already set in the conf file
  // any duplicates are removed
  List<String> cleanArgs(NodeConnectionSettings settings, List<String> extraArgs) {
    final baseArgs = bitcoinCoreBinaryArgs(settings);
    log.d('Deduplicating args - base args: $baseArgs');

    // Filter out any extra args that exist in base args and come from config
    final filteredExtraArgs = extraArgs.where((arg) {
      final paramName = arg.split('=')[0].replaceAll(RegExp(r'^-+'), '');
      return !settings.isFromConfigFile(paramName);
    }).toList();

    log.d('Extra args after filtering config duplicates: $filteredExtraArgs');

    // Create a map to store args by their parameter name (without the leading dash)
    final argMap = <String, String>{};

    // Process all args and keep only the last occurrence of each parameter
    for (final arg in [...baseArgs, ...filteredExtraArgs]) {
      String paramName;
      if (arg.contains('=')) {
        paramName = arg.split('=')[0].replaceAll(RegExp(r'^-+'), '');
      } else {
        paramName = arg.replaceAll(RegExp(r'^-+'), '');
      }
      argMap[paramName] = arg;
    }

    final args = argMap.values.toList();
    log.d('Args after deduplication: $args');

    return args;
  }

  Future<void> stop() async {
    try {
      log.i('stopping rpc');
      stoppingBinary = true;
      notifyListeners();
      // Try graceful shutdown first
      try {
        await stopRPC();
        _connectionTimer?.cancel();
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 250));
        final processes = GetIt.I.get<ProcessProvider>();
        if (processes.exited(binary) != null) {
          // Process exited, don't bother killing it
          _connectionTimer?.cancel();
          return;
        }

        log.w('Killing process, graceful shutdown failed: $e');
        await processes.kill(binary);
        _connectionTimer?.cancel();
      }
    } catch (e) {
      log.e('could not stop rpc: $e');
      connectionError = 'could not stop nor kill rpc, process might still be running: $e';
    } finally {
      connected = false;
      stoppingBinary = false;
      if (connectionError != null && connectionError!.contains('not found for binary')) {
        _connectionTimer?.cancel();
      } else {
        log.i('stopped rpc successfully');
        connectionError = null;
      }

      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _connectionTimer?.cancel();
    _restartTimer?.cancel();
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
  final String chain;
  final int blocks;
  final int headers;
  final String bestBlockHash;
  final double difficulty;
  final int time;
  final int medianTime;
  final double verificationProgress;
  final bool initialBlockDownload;
  final String chainWork;
  final int sizeOnDisk;
  final bool pruned;
  final List<String> warnings;

  BlockchainInfo({
    required this.chain,
    required this.blocks,
    required this.headers,
    required this.bestBlockHash,
    required this.difficulty,
    required this.time,
    required this.medianTime,
    required this.verificationProgress,
    required this.initialBlockDownload,
    required this.chainWork,
    required this.sizeOnDisk,
    required this.pruned,
    required this.warnings,
  });

  factory BlockchainInfo.fromMap(Map<String, dynamic> map) {
    return BlockchainInfo(
      chain: map['chain'] ?? '',
      blocks: map['blocks'] ?? 0,
      headers: map['headers'] ?? 0,
      bestBlockHash: map['bestblockhash'] ?? '',
      difficulty: (map['difficulty'] ?? 0.0).toDouble(),
      time: map['time'] ?? 0,
      medianTime: map['mediantime'] ?? 0,
      verificationProgress: (map['verificationprogress'] ?? 0.0).toDouble(),
      initialBlockDownload: map['initialblockdownload'] ?? false,
      chainWork: map['chainwork'] ?? '',
      sizeOnDisk: map['size_on_disk'] ?? 0,
      pruned: map['pruned'] ?? false,
      warnings: List<String>.from(map['warnings'] ?? []),
    );
  }

  static BlockchainInfo fromJson(String json) => BlockchainInfo.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'chain': chain,
        'blocks': blocks,
        'headers': headers,
        'bestblockhash': bestBlockHash,
        'difficulty': difficulty,
        'time': time,
        'mediantime': medianTime,
        'verificationprogress': verificationProgress,
        'initialblockdownload': initialBlockDownload,
        'chainwork': chainWork,
        'size_on_disk': sizeOnDisk,
        'pruned': pruned,
        'warnings': warnings,
      };

  static BlockchainInfo empty() => BlockchainInfo(
        chain: '',
        blocks: 0,
        headers: 0,
        bestBlockHash: '',
        difficulty: 0,
        time: 0,
        medianTime: 0,
        verificationProgress: 0,
        initialBlockDownload: true,
        chainWork: '',
        sizeOnDisk: 0,
        pruned: false,
        warnings: [],
      );
}

String extractConnectException(
  Object error,
) {
  final messageIfUnknown = error.toString();

  if (error is ConnectException) {
    if (error.message.isEmpty) {
      return messageIfUnknown;
    }
    return error.message;
  } else if (error is String) {
    return error.toString();
  } else {
    return messageIfUnknown;
  }
}
