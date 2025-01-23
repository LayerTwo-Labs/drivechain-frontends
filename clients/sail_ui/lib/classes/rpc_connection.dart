// class for connecting to a basic bitcoin core rpc interface
// also includes functions for checking whether the connection
// is live, and if not, what error message the node returned
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/sail_ui.dart';

// when you implement this class, you should extend a ChangeNotifier, to get
// a proper implementation of notifyListeners(), e.g:
// YourClass extends ChangeNotifier implements RPCConnection
abstract class RPCConnection extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  NodeConnectionSettings conf;
  final Binary binary;
  final String logPath;

  RPCConnection({
    required this.conf,
    required this.binary,
    required this.logPath,
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

  bool initializingBinary = false;
  bool stoppingBinary = false;
  bool _testing = false;

  Future<(bool, String?)> testConnection() async {
    try {
      if (_testing) {
        return (connected, connectionError);
      }
      _testing = true;
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
      String? newError = error.toString();

      if (error is GrpcError) {
        // if it's a grpc error, we're talking to a binary that
        // has a grpc server. That is initialized whenever it
        // responds, so we know it's no longer initializing
        newError = extractGRPCError(error);
      } else if (!initializingBinary) {
        // If it's not a grpc error however, we're probably talking
        // to a bitcoin core based binary. That will return a bunch of
        // uninteresting errors during initialization, such as "indexing blocks...",
        // As long as it does that, we want to keep showing the orange spinner!

        if (error is SocketException) {
          newError = error.osError?.message ?? 'could not connect at ${conf.host}:${conf.port}';
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
      }

      if (newError.contains('Connection refused')) {
        if (connectionError != null) {
          // an error is already set, and we don't want to override it with
          // a generic non-informative message!
          newError = connectionError!;
        } else {
          // don't show a generic Connection refused as the first error
          newError = null;
        }
      }

      connected = false;
      if (connectionError != newError) {
        // we have a new error on our hands!
        log.e('could not test connection: ${newError!}!');
        connectionError = newError;
        initializingBinary = false;
        notifyListeners();
      }
    } finally {
      _testing = false;
    }

    return (connected, connectionError);
  }

  // values for tracking connection state, and error (if any)
  String? connectionError;
  bool connected = false;
  int blockCount = 0;

  Future<void> initBinary(
    BuildContext context, {
    List<String>? arg,
  }) async {
    final args = await binaryArgs(conf);
    args.addAll(arg ?? []);

    final processes = GetIt.I.get<ProcessProvider>();

    initializingBinary = true;
    notifyListeners();

    log.i('init binaries: checking $binary connection ${conf.host}:${conf.port}');

    await startConnectionTimer();
    // If we managed to connect to an already running daemon, we're finished here!
    if (connected) {
      log.i('init binaries: $binary is already running, not doing anything');
      initializingBinary = false;
      notifyListeners();
      return;
    }

    if (!context.mounted) {
      initializingBinary = false;
      notifyListeners();
      return;
    }

    log.i('init binaries: starting $binary ${args.join(" ")}');

    int pid;
    try {
      pid = await processes.start(
        context,
        binary.binary,
        args,
        stopRPC,
      );
      log.i('init binaries: started $binary with PID $pid');
    } catch (err) {
      log.e('init binaries: could not start $binary daemon', error: err);
      initializingBinary = false;
      connectionError = 'could not start $binary daemon: $err';
      connected = false;
      notifyListeners();
      return;
    }

    log.i('init binaries: waiting for $binary connection');

    var timeout = Duration(seconds: 60);
    if (binary.binary == 'zsided') {
      // zcash can take a long time. initial sync as well
      timeout = Duration(seconds: 5 * 60);
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
          final res = processes.exited(pid);
          return res != null;
        }).then(
          (_) {
            throw processes.exited(pid)?.message ?? "'$binary' exited";
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
  Future<void> startConnectionTimer() async {
    // Cancel any existing timer before starting a new one
    _connectionTimer?.cancel();

    await testConnection();
    log.i('starting connection timer for ${conf.host}:${conf.port}');
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
        await stopRPC().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            log.w('Graceful shutdown timed out after 2 seconds');
            throw TimeoutException('Graceful shutdown timed out');
          },
        );
      } catch (e) {
        log.w('Graceful shutdown failed: $e');
      }

      try {
        log.w('Killing process');
        final processes = GetIt.I.get<ProcessProvider>();
        await processes.kill(binary);
      } catch (e) {
        log.w('Killing process failed: $e');
      }

      _connectionTimer?.cancel();
    } catch (e) {
      log.e('could not stop rpc: $e');
    } finally {
      log.i('stopping rpc successfully');
      connected = false;
      connectionError = null;
      stoppingBinary = false;
      notifyListeners();
    }
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
}

String extractGRPCError(
  Object error,
) {
  const messageIfUnknown = "We couldn't figure out exactly what went wrong. Reach out to the devs.";

  if (error is GrpcError) {
    return error.message ?? messageIfUnknown;
  } else if (error is String) {
    return error.toString();
  } else {
    return messageIfUnknown;
  }
}
