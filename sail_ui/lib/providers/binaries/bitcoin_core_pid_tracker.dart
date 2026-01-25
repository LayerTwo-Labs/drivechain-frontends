import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

/// Tracks Bitcoin Core's PID by monitoring the bitcoin.pid file in its datadir,
/// and provides methods to start and stop watching the file.
/// The PID file location is network-aware:
/// - mainnet: {datadir}/bitcoin.pid
/// - testnet: {datadir}/testnet3/bitcoin.pid
/// - signet: {datadir}/signet/bitcoin.pid
/// - regtest: {datadir}/regtest/bitcoin.pid
/// The running network is fetched directly from the conf provider,
/// so from {bitwindow-}bitcoin.conf
class BitcoinCorePidTracker {
  final Logger log = GetIt.I.get<Logger>();

  Timer? _watcher;
  int? _currentPid;

  /// Get the currently tracked PID (may be null if not running or not yet discovered)
  int? get currentPid => _currentPid;

  /// Start watching the bitcoin.pid file
  void startWatching() {
    if (_watcher != null) {
      log.w('BitcoinCorePidTracker already watching');
      return;
    }

    log.d('Starting Bitcoin Core PID file watcher');
    _watcher = Timer.periodic(const Duration(seconds: 10), (_) => _checkPidFile());

    // Do an immediate check
    _checkPidFile();
  }

  /// Stop watching the bitcoin.pid file
  void stopWatching() {
    _watcher?.cancel();
    _watcher = null;
    _currentPid = null;
    log.d('Stopped Bitcoin Core PID file watcher');
  }

  /// Check the bitcoin.pid file and update our tracked PID
  Future<void> _checkPidFile() async {
    try {
      // Build the path to bitcoin.pid, located in the network-aware datadir
      final pidFile = File(path.join(BitcoinCore().datadirNetwork(), 'bitcoind.pid'));

      if (await pidFile.exists()) {
        final pidString = await pidFile.readAsString();
        final pid = int.tryParse(pidString.trim());

        if (pid != null && pid != _currentPid) {
          log.i('Bitcoin Core PID updated from bitcoin.pid (${pidFile.path}): $pid');
          _currentPid = pid;
        }
      } else {
        // PID file doesnt or no longer, clear our cached PID
        if (_currentPid != null) {
          log.d('bitcoin.pid file no longer exists at ${pidFile.path}, clearing cached PID');
          _currentPid = null;
        }
      }
    } catch (e) {
      log.e('Error checking Bitcoin Core PID file: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    stopWatching();
  }
}
