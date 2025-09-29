import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/gen/version.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

enum UpdateStatus {
  idle,
  checking,
  updateAvailable,
  upToDate,
  downloading,
  installing,
  error,
}

class LinuxUpdater {
  final Logger log;
  static const String githubReleasesUrl = 'https://api.github.com/repos/LayerTwo-Labs/drivechain-frontends/releases/latest';
  static const String installScriptUrl = 'https://raw.githubusercontent.com/LayerTwo-Labs/drivechain-frontends/refs/heads/master/install-bitwindow.sh';

  UpdateStatus _status = UpdateStatus.idle;
  String? _latestVersion;
  String? _errorMessage;

  UpdateStatus get status => _status;
  String? get latestVersion => _latestVersion;
  String? get errorMessage => _errorMessage;

  LinuxUpdater({required this.log});

  /// Check if there's a newer version available
  Future<bool> checkForUpdates() async {
    _status = UpdateStatus.checking;
    _errorMessage = null;
    _latestVersion = null;

    try {
      log.i('Checking for updates from GitHub...');

      final response = await http.get(Uri.parse(githubReleasesUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch release info: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String?;

      if (tagName == null) {
        throw Exception('No tag_name found in release data');
      }

      // Remove 'v' prefix if present for comparison
      _latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      log.i('Current version: ${AppVersion.version}, Latest version: $_latestVersion');

      final hasUpdate = _compareVersions(AppVersion.version, _latestVersion!);

      _status = hasUpdate ? UpdateStatus.updateAvailable : UpdateStatus.upToDate;

      return hasUpdate;
    } catch (e) {
      log.e('Error checking for updates: $e');
      _errorMessage = e.toString();
      _status = UpdateStatus.error;
      return false;
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

  /// Download and run the install script
  Future<void> performUpdate() async {
    _status = UpdateStatus.downloading;
    _errorMessage = null;

    try {
      log.i('Downloading install script from: $installScriptUrl');

      // Download the install script
      final response = await http.get(Uri.parse(installScriptUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download install script: ${response.statusCode}');
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final scriptPath = '${tempDir.path}/install-bitwindow.sh';
      final scriptFile = File(scriptPath);

      await scriptFile.writeAsString(response.body);

      log.i('Install script downloaded to: $scriptPath');

      // Make executable
      final chmodResult = await Process.run('chmod', ['+x', scriptPath]);
      if (chmodResult.exitCode != 0) {
        throw Exception('Failed to make script executable: ${chmodResult.stderr}');
      }

      _status = UpdateStatus.installing;
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
      _errorMessage = e.toString();
      _status = UpdateStatus.error;
      rethrow;
    }
  }

  /// Restart the application
  Future<void> _restartApplication() async {
    log.i('Restarting application...');

    try {
      // Start a new instance of the application
      // The executable should be in PATH after installation via the script
      Process.start('bitwindow', [], mode: ProcessStartMode.detached);

      // Exit current instance
      exit(0);
    } catch (e) {
      log.e('Failed to restart application: $e');
      // If restart fails, just exit and let user manually restart
      exit(0);
    }
  }

  void reset() {
    _status = UpdateStatus.idle;
    _errorMessage = null;
    _latestVersion = null;
  }
}