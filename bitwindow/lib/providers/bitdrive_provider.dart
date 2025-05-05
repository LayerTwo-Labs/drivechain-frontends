import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';

class BitDriveContent {
  final String fileName;
  final Uint8List content;

  BitDriveContent({
    required this.fileName,
    required this.content,
  });
}

// Class to store information about pending downloads
class PendingDownload {
  final String txid;
  final bool isEncrypted;
  final int timestamp;
  final String fileType;

  PendingDownload({
    required this.txid,
    required this.isEncrypted,
    required this.timestamp,
    required this.fileType,
  });

  String get fileName => '$timestamp.$fileType';
}

class BitDriveProvider extends ChangeNotifier {
  BitwindowRPC get bitwindowd => GetIt.I.get<BitwindowRPC>();
  Logger get log => GetIt.I.get<Logger>();
  HDWalletProvider get hdWallet => GetIt.I.get<HDWalletProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();

  bool initialized = false;
  String? error;
  bool _isFetching = false;
  bool _hasRestoredFiles = false;

  // Scan and download state
  bool _isScanning = false;
  bool get isScanning => _isScanning;
  final List<PendingDownload> _pendingDownloads = [];
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
  int fee = 1000;
  String? _bitdriveDir;

  // Constants
  static const int BITDRIVE_DERIVATION_INDEX = 4000;
  static const String BITDRIVE_DERIVATION_PATH = "m/44'/0'/0'/$BITDRIVE_DERIVATION_INDEX";
  static const String AUTH_KEY_PATH = "m/44'/0'/0'/$BITDRIVE_DERIVATION_INDEX/1";
  static const int AUTH_TAG_SIZE = 8; // 8 bytes auth tag

  BitDriveProvider() {
    // Listen for blockchain sync status changes
    blockchainProvider.addListener(_onSyncStatusChanged);
  }

