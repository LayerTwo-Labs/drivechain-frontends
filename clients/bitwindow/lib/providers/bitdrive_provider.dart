import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:bitwindow/env.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';

class BitDriveContent {
  final String fileName;
  final Uint8List content;

  BitDriveContent({
    required this.fileName,
    required this.content,
  });
}

class BitDriveProvider extends ChangeNotifier {
  BitwindowRPC get api => GetIt.I.get<BitwindowRPC>();
  Logger get log => GetIt.I.get<Logger>();
  HDWalletProvider get hdWallet => GetIt.I.get<HDWalletProvider>();
  BlockchainProvider get blockchainProvider => GetIt.I.get<BlockchainProvider>();

  bool initialized = false;
  String? error;
  bool _isFetching = false;
  bool _hasRestoredFiles = false;

  // File/text content to be stored
  Uint8List? fileContent;
  String? textContent;
  String? fileName;
  String? mimeType;
  bool shouldEncrypt = true;
  double fee = 0.0001;
  String? _bitdriveDir;

  // Encryption constants
  static const int BITDRIVE_DERIVATION_INDEX = 4000;
  static const String BITDRIVE_DERIVATION_PATH = "m/44'/0'/0'/$BITDRIVE_DERIVATION_INDEX";

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
    if (!_hasRestoredFiles && blockchainProvider.isSynced) {
      log.i('BitDrive: Wallet is synced, starting file restoration...');
      await autoRestoreFiles();
      _hasRestoredFiles = true;
    }
  }

  Future<Uint8List> _extendKey(Uint8List initialKey, int targetLength) async {
    var currentKey = initialKey;
    var extendedKey = <int>[];

    while (extendedKey.length < targetLength) {
      // Store left half
      final digest = sha256.convert(currentKey);
      final leftHalf = Uint8List.fromList(digest.bytes.sublist(0, 16));
      extendedKey.addAll(leftHalf);

      // Use right half for next iteration
      currentKey = Uint8List.fromList(digest.bytes.sublist(16));
    }

    // Trim to exact length needed
    return Uint8List.fromList(extendedKey.sublist(0, targetLength));
  }

  Future<Uint8List> _encryptContent(Uint8List content) async {
    try {
      // Get private key from HD wallet at m/44'/0'/0'/4000
      final privateKeyHex = await hdWallet.derivePrivateKey(BITDRIVE_DERIVATION_PATH);

      // Convert hex to bytes
      final keyBytes = Uint8List.fromList(hex.decode(privateKeyHex));

      // Extend the key to content length
      final extendedKey = await _extendKey(keyBytes, content.length);

      // XOR the content with extended key
      final encrypted = Uint8List(content.length);
      for (var i = 0; i < content.length; i++) {
        encrypted[i] = content[i] ^ extendedKey[i];
      }

      return encrypted;
    } catch (e) {
      log.e('BitDrive: Error encrypting content: $e');
      rethrow;
    }
  }

  Future<Uint8List> _decryptContent(Uint8List encryptedContent) async {
    try {
      // Get private key from HD wallet at m/44'/0'/0'/4000
      final privateKeyHex = await hdWallet.derivePrivateKey(BITDRIVE_DERIVATION_PATH);

      // Convert hex to bytes
      final keyBytes = Uint8List.fromList(hex.decode(privateKeyHex));

      // Extend the key to encrypted content length
      final extendedKey = await _extendKey(keyBytes, encryptedContent.length);

      // XOR the encrypted content with extended key to decrypt
      final decrypted = Uint8List(encryptedContent.length);
      for (var i = 0; i < encryptedContent.length; i++) {
        decrypted[i] = encryptedContent[i] ^ extendedKey[i];
      }

      return decrypted;
    } catch (e) {
      log.e('BitDrive: Error decrypting content: $e');
      rethrow;
    }
  }

  Future<void> init() async {
    try {
      // Initialize BitDrive directory
      final appDir = await Environment.datadir();
      _bitdriveDir = path.join(appDir.path, 'bitdrive');
      final dir = Directory(_bitdriveDir!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Only restore files if wallet is already synced
      if (blockchainProvider.isSynced && !_hasRestoredFiles) {
        log.i('BitDrive: Wallet is already synced, starting file restoration...');
        await autoRestoreFiles();
        _hasRestoredFiles = true;
      }

      initialized = true;
      notifyListeners();
    } catch (e) {
      log.e('Error initializing BitDrive: $e');
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> autoRestoreFiles() async {
    if (_bitdriveDir == null) return;

    try {
      log.i('BitDrive: Starting automatic file restoration...');

      // Get wallet transactions
      final walletTxs = await api.wallet.listTransactions();
      log.d('BitDrive: Found ${walletTxs.length} wallet transactions');

      var restoredCount = 0;
      // Process each transaction
      for (final tx in walletTxs) {
        try {
          // Check if transaction has an OP_RETURN
          if (!await hasOpReturn(tx.txid)) continue;

          // Get the OP_RETURN data
          final opReturns = await api.misc.listOPReturns();
          final opReturn = opReturns.firstWhere(
            (op) => op.txid == tx.txid,
            orElse: () => throw Exception('No OP_RETURN found for transaction'),
          );

          // Skip if not a BitDrive message
          if (!opReturn.message.contains('|')) continue;

          // Parse metadata
          final parts = opReturn.message.split('|');
          if (parts.length != 2) continue;

          final metadataBytes = base64.decode(parts[0]);
          if (metadataBytes.length != 9) continue;

          // Extract metadata
          final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
          final isEncrypted = metadata.getUint8(0) == 1;
          final timestamp = metadata.getUint32(1);
          final fileType = utf8.decode(metadataBytes.sublist(5, 9)).trim();

          // Generate filename using just timestamp
          final fileName = '$timestamp.$fileType';
          final file = File(path.join(_bitdriveDir!, fileName));

          // Skip if file already exists
          if (await file.exists()) {
            log.d('BitDrive: File $fileName already exists, skipping...');
            continue;
          }

          log.d('BitDrive: Found file with encryption=$isEncrypted, timestamp=$timestamp, type=$fileType');

          // Decode content
          final contentBytes = base64.decode(parts[1]);

          // Decrypt if necessary
          final content = isEncrypted ? await _decryptContent(contentBytes) : contentBytes;

          // Save file
          await file.writeAsBytes(content);
          restoredCount++;
          log.d('BitDrive: Restored $fileName');
        } catch (e) {
          log.e('BitDrive: Error processing transaction ${tx.txid}: $e');
          continue;
        }
      }

      log.i('BitDrive: Automatic restoration complete. Restored $restoredCount files.');
    } catch (e) {
      log.e('BitDrive: Error during automatic file restoration: $e');
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
    fee = value;
    notifyListeners();
  }

  Future<void> store() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final content = fileContent ?? Uint8List.fromList(textContent?.codeUnits ?? []);
      if (content.isEmpty) {
        throw Exception('No content to store');
      }

      // Create compact metadata
      // Format: <1 byte encryption flag><4 bytes unix timestamp><4 bytes file extension>
      final metadata = ByteData(9);

      // Store flags and timestamp first
      metadata.setUint8(0, shouldEncrypt ? 1 : 0);
      metadata.setUint32(1, DateTime.now().millisecondsSinceEpoch ~/ 1000);

      // Store file type last
      final fileType = _detectFileType(content);
      final typeBytes = utf8.encode(fileType.padRight(4, ' '));
      for (var i = 0; i < 4; i++) {
        metadata.setUint8(5 + i, typeBytes[i]);
      }

      // Convert metadata to base64
      final metadataBytes = metadata.buffer.asUint8List();
      final metadataStr = base64.encode(metadataBytes);

      // Encrypt and encode content
      final processedContent = shouldEncrypt ? await _encryptContent(content) : content;
      final contentStr = base64.encode(processedContent);

      // Combine with a single delimiter
      final opReturnData = '$metadataStr|$contentStr';
      log.d('BitDrive: OP_RETURN data size: ${opReturnData.length} bytes');

      // Get a new address to send to
      final address = await api.wallet.getNewAddress();
      log.d('BitDrive: Generated new address: $address');

      // Send transaction with OP_RETURN
      final txid = await api.wallet.sendTransaction(
        address,
        10000, // 0.0001 BTC in satoshis
        btcPerKvB: fee,
        opReturnMessage: opReturnData,
      );
      log.d('BitDrive: Content stored in transaction: $txid');

      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isFetching = false;
    }
  }

  Future<List<int>> retrieveContent(String txid) async {
    try {
      log.d('BitDrive: Retrieving content from txid: $txid');

      // Get all OP_RETURN messages
      final opReturns = await api.misc.listOPReturns();
      // Find the one matching our txid
      final opReturn = opReturns.firstWhere(
        (op) => op.txid == txid,
        orElse: () {
          throw Exception('No OP_RETURN data found for transaction $txid');
        },
      );

      // Parse the data
      final parts = opReturn.message.split('|');
      if (parts.length != 2) {
        throw Exception('Invalid OP_RETURN data format');
      }

      // Parse metadata
      final metadataBytes = base64.decode(parts[0]);
      if (metadataBytes.length != 9) {
        throw Exception('Invalid metadata length');
      }

      final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
      final isEncrypted = metadata.getUint8(0) == 1;
      final timestamp = metadata.getUint32(1);
      final fileType = utf8.decode(metadataBytes.sublist(5, 9)).trim();

      log.d('BitDrive: Retrieved content metadata - encrypted=$isEncrypted, timestamp=$timestamp, file_type=$fileType');

      // Decode content
      final contentBytes = base64.decode(parts[1]);

      // Decrypt if necessary
      if (isEncrypted) {
        return await _decryptContent(contentBytes);
      }
      return contentBytes;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> hasOpReturn(String txid) async {
    try {
      final opReturns = await api.misc.listOPReturns();
      return opReturns.any((op) => op.txid == txid);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  String _detectFileType(List<int> content) {
    // Check file magic numbers
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

    // Default to binary
    return 'bin';
  }
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
