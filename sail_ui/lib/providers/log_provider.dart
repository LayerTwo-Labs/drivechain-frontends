import 'package:flutter/foundation.dart';
import 'package:sail_ui/config/binaries.dart';

/// A single log entry capturing process output.
class FullProcessLogEntry {
  final DateTime timestamp;
  final String message;
  final bool isStderr;
  final BinaryType binaryType;
  final bool isStartupMarker;

  FullProcessLogEntry({
    required this.timestamp,
    required this.message,
    required this.isStderr,
    required this.binaryType,
    this.isStartupMarker = false,
  });

  /// Estimate the memory footprint of this entry (chars * 2 bytes + overhead).
  int get estimatedSizeBytes => message.length * 2 + 100;
}

/// A rolling buffer that evicts oldest entries when exceeding max size.
class LogBuffer {
  final int maxSizeBytes;
  final List<FullProcessLogEntry> entries = [];
  int currentSizeBytes = 0;

  LogBuffer({this.maxSizeBytes = 10 * 1024 * 1024}); // 10MB default

  void add(FullProcessLogEntry entry) {
    final entrySize = entry.estimatedSizeBytes;
    entries.add(entry);
    currentSizeBytes += entrySize;

    // Evict oldest entries until we're under the limit
    while (currentSizeBytes > maxSizeBytes && entries.length > 1) {
      final removed = entries.removeAt(0);
      currentSizeBytes -= removed.estimatedSizeBytes;
    }
  }

  void clear() {
    entries.clear();
    currentSizeBytes = 0;
  }
}

/// Provider that captures ALL process stdout/stderr output for viewing in the UI.
/// Stores up to ~10MB per binary with rolling buffer eviction.
class LogProvider extends ChangeNotifier {
  final Map<BinaryType, LogBuffer> _buffers = {};

  /// Add a log entry for a binary.
  void addLog(FullProcessLogEntry entry) {
    _buffers.putIfAbsent(entry.binaryType, () => LogBuffer());
    _buffers[entry.binaryType]!.add(entry);
    notifyListeners();
  }

  /// Add a startup marker entry (e.g., "--- Starting Bitcoin Core ---").
  void addStartupMarker(BinaryType type, String binaryName) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final entry = FullProcessLogEntry(
      timestamp: now,
      message: '--- Starting $binaryName (attempt at $timeStr) ---',
      isStderr: false,
      binaryType: type,
      isStartupMarker: true,
    );
    addLog(entry);
  }

  /// Add an exit marker entry (e.g., "--- Bitcoin Core exited (code 0) ---").
  void addExitMarker(BinaryType type, String binaryName, int? exitCode) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final codeStr = exitCode != null ? ' (code $exitCode)' : '';
    final entry = FullProcessLogEntry(
      timestamp: now,
      message: '--- $binaryName exited$codeStr at $timeStr ---',
      isStderr: false,
      binaryType: type,
      isStartupMarker: true,
    );
    addLog(entry);
  }

  /// Get all logs for a specific binary.
  List<FullProcessLogEntry> getLogsForBinary(BinaryType type) {
    return _buffers[type]?.entries ?? [];
  }

  /// Check if there are any logs for a binary.
  bool hasLogsForBinary(BinaryType type) {
    final buffer = _buffers[type];
    return buffer != null && buffer.entries.isNotEmpty;
  }

  /// Clear logs for a specific binary.
  void clearLogsForBinary(BinaryType type) {
    _buffers[type]?.clear();
    notifyListeners();
  }

  /// Clear all logs.
  void clearAll() {
    for (final buffer in _buffers.values) {
      buffer.clear();
    }
    notifyListeners();
  }
}