  @override
  void dispose() {
    blockchainProvider.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  void _onSyncStatusChanged() async {
    if (blockchainProvider.infoProvider.mainchainSyncInfo == null) {
      return;
    }

    if (!_hasRestoredFiles && blockchainProvider.infoProvider.mainchainSyncInfo!.isSynced) {
      log.i('BitDrive: Starting file restoration on sync');
      await autoRestoreFiles();
      _hasRestoredFiles = true;
    }
  }

  // Optimized key stream generation
  Future<Uint8List> _deriveKeyStream(int timestamp, String fileType, int length) async {
    // Get wallet key and create a deterministic seed based on file metadata
    final keyInfo = await hdWallet.deriveKeyInfo(hdWallet.mnemonic ?? '', BITDRIVE_DERIVATION_PATH);
    final privateKeyHex = keyInfo['privateKey'] ?? '';

    // Create seed value from key and metadata
    final seedValue = utf8.encode('$privateKeyHex:$timestamp:$fileType');
    final seed = sha256.convert(seedValue).bytes;

    // Optimized stream generation with pre-allocated buffer
    final result = Uint8List(length);
    var bytesGenerated = 0;
    var counter = 0;

    while (bytesGenerated < length) {
      // Create counter bytes
      final counterData = ByteData(4)..setUint32(0, counter);
      final counterBytes = counterData.buffer.asUint8List();

      // Generate block
      final blockInput = Uint8List(seed.length + counterBytes.length);
      blockInput.setAll(0, seed);
      blockInput.setAll(seed.length, counterBytes);

      final block = sha256.convert(blockInput).bytes;

      // Copy block to result
      final bytesToCopy = min(block.length, length - bytesGenerated);
      result.setRange(bytesGenerated, bytesGenerated + bytesToCopy, block);

      bytesGenerated += bytesToCopy;
      counter++;
    }

    return result;
  }

  Future<Uint8List> _deriveAuthKey() async {
    final keyInfo = await hdWallet.deriveKeyInfo(hdWallet.mnemonic ?? '', AUTH_KEY_PATH);
    final privateKeyHex = keyInfo['privateKey'] ?? '';
    return Uint8List.fromList(hex.decode(privateKeyHex));
  }

  Future<Uint8List> _encryptContent(Uint8List content, int timestamp, String fileType) async {
    try {
      // Generate key stream and perform XOR encryption
      final keyStream = await _deriveKeyStream(timestamp, fileType, content.length);
      final encrypted = Uint8List(content.length);

      for (var i = 0; i < content.length; i++) {
        encrypted[i] = content[i] ^ keyStream[i];
      }

      // Generate truncated authentication tag
      final authKey = await _deriveAuthKey();
      final tag = Uint8List.fromList(Hmac(sha256, authKey).convert(encrypted).bytes.sublist(0, AUTH_TAG_SIZE));

      // Combine encrypted content with tag
      final result = Uint8List(encrypted.length + tag.length);
      result.setAll(0, encrypted);
      result.setAll(encrypted.length, tag);

      log.d('BitDrive: Encrypted ${content.length} bytes to ${result.length} bytes');
      return result;
    } catch (e) {
      log.e('BitDrive: Encryption error: $e');
      rethrow;
    }
  }

  Future<Uint8List> _decryptContent(Uint8List encryptedData, int timestamp, String fileType) async {
    try {
      if (encryptedData.length <= AUTH_TAG_SIZE) {
        throw Exception('Invalid encrypted data: too short');
      }

      // Extract content and authentication tag
      final contentLength = encryptedData.length - AUTH_TAG_SIZE;
      final encryptedContent = encryptedData.sublist(0, contentLength);
      final receivedTag = encryptedData.sublist(contentLength);

      // Verify authentication tag
      final authKey = await _deriveAuthKey();
      final hmac = Hmac(sha256, authKey);
      final calculatedTag = hmac.convert(encryptedContent).bytes.sublist(0, AUTH_TAG_SIZE);

      // Constant-time comparison
      if (!_constantTimeEquals(receivedTag, calculatedTag)) {
        throw Exception('Authentication failed: data may be corrupted');
      }

      // Decrypt content
      final keyStream = await _deriveKeyStream(timestamp, fileType, contentLength);
      final decrypted = Uint8List(contentLength);

      for (var i = 0; i < contentLength; i++) {
        decrypted[i] = encryptedContent[i] ^ keyStream[i];
      }

      return decrypted;
    } catch (e) {
      log.e('BitDrive: Decryption error: $e');
      rethrow;
    }
  }

  // Constant-time comparison to prevent timing attacks
  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    var equal = true;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) equal = false;
    }
    return equal;
  }

  Future<void> init() async {
    try {
      final appDir = await Environment.datadir();
      _bitdriveDir = path.join(appDir.path, 'bitdrive');
      final dir = Directory(_bitdriveDir!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      if (blockchainProvider.infoProvider.mainchainSyncInfo == null) {
        return;
      }

      if (blockchainProvider.infoProvider.mainchainSyncInfo!.isSynced && !_hasRestoredFiles) {
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
    if (_bitdriveDir == null) return;

    try {
      log.i('BitDrive: Starting file restoration...');
      final walletTxs = await bitwindowd.wallet.listTransactions();

      var restoredCount = 0;
      for (final tx in walletTxs) {
        try {
          if (!await hasOpReturn(tx.txid)) continue;

          final opReturns = await bitwindowd.misc.listOPReturns();
          final opReturn = opReturns.firstWhere(
            (op) => op.txid == tx.txid,
            orElse: () => throw Exception('No OP_RETURN found'),
          );

          if (!opReturn.message.contains('|')) continue;

          final parts = opReturn.message.split('|');
          if (parts.length != 2) continue;

          final metadataBytes = base64.decode(parts[0]);
          if (metadataBytes.length != 9) continue;

          final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
          final isEncrypted = metadata.getUint8(0) == 1;
          final timestamp = metadata.getUint32(1);
          final fileType = utf8.decode(metadataBytes.sublist(5, 9)).trim();

          final fileName = '$timestamp.$fileType';
          final file = File(path.join(_bitdriveDir!, fileName));

          if (await file.exists()) continue;

          final contentBytes = base64.decode(parts[1]);
          final content = isEncrypted ? await _decryptContent(contentBytes, timestamp, fileType) : contentBytes;

          await file.writeAsBytes(content);
          restoredCount++;
        } catch (e) {
          log.e('BitDrive: Error processing tx ${tx.txid}: $e');
          continue;
        }
      }

      log.i('BitDrive: Restored $restoredCount files');
    } catch (e) {
      log.e('BitDrive: Restoration error: $e');
      error = e.toString();
      notifyListeners();
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
    if (_isFetching) return;
    _isFetching = true;
    error = null;

    try {
      final content = fileContent ?? Uint8List.fromList(textContent?.codeUnits ?? []);
      if (content.isEmpty) {
        throw Exception('No content to store');
      }

      // Create metadata (9 bytes: 1 byte flag + 4 bytes timestamp + 4 bytes filetype)
      final metadata = ByteData(9);
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final fileType = _detectFileType(content);

      metadata.setUint8(0, shouldEncrypt ? 1 : 0);
      metadata.setUint32(1, timestamp);

      final typeBytes = utf8.encode(fileType.padRight(4, ' '));
      for (var i = 0; i < 4; i++) {
        metadata.setUint8(5 + i, typeBytes[i]);
      }

      final metadataStr = base64.encode(metadata.buffer.asUint8List());

      // Process content
      String contentStr;
      if (!shouldEncrypt && fileType == 'txt' && textContent != null) {
        // Store unencrypted text directly for human readability
        contentStr = textContent!;
      } else {
        final processedContent = shouldEncrypt ? await _encryptContent(content, timestamp, fileType) : content;

        if (processedContent.isEmpty) {
          throw Exception('Processing error: empty result');
        }

        contentStr = base64.encode(processedContent);
      }

      // Combine and store
      final opReturnData = '$metadataStr|$contentStr';
      log.d('BitDrive: OP_RETURN size: ${opReturnData.length} bytes');

      final address = await bitwindowd.wallet.getNewAddress();
      final txid = await bitwindowd.wallet.sendTransaction(
        {address: 10000}, // 0.0001 BTC
        fixedFeeSats: 1000,
        opReturnMessage: opReturnData,
      );

      log.d('BitDrive: Stored in tx: $txid');
      notifyListeners();
    } catch (e) {
      error = e.toString();
      log.e('BitDrive: Store error: $e');
      notifyListeners();
      rethrow;
    } finally {
      _isFetching = false;
    }
  }

  Future<List<int>> retrieveContent(String txid) async {
    try {
      // Get transaction data
      final opReturns = await bitwindowd.misc.listOPReturns();
      final opReturn = opReturns.firstWhere(
        (op) => op.txid == txid,
        orElse: () => throw Exception('No OP_RETURN data found'),
      );

      // Parse data
      final parts = opReturn.message.split('|');
      if (parts.length != 2) {
        throw Exception('Invalid data format');
      }

      // Parse metadata
      final metadataBytes = base64.decode(parts[0]);
      if (metadataBytes.length != 9) {
        throw Exception('Invalid metadata');
      }

      final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
      final isEncrypted = metadata.getUint8(0) == 1;
      final timestamp = metadata.getUint32(1);
      final fileType = utf8.decode(metadataBytes.sublist(5, 9)).trim();

      // Process content based on type
      if (!isEncrypted && fileType == 'txt') {
        return utf8.encode(parts[1]);
      } else {
        final contentBytes = base64.decode(parts[1]);

        if (isEncrypted) {
          final decryptedBytes = await _decryptContent(contentBytes, timestamp, fileType);

          // Format text files properly
          if (fileType == 'txt') {
            try {
              final textContent = utf8.decode(decryptedBytes);
              return utf8.encode(textContent);
            } catch (e) {
              log.w('BitDrive: Text decode failed, returning raw bytes: $e');
              return decryptedBytes;
            }
          }

          return decryptedBytes;
        }

        return contentBytes;
      }
    } catch (e) {
      log.e('BitDrive: Retrieval error: $e');
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> hasOpReturn(String txid) async {
    try {
      final opReturns = await bitwindowd.misc.listOPReturns();
      return opReturns.any((op) => op.txid == txid);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  String _detectFileType(List<int> content) {
    // Check file signatures
    if (content.length >= 2) {
      // JPEG
      if (content[0] == 0xFF && content[1] == 0xD8) {
        return 'jpg';
      }
      // PNG
      if (content.length >= 8 && content[0] == 0x89 && content[1] == 0x50 && content[2] == 0x4E && content[3] == 0x47) {
        return 'png';
      }
      // GIF
      if (content.length >= 6 && content[0] == 0x47 && content[1] == 0x49 && content[2] == 0x46) {
        return 'gif';
      }
      // PDF
      if (content.length >= 4 && content[0] == 0x25 && content[1] == 0x50 && content[2] == 0x44 && content[3] == 0x46) {
        return 'pdf';
      }
    }

    // Try to detect text files
    try {
      final str = utf8.decode(content.take(1024).toList());
      if (str.trim().isNotEmpty) {
        return 'txt';
      }
    } catch (_) {}

    return 'bin';
  }

  Future<void> scanForFiles() async {
    if (_isScanning || _bitdriveDir == null) return;

    _isScanning = true;
    _pendingDownloads.clear();
    error = null;
    notifyListeners();

    try {
      final walletTxs = await bitwindowd.wallet.listTransactions();

      for (final tx in walletTxs) {
        try {
          if (!await hasOpReturn(tx.txid)) continue;

          final opReturns = await bitwindowd.misc.listOPReturns();
          final opReturn = opReturns.firstWhere(
            (op) => op.txid == tx.txid,
            orElse: () => throw Exception('No OP_RETURN found'),
          );

          if (!opReturn.message.contains('|')) continue;

          final parts = opReturn.message.split('|');
          if (parts.length != 2) continue;

          final metadataBytes = base64.decode(parts[0]);
          if (metadataBytes.length != 9) continue;

          final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
          final isEncrypted = metadata.getUint8(0) == 1;
          final timestamp = metadata.getUint32(1);
          final fileType = utf8.decode(metadataBytes.sublist(5, 9)).trim();

          final fileName = '$timestamp.$fileType';
          final file = File(path.join(_bitdriveDir!, fileName));

          if (await file.exists()) continue;

          _pendingDownloads.add(
            PendingDownload(
              txid: tx.txid,
              isEncrypted: isEncrypted,
              timestamp: timestamp,
              fileType: fileType,
            ),
          );
        } catch (e) {
          log.e('BitDrive: Error scanning tx ${tx.txid}: $e');
          continue;
        }
      }

      log.i('BitDrive: Found ${_pendingDownloads.length} files to download');
    } catch (e) {
      log.e('BitDrive: Scan error: $e');
      error = e.toString();
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> downloadPendingFiles() async {
    if (_isDownloading || _pendingDownloads.isEmpty || _bitdriveDir == null) return;

    _isDownloading = true;
    error = null;
    notifyListeners();

    try {
      int downloadedCount = 0;
      List<PendingDownload> downloaded = [];

      for (final pendingFile in _pendingDownloads) {
        try {
          final content = await retrieveContent(pendingFile.txid);
          final file = File(path.join(_bitdriveDir!, pendingFile.fileName));
          await file.writeAsBytes(content);

          downloadedCount++;
          downloaded.add(pendingFile);
        } catch (e) {
          log.e('BitDrive: Error downloading ${pendingFile.fileName}: $e');
          continue;
        }
      }

      _pendingDownloads.removeWhere((pending) => downloaded.contains(pending));
      log.i('BitDrive: Downloaded $downloadedCount files');
    } catch (e) {
      log.e('BitDrive: Download error: $e');
      error = e.toString();
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  // Helper function
  int min(int a, int b) => a < b ? a : b;
}

class StoredContent {
  final String fileName;
  final String mimeType;
  final Uint8List content;
  final bool encrypted;
  final DateTime timestamp;

  StoredContent({
    required this.fileName,
    required this.mimeType,
    required this.content,
    required this.encrypted,
    required this.timestamp,
  });
}
