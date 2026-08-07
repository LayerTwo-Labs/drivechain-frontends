import 'dart:io';

import 'package:flutter/services.dart';

/// Hands a spawned daemon to the Windows job object the runner owns, so it dies
/// with the app however the app dies. The app is deliberately not a job member.
abstract final class DaemonJob {
  static const _channel = MethodChannel('bitwindow/daemon_job');

  /// False when the platform has no job (everything but Windows) or the runner
  /// does not implement the channel, which must never block a daemon.
  static Future<bool> bind(int pid) async {
    if (!Platform.isWindows) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('bind', {'pid': pid}) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
