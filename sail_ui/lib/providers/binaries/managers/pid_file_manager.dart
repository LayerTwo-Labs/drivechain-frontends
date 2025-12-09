import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';

/// Manages PID files for binary processes to detect orphaned processes after a crash or hot restart.
///
/// PID files are stored in a central directory (e.g., ~/Library/Application Support/bitwindow/pids/)
/// with naming convention: {binary.binaryName}.pid
class PidFileManager {
  Logger get log => GetIt.I.get<Logger>();

  final Directory pidDir;

  PidFileManager({
    required this.pidDir,
  }) {
    // Ensure directory exists synchronously on creation
    if (!pidDir.existsSync()) {
      pidDir.createSync(recursive: true);
      log.d('Created PID directory: ${pidDir.path}');
    }
  }

  /// Get the PID file path for a binary
  File _pidFile(Binary binary) {
    return File(path.join(pidDir.path, '${binary.binaryName}.pid'));
  }

  /// Write PID to file for a binary
  Future<void> writePidFile(Binary binary, int pid) async {
    try {
      final file = _pidFile(binary);

      // Ensure directory exists
      if (!await pidDir.exists()) {
        await pidDir.create(recursive: true);
      }

      await file.writeAsString(pid.toString());
      log.d('Wrote PID file for ${binary.name}: ${file.path} (PID: $pid)');
    } catch (e) {
      log.e('Failed to write PID file for ${binary.name}: $e');
      // Non-fatal - process is still running, just won't be detected as orphaned on restart
    }
  }

  /// Read PID from file (returns null if file doesn't exist or is invalid)
  Future<int?> readPidFile(Binary binary) async {
    try {
      final file = _pidFile(binary);

      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      final pid = int.tryParse(content.trim());

      if (pid == null) {
        log.w('Invalid PID file content for ${binary.name}: "$content"');
        await deletePidFile(binary);
        return null;
      }

      return pid;
    } catch (e) {
      log.e('Failed to read PID file for ${binary.name}: $e');
      return null;
    }
  }

  /// Delete PID file for a binary
  Future<void> deletePidFile(Binary binary) async {
    try {
      final file = _pidFile(binary);

      if (await file.exists()) {
        await file.delete();
        log.d('Deleted PID file for ${binary.name}: ${file.path}');
      }
    } catch (e) {
      log.e('Failed to delete PID file for ${binary.name}: $e');
      // Non-fatal - file might already be deleted or inaccessible
    }
  }

  /// Check if a PID is still alive (cross-platform)
  Future<bool> isPidAlive(int pid) async {
    try {
      if (Platform.isWindows) {
        // On Windows, use tasklist to check if process exists
        final result = await Process.run('tasklist', ['/FI', 'PID eq $pid', '/NH']);
        return result.stdout.toString().contains('$pid');
      }

      // On Unix-like systems, use ps to check if process exists
      final result = await Process.run('ps', ['-p', '$pid']);
      return result.exitCode == 0;
    } catch (e) {
      log.e('Could not check if PID $pid is alive: $e');
      return false;
    }
  }

  /// Get the process name for a PID (platform-specific)
  ///
  /// Returns the executable name (e.g., "bitwindowd", "bip300301-enforcer")
  /// or null if the process doesn't exist or name can't be determined.
  Future<String?> getProcessName(int pid) async {
    try {
      if (Platform.isWindows) {
        // On Windows: tasklist /FI "PID eq PID" /FO CSV /NH
        // Output: "ImageName.exe","PID","SessionName","Session#","MemUsage"
        final result = await Process.run(
          'tasklist',
          ['/FI', 'PID eq $pid', '/FO', 'CSV', '/NH'],
        );

        if (result.exitCode != 0) return null;

        final output = result.stdout.toString().trim();
        if (output.isEmpty || output.contains('No tasks')) return null;

        // Parse CSV: first quoted value is the image name
        final match = RegExp(r'"([^"]+)"').firstMatch(output);
        if (match == null) return null;

        // Remove .exe suffix for comparison
        var name = match.group(1) ?? '';
        if (name.toLowerCase().endsWith('.exe')) {
          name = name.substring(0, name.length - 4);
        }
        return name;
      }

      // On Unix: ps -p PID -o comm=
      // Output: just the command name (e.g., "bitwindowd")
      final result = await Process.run('ps', ['-p', '$pid', '-o', 'comm=']);

      if (result.exitCode != 0) return null;

      final name = result.stdout.toString().trim();
      return name.isEmpty ? null : name;
    } catch (e) {
      log.e('Failed to get process name for PID $pid: $e');
      return null;
    }
  }

  /// Verify that a PID belongs to the expected binary
  ///
  /// This prevents adopting a wrong process when the OS has reused a PID.
  Future<bool> verifyProcessName(int pid, Binary binary) async {
    final processName = await getProcessName(pid);
    if (processName == null) return false;

    // The process name should contain the binary name
    // e.g., processName="bip300301-enforcer" should match binary.binaryName="bip300301-enforcer"
    // Process name may be truncated on some systems, so check both directions
    final binaryName = binary.binaryName.toLowerCase();
    final procName = processName.toLowerCase();

    return procName.contains(binaryName) || binaryName.contains(procName);
  }

  /// Validate a PID: check if it's alive AND belongs to the expected binary
  ///
  /// Returns true only if:
  /// 1. The PID is alive (process exists)
  /// 2. The process name matches the expected binary
  Future<bool> validatePid(int pid, Binary binary) async {
    // First check if alive (fast check)
    final alive = await isPidAlive(pid);
    if (!alive) {
      log.d('PID $pid is not alive');
      return false;
    }

    // Then verify process name (prevents PID reuse issues)
    final nameMatches = await verifyProcessName(pid, binary);
    if (!nameMatches) {
      log.w('PID $pid is alive but process name does not match ${binary.binaryName}');
      return false;
    }

    return true;
  }
}
