import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
import 'package:sail_ui/providers/sync_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

const int maxFileSizeBytes = 1024 * 1024; // 1MB

class TimestampProvider extends ChangeNotifier {
  final Logger log = Logger(level: Level.debug);
  final BitwindowRPC _bitwindowRPC = GetIt.I.get<BitwindowRPC>();
  SyncProvider get _syncProvider => GetIt.I.get<SyncProvider>();

  List<FileTimestamp> timestamps = [];
  bool isLoading = false;
  String? modelError;

  Timer? _pollTimer;

  TimestampProvider() {
    _bitwindowRPC.addListener(_onBitwindowConnectionChanged);
    _syncProvider.addListener(_onNewBlock);
    _init();
  }

  Future<void> _init() async {
    if (_bitwindowRPC.connected) {
      await fetch();
    }
  }

  void _onBitwindowConnectionChanged() {
    if (_bitwindowRPC.connected) {
      fetch();
    }
  }

  void _onNewBlock() {
    if (_syncProvider.isSynced) {
      fetch();
    }
  }

  Future<void> fetch() async {
    isLoading = true;
    modelError = null;
    notifyListeners();

    try {
      timestamps = await _bitwindowRPC.misc.listTimestamps();
      modelError = null;
    } catch (e) {
      log.e('Failed to fetch timestamps: $e');
      modelError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<FileTimestamp?> timestampFile(String filename, List<int> fileData) async {
    if (fileData.length > maxFileSizeBytes) {
      modelError = 'File too large. Maximum size: 1MB';
      notifyListeners();
      return null;
    }

    try {
      final resp = await _bitwindowRPC.misc.timestampFile(filename, fileData);

      final timestamp = FileTimestamp(
        id: resp.id,
        filename: filename,
        fileHash: resp.fileHash,
        txid: resp.txid,
        status: 'confirming',
      );

      timestamps.insert(0, timestamp);
      notifyListeners();
      startPolling();
      return timestamp;
    } catch (e) {
      log.e('Failed to timestamp file: $e');
      modelError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<VerifyTimestampResponse?> verifyFile(List<int> fileData, String filename) async {
    if (fileData.length > maxFileSizeBytes) {
      modelError = 'File too large. Maximum size: 1MB';
      notifyListeners();
      return null;
    }

    try {
      final resp = await _bitwindowRPC.misc.verifyTimestamp(fileData, filename);
      modelError = null;
      return resp;
    } catch (e) {
      log.e('Failed to verify timestamp: $e');
      modelError = e.toString();
      notifyListeners();
      return null;
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    stopPolling();
    _pollTimer = Timer.periodic(interval, (_) async {
      if (timestamps.any((t) => t.status == 'pending' || t.status == 'confirming')) {
        await fetch();
      } else {
        stopPolling();
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _bitwindowRPC.removeListener(_onBitwindowConnectionChanged);
    _syncProvider.removeListener(_onNewBlock);
    stopPolling();
    super.dispose();
  }
}
