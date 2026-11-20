import 'dart:async';
import 'dart:io';

/// The daemons on the boot path. Each one prints its version and exits.
const bootDaemons = {'bitwindowd', 'drivechaind'};

/// Runs each new boot daemon one time with `--version` as soon as it is
/// staged, so the first-exec check of macOS starts before the real start.
class DaemonWarmUp {
  DaemonWarmUp({bool? enabled}) : _enabled = enabled ?? Platform.isMacOS;

  final bool _enabled;
  final _runs = <Future<void>>[];

  void onStaged(String canonical, File file) {
    if (!_enabled || !bootDaemons.contains(canonical)) {
      return;
    }
    _runs.add(_run(file)..ignore());
  }

  /// Completes when each warm-up exited. Throws the first failure.
  Future<void> done() => Future.wait(_runs);

  static Future<void> _run(File file) async {
    const args = ['--version'];
    final result = await Process.run(file.path, args);
    if (result.exitCode != 0) {
      throw ProcessException(file.path, args, '${result.stderr}', result.exitCode);
    }
  }
}
