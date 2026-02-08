import 'dart:async';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

class BitDriveProvider extends ChangeNotifier {
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  Logger get log => GetIt.I.get<Logger>();
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  bool initialized = false;
  String? error;
  bool _isStoring = false;
  bool _isRestoring = false;
  bool _hasRestoredFiles = false;
  bool _hasLoggedWaitingForSync = false;
  bool _hasLoggedWaitingForEnforcer = false;

  // Scan and download state
  bool _isScanning = false;
  bool get isScanning => _isScanning;
  List<PendingFile> _pendingDownloads = [];
  int get pendingDownloadsCount => _pendingDownloads.length;
  bool get hasPendingDownloads => _pendingDownloads.isNotEmpty;
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  // File/text content to be stored
  Uint8List? fileContent;
  String? textContent;
  String? fileName;
  String? mimeType;
  bool shouldEncrypt = true;
  int fee = 1;
  String? _bitdriveDir;

  BitDriveProvider() {
    blockchainProvider.addListener(_onSyncStatusChanged);
    enforcer.addListener(_onSyncStatusChanged);
    _walletReader.addListener(_onWalletChanged);
  }

  @override
  void dispose() {
    blockchainProvider.removeListener(_onSyncStatusChanged);
    enforcer.removeListener(_onSyncStatusChanged);
    _walletReader.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() {
    _pendingDownloads.clear();
    _hasRestoredFiles = false;
    _hasLoggedWaitingForSync = false;
    _hasLoggedWaitingForEnforcer = false;
    notifyListeners();
  }

  void _onSyncStatusChanged() async {
    if (!initialized) {
      return;
    }

    if (blockchainProvider.syncProvider.mainchainSyncInfo == null) {
      return;
    }

    final isSynced = blockchainProvider.syncProvider.mainchainSyncInfo!.isSynced;
    final isEnforcerConnected = enforcer.connected;

    if (!_hasRestoredFiles && isSynced && isEnforcerConnected) {
      log.i('BitDrive: Starting file restoration on sync complete and enforcer connected');
      await autoRestoreFiles();
      _hasRestoredFiles = true;
      _hasLoggedWaitingForSync = false;
      _hasLoggedWaitingForEnforcer = false;
    } else if (!isSynced && !_hasLoggedWaitingForSync) {
      log.d('BitDrive: Waiting for blockchain sync to complete');
      _hasLoggedWaitingForSync = true;
    } else if (!isEnforcerConnected && isSynced && !_hasLoggedWaitingForEnforcer) {
      log.d('BitDrive: Waiting for enforcer connection');
      _hasLoggedWaitingForEnforcer = true;
    }
  }

  Future<void> init() async {
    try {
      final appDir = await Environment.datadir();
      _bitdriveDir = path.join(appDir.path, 'bitdrive');
      final dir = Directory(_bitdriveDir!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      if (blockchainProvider.syncProvider.mainchainSyncInfo == null) {
        return;
      }

      if (blockchainProvider.syncProvider.mainchainSyncInfo!.isSynced && !_hasRestoredFiles) {
        await autoRestoreFiles();
        _hasRestoredFiles = true;
      }

      initialized = true;
      notifyListeners();
    } catch (e) {
      log.e('BitDrive init error: $e');
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> autoRestoreFiles() async {
    if (_isRestoring) return;
    _isRestoring = true;

    try {
      log.i('BitDrive: Starting file restoration via RPC...');
      final response = await bitwindowd.bitdrive.downloadPendingFiles();
      log.i('BitDrive: Restored ${response.downloadedCount} files (${response.failedCount} failed)');
    } catch (e) {
      log.e('BitDrive: Restoration error: $e');
      error = e.toString();
      notifyListeners();
    } finally {
      _isRestoring = false;
    }
  }

  Future<void> setFileContent(Uint8List content, {String? name, String? type}) async {
    if (content.length > 1024 * 1024) {
      error = 'File size must be less than 1MB';
      notifyListeners();
      return;
    }
    fileContent = content;
    fileName = name;
    mimeType = type;
    textContent = null;
    error = null;
    notifyListeners();
  }

  Future<void> setTextContent(String content) async {
    if (content.length > 1024 * 1024) {
      error = 'Text size must be less than 1MB';
      notifyListeners();
      return;
    }
    textContent = content;
    fileContent = null;
    fileName = 'text.txt';
    mimeType = 'text/plain';
    error = null;
    notifyListeners();
  }

  void setEncryption(bool value) {
    shouldEncrypt = value;
    notifyListeners();
  }

  void setFee(double value) {
    fee = (btcToSatoshi(value)).toInt();
    notifyListeners();
  }

  Future<void> store() async {
    if (_isStoring) return;
    _isStoring = true;
    error = null;

    try {
      final content = fileContent ?? Uint8List.fromList(textContent?.codeUnits ?? []);
      if (content.isEmpty) {
        throw Exception('No content to store');
      }

      final response = await bitwindowd.bitdrive.storeFile(
        content: content,
        filename: fileName,
        mimeType: mimeType,
        encrypt: shouldEncrypt,
        feeSatPerVbyte: fee,
      );

      log.i(
        'BitDrive: Stored file with txid ${response.txid}, type: ${response.fileType}, encrypted: ${response.encrypted}',
      );
      notifyListeners();
    } catch (e) {
      error = e.toString();
      log.e('BitDrive: Store error: $e');
      notifyListeners();
      rethrow;
    } finally {
      _isStoring = false;
    }
  }

  Future<List<int>> retrieveContent(String txid) async {
    try {
      final response = await bitwindowd.bitdrive.retrieveContent(txid);
      return response.content;
    } catch (e) {
      log.e('BitDrive: Retrieval error: $e');
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> scanForFiles() async {
    if (_isScanning) return;

    _isScanning = true;
    _pendingDownloads.clear();
    error = null;
    notifyListeners();

    try {
      final response = await bitwindowd.bitdrive.scanForFiles();
      _pendingDownloads = response.pendingFiles;
      log.i('BitDrive: Scan found ${_pendingDownloads.length} pending files (scanned ${response.totalScanned} total)');
    } catch (e) {
      log.e('BitDrive: Scan error: $e');
      error = e.toString();
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> downloadPendingFiles() async {
    if (_isDownloading || _pendingDownloads.isEmpty) return;

    _isDownloading = true;
    error = null;
    notifyListeners();

    try {
      final response = await bitwindowd.bitdrive.downloadPendingFiles();
      log.i('BitDrive: Downloaded ${response.downloadedCount} files (${response.failedCount} failed)');
      _pendingDownloads.clear();
    } catch (e) {
      log.e('BitDrive: Download error: $e');
      error = e.toString();
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<List<BitDriveFile>> listFiles() async {
    try {
      return await bitwindowd.bitdrive.listFiles();
    } catch (e) {
      log.e('BitDrive: List files error: $e');
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> wipeData(Directory appDir) async {
    try {
      await bitwindowd.bitdrive.wipeData();
      final bitdriveDir = Directory(path.join(appDir.path, 'bitdrive'));
      if (await bitdriveDir.exists()) {
        await bitdriveDir.delete(recursive: true);
      }
    } catch (e) {
      log.e('BitDrive: Wipe data error: $e');
      error = e.toString();
      notifyListeners();
    }
  }
}
