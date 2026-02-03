import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/config/binaries.dart';

class UpdateProvider extends ChangeNotifier {
  final Logger log;
  final BinaryType binaryType;
  final String currentVersion;

  static const String versionsUrl = 'https://releases.drivechain.info/versions.json';
  static const String installScriptBaseUrl =
      'https://raw.githubusercontent.com/LayerTwo-Labs/drivechain-frontends/master/install';
  static const Duration _checkInterval = Duration(minutes: 10);

  Timer? _timer;
  bool updateAvailable = false;
  String? latestVersion;
  String? errorMessage;
  bool checking = false;
  bool updating = false;

  UpdateProvider({
    required this.log,
    required this.binaryType,
    required this.currentVersion,
  }) {
    // Only check for updates on Linux (macOS/Windows use auto_updater)
    if (!Platform.isLinux) {
      return;
    }

    // Check immediately on startup
    _checkForUpdates();

    // Then check periodically
    _timer = Timer.periodic(_checkInterval, (_) => _checkForUpdates());
  }

  /// Get the key used in versions.json for this binary type
  String get _appname => switch (binaryType) {
    BinaryType.bitWindow => 'bitwindow',
    BinaryType.thunder => 'thunder',
    BinaryType.zSide => 'zside',
    BinaryType.bitnames => 'bitnames',
    BinaryType.bitassets => 'bitassets',
    BinaryType.truthcoin => 'truthcoin',
    BinaryType.photon => 'photon',
    _ => throw UnsupportedError('Update provider not supported for ${binaryType.name}'),
  };

  /// Get the install script URL for this binary type
  String get _installScriptUrl => '$installScriptBaseUrl/install-$_appname.sh';

  Future<void> _checkForUpdates() async {
    if (checking) return;

    checking = true;
    errorMessage = null;

    try {
      log.d('Checking for updates for $_appname...');

      final response = await http.get(Uri.parse(versionsUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch version info: ${response.statusCode}');
      }

      latestVersion = jsonDecode(response.body)?[_appname]?['linux']?['version'] as String?;
      if (latestVersion == null) {
        // Platform not available, that's ok
        log.d('No version found for $_appname on linux');
        checking = false;
        return;
      }

      final hasUpdate = _compareVersions(currentVersion, latestVersion!);
      if (hasUpdate != updateAvailable) {
        updateAvailable = hasUpdate;
        if (hasUpdate) {
          log.i('Update available: $currentVersion -> $latestVersion');
        }
        notifyListeners();
      }
    } catch (e) {
      log.w('Error checking for updates: $e');
      errorMessage = e.toString();
    } finally {
      checking = false;
    }
  }

  /// Compare two version strings (returns true if remote is newer)
  bool _compareVersions(String current, String remote) {
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final remoteParts = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final remotePart = i < remoteParts.length ? remoteParts[i] : 0;

      if (remotePart > currentPart) {
        return true;
      } else if (remotePart < currentPart) {
        return false;
      }
    }

    return false;
  }

  /// Force a check for updates
  Future<void> checkNow() async {
    await _checkForUpdates();
  }

  /// Dismiss the update notification (until next check finds a new version)
  void dismissUpdate() {
    updateAvailable = false;
    notifyListeners();
  }

  /// Download and run the install script to perform the update
  Future<void> performUpdate() async {
    updating = true;
    errorMessage = null;
    notifyListeners();

    try {
      log.i('Downloading install script from: $_installScriptUrl');

      // Download the install script
      final response = await http.get(Uri.parse(_installScriptUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download install script: ${response.statusCode}');
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final scriptPath = '${tempDir.path}/install-$_appname.sh';
      final scriptFile = File(scriptPath);

      await scriptFile.writeAsString(response.body);

      log.i('Install script downloaded to: $scriptPath');

      // Make executable
      final chmodResult = await Process.run('chmod', ['+x', scriptPath]);
      if (chmodResult.exitCode != 0) {
        throw Exception('Failed to make script executable: ${chmodResult.stderr}');
      }

      log.i('Running install script...');

      // Run the script
      final installResult = await Process.run('bash', [scriptPath]);

      if (installResult.exitCode != 0) {
        throw Exception('Install script failed: ${installResult.stderr}');
      }

      log.i('Update completed successfully. Output: ${installResult.stdout}');

      // Clean up
      await scriptFile.delete();

      // Restart the application
      await _restartApplication();
    } catch (e) {
      log.e('Error performing update: $e');
      errorMessage = e.toString();
      updating = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Restart the application
  Future<void> _restartApplication() async {
    log.i('Restarting application...');

    try {
      // Start a new instance of the application
      // The executable should be in PATH after installation via the script
      await Process.start(_appname, [], mode: ProcessStartMode.detached);

      // Exit current instance
      exit(0);
    } catch (e) {
      log.e('Failed to restart application: $e');
      // If restart fails, just exit and let user manually restart
      exit(0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
