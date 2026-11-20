import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:sidechain_core/config/binaries.dart';

/// The calls into the backend library that holds bitwindowd and drivechaind.
abstract interface class BackendNative {
  /// Starts the backend with a JSON config. Returns null, or the error.
  String? start(String config);

  /// Asks the backend to stop. [status] reports when it is gone.
  void stop();

  /// The JSON status of the backend.
  String status();
}

/// The state that [BackendNative.status] reports.
class BackendStatus {
  final bool running;

  /// The error that ended the backend, or null.
  final String? error;

  const BackendStatus({required this.running, this.error});

  factory BackendStatus.fromJson(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final error = json['error'] as String?;
    return BackendStatus(running: json['running'] as bool, error: error == null || error.isEmpty ? null : error);
  }
}

/// Runs bitwindowd and drivechaind inside the app process. A phone cannot
/// start a child process, so the app links them as one library.
class InProcessBackend extends ChangeNotifier {
  final BackendNative _native;

  /// How often a running backend gets checked for its exit.
  final Duration pollEvery;

  /// How long [stop] waits for the backend to go.
  final Duration stopTimeout;

  InProcessBackend(
    this._native, {
    this.pollEvery = const Duration(seconds: 1),
    this.stopTimeout = const Duration(seconds: 60),
  });

  /// The backend in the library that the app links.
  factory InProcessBackend.open() => InProcessBackend(FfiBackendNative(FfiBackendNative.openLibrary()));

  bool _running = false;
  Timer? _poll;

  /// The error that ended the last backend, or null.
  String? exitError;

  /// Only bitwindowd runs in process, and it runs drivechaind itself.
  bool isRunning(Binary binary) => binary is BitWindow && _running;

  /// Starts bitwindowd with the command line flags [args] and the environment [env].
  Future<void> start(Binary binary, List<String> args, Map<String, String> env) async {
    if (binary is! BitWindow) {
      throw UnsupportedError('${binary.name} does not run in the app process');
    }
    final error = _native.start(jsonEncode({'args': args, 'env': env}));
    if (error != null) {
      throw StateError('could not start ${binary.name}: $error');
    }
    _running = true;
    exitError = null;
    _poll?.cancel();
    _poll = Timer.periodic(pollEvery, (_) => _check());
    notifyListeners();
  }

  /// Stops bitwindowd and drivechaind, and waits until they are gone.
  Future<void> stop(Binary binary) async {
    if (!isRunning(binary)) {
      return;
    }
    _native.stop();
    final deadline = DateTime.now().add(stopTimeout);
    while (_running) {
      if (DateTime.now().isAfter(deadline)) {
        throw StateError('${binary.name} did not stop in ${stopTimeout.inSeconds}s');
      }
      await Future.delayed(pollEvery);
      _check();
    }
    final error = exitError;
    if (error != null) {
      throw StateError('${binary.name} stopped with an error: $error');
    }
  }

  void _check() {
    if (!_running) {
      return;
    }
    final status = BackendStatus.fromJson(_native.status());
    if (status.running) {
      return;
    }
    _running = false;
    exitError = status.error;
    _poll?.cancel();
    _poll = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }
}

typedef _StartNative = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _StopNative = Void Function();
typedef _Stop = void Function();
typedef _StatusNative = Pointer<Utf8> Function();
typedef _FreeNative = Void Function(Pointer<Utf8>);
typedef _Free = void Function(Pointer<Utf8>);

/// [BackendNative] through dart:ffi.
class FfiBackendNative implements BackendNative {
  final _StartNative _start;
  final _Stop _stop;
  final _StatusNative _status;
  final _Free _free;

  FfiBackendNative(DynamicLibrary library)
    : _start = library.lookupFunction<_StartNative, _StartNative>('BitwindowStart'),
      _stop = library.lookupFunction<_StopNative, _Stop>('BitwindowStop'),
      _status = library.lookupFunction<_StatusNative, _StatusNative>('BitwindowStatus'),
      _free = library.lookupFunction<_FreeNative, _Free>('BitwindowFree');

  /// iOS links the library into the app binary. Android loads it from the APK.
  static DynamicLibrary openLibrary() =>
      Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open('libbitwindow_backend.so');

  @override
  String? start(String config) {
    final arg = config.toNativeUtf8();
    try {
      return _take(_start(arg));
    } finally {
      malloc.free(arg);
    }
  }

  @override
  void stop() => _stop();

  @override
  String status() => _take(_status())!;

  String? _take(Pointer<Utf8> result) {
    if (result == nullptr) {
      return null;
    }
    try {
      return result.toDartString();
    } finally {
      _free(result);
    }
  }
}
