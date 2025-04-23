import 'dart:ffi';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

typedef HandlerFunc = Int32 Function(Int32);
typedef SetConsoleCtrlHandlerNative = Int32 Function(Pointer<NativeFunction<HandlerFunc>>, Int32);
typedef SetConsoleCtrlHandlerDart = int Function(Pointer<NativeFunction<HandlerFunc>>, int);

/// Windows signal constants
const CTRL_C_EVENT = 0;
const CTRL_BREAK_EVENT = 1;
const CTRL_CLOSE_EVENT = 2;
const CTRL_LOGOFF_EVENT = 5;
const CTRL_SHUTDOWN_EVENT = 6;

late final void Function() onShutdown;
late final Logger _log;

final _handler = Pointer.fromFunction<HandlerFunc>(_signalHandler, 0);

final _kernel32 = DynamicLibrary.open('kernel32.dll');
final _setConsoleCtrlHandler = _kernel32.lookupFunction<SetConsoleCtrlHandlerNative, SetConsoleCtrlHandlerDart>(
  'SetConsoleCtrlHandler',
);

void setupWindowsSignalHandler(void Function() shutdownCallback) {
  if (!Platform.isWindows) return;

  onShutdown = shutdownCallback;
  _log = GetIt.I.get<Logger>();

  final result = _setConsoleCtrlHandler(_handler, 1);
  if (result == 0) {
    _log.e('Failed to register Windows control handler');
  } else {
    _log.i('Windows shutdown handler registered successfully');
  }
}

int _signalHandler(int signal) {
  switch (signal) {
    case CTRL_C_EVENT:
      _log.i('Received CTRL+C signal');
      break;
    case CTRL_CLOSE_EVENT:
      _log.i('Received close signal');
      break;
    case CTRL_LOGOFF_EVENT:
      _log.i('Received logoff signal');
      break;
    case CTRL_SHUTDOWN_EVENT:
      _log.i('Received shutdown signal');
      break;
  }

  onShutdown();
  sleep(Duration(seconds: 4)); // let it flush logs / cleanup
  return 1; // handled
}
