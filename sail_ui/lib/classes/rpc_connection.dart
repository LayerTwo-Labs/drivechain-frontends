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
import 'package:sail_ui/sail_ui.dart';

// when you implement this class, you should extend a ChangeNotifier, to get
// a proper implementation of notifyListeners(), e.g:
// YourClass extends ChangeNotifier implements RPCConnection
abstract class RPCConnection extends ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  NodeConnectionSettings conf;
  final Binary binary;
  // if set to true, the process will be restarted when exiting with a non-zero exit code
  final bool restartOnFailure;

  RPCConnection({
    required this.conf,
    required this.binary,
    required this.restartOnFailure,
  });

  /// Args to pass to the binary on startup.
  Future<List<String>> binaryArgs(
    NodeConnectionSettings mainchainConf,
  );

  Map<String, String> environment = const {};

  // attempt to stop the binary gracefully
  Future<void> stopRPC();

  // used to ping the node to check if the connection is live
  // for bitcoin core based binaries, returns the block height
  Future<int> ping();

  // returns a list of error messages from the binary that
  // indicates it is successfully started, but not yet ready to
  // accept connections
  List<String> startupErrors();

  // Override this function if you want to do something when connection changes status.
  void onConnectionStateChanged(bool isConnected) {}

  /// Returns confirmed and unconfirmed balance.
  Future<(double, double)> balance();

  /// Fetches the latest blockchain info.
  Future<BlockchainInfo> getBlockchainInfo();

  bool initializingBinary = false;
  bool stoppingBinary = false;
  bool _testing = false;
  bool _shouldNotify = false;

  bool _completedStartup = false;

  // values for tracking connection state, and error (if any)
  String? connectionError;
  // if set, startupError contains messages from the binary that indicates
  // it is started, but in a bootup-phase and not ready to accept connections
  String? startupError;
  bool connected = false;
  int blockCount = 0;

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
        onConnectionStateChanged(true);
      }
      connected = true;
      connectionError = null;
      startupError = null;
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
      if (connected || (connectionError != newError && startupError != newError)) {
        // we were previously connected, and should notify listeners
        // or we have a new error on our hands that must be shown
        initializingBinary = false;
        _shouldNotify = true;
        onConnectionStateChanged(false);
        // we have a new error on our hands!
        log.e('could not test connection ${binary.connectionString}: ${newError ?? ''}!');
      }

      connected = false;

      // finally set the error variable based on what type of error it is
      if (newError != null && startupErrors().any((error) => newError!.contains(error))) {
        startupError = newError;
      } else {
        connectionError = newError;
      }
    } finally {
      _testing = false;
      if (_shouldNotify) {
        notifyListeners();
      }
      _shouldNotify = false;
    }

    return (connected, connectionError);
  }

  Future<void> initBinary(Future<String?> Function(Binary, List<String>, Future<void> Function(), Map<String, String> environment) bootProcess) async {
    final args = await binaryArgs(conf);

    initializingBinary = true;
    notifyListeners();

    log.i('init binaries: checking connection ${binary.connectionString}');

    await startConnectionTimer();
    if (connected) {
      log.i('init binaries: $binary is already running, not booting');
      initializingBinary = false;
      notifyListeners();
      return;
    }

    // only start retart timer if this process starts the binary!
    startRestartTimer(bootProcess);

    log.i('init binaries: starting ${binary.name}:${binary.binary} ${args.join(" ")}');

    final error = await bootProcess(
      binary,
      args,
      stopRPC,
      environment,
    );
    if (error != null) {
      log.e('init binaries: could not boot ${binary.connectionString}: $error');
      connectionTimer?.cancel();
      connectionError = error;
    } else {
      log.i('init binaries: successfully booted ${binary.connectionString} ');
    }

    initializingBinary = false;
    notifyListeners();
  }

  Timer? restartTimer;
  int _restartCount = 0;
  void startRestartTimer(Future<String?> Function(Binary, List<String>, Future<void> Function(), Map<String, String> environment) bootProcess) {
    restartTimer?.cancel();
    restartTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (restartOnFailure && _completedStartup) {
        if (initializingBinary) {
          // we're still going from the last loop, don't retry multiple times in parallell!
          return;
        }

        if (stoppingBinary) {
          // we're currently stopping manually. Don't retry if the user wants to shut it off
          return;
        }

        if (startupError != null) {
          // we're not connected yet, but in a startup phase! Don't retry then
          return;
        }

        if (_restartCount > 10) {
          // we've restarted too many times without successfully starting. stop trying, rip
          return;
        }

        if (connected) {
          // we're connected! no need to restart then
          return;
        }

        final exit = GetIt.I.get<BinaryProvider>().exited(binary);
        if (exit != null && exit.code != 0) {
          // Only attempt restart if the process has exited with non-zero code
          log.w('Process exited unexpectedly with code ${exit.code}, restarting...');
          _restartCount++;
          await initBinary(bootProcess);
          if (connected) {
            // we managed to restart! reset the restart count
            _restartCount = 0;
          }
        }
      }
    });
  }

  // responsible for pinging the node every x seconds,
  // so we can update the UI immediately when the connection drops/begins
  Timer? connectionTimer;
  Future<void> startConnectionTimer() async {
    // Cancel any existing timer before starting a new one
    connectionTimer?.cancel();

    log.i('checking connection ${binary.connectionString}');

    await testConnection();
    if (connected) {
      log.i('${binary.connectionString} already running');
    } else {
      log.i('${binary.connectionString} could not connect: error=${connectionError ?? ''}');
    }

    log.i('starting connection timer for ${binary.connectionString}');
    connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
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
      await stopRPC();
      connectionTimer?.cancel();
    } catch (e) {
      log.e('could not stop rpc: $e');
      connectionError = 'could not stop nor kill rpc, process might still be running: $e';
      startupError = null;
      rethrow;
    } finally {
      connected = false;
      stoppingBinary = false;
      if (connectionError != null && connectionError!.contains('not found for binary')) {
        connectionTimer?.cancel();
      } else {
        log.i('stopped rpc successfully');
        connectionError = null;
        startupError = null;
      }

      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    connectionTimer?.cancel();
    restartTimer?.cancel();
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
