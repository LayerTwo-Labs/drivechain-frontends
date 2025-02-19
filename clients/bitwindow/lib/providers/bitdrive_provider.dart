import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:bitwindow/env.dart';

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

  bool initialized = false;
  String? error;
  bool _isFetching = false;

  // File/text content to be stored
  Uint8List? fileContent;
  String? textContent;
  String? fileName;
  String? mimeType;
  bool shouldEncrypt = true;
  double fee = 0.0001;
  String? _bitdriveDir;

  Future<void> init() async {
    try {
      // Initialize BitDrive directory
      final appDir = await Environment.datadir();
      _bitdriveDir = '${appDir.path}/bitdrive';
      final dir = Directory(_bitdriveDir!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      // Auto-restore files
      await autoRestoreFiles();
      
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
      
      // Get current block height
      final blockInfo = await api.bitcoind.getBlockchainInfo();
      final currentHeight = blockInfo.blocks;
      log.d('BitDrive: Current block height: $currentHeight');

      // Get all OP_RETURN messages
      final opReturns = await api.misc.listOPReturns();
      log.d('BitDrive: Found ${opReturns.length} total OP_RETURN messages');
      
      var restoredCount = 0;
      // Process each OP_RETURN message
      for (final opReturn in opReturns) {
        try {
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

          // Retrieve content
          final content = await api.bitwindowd.retrieveContent(opReturn.txid);
          
          // Generate filename using block height and timestamp
          final fileName = 'block${currentHeight}_$timestamp.$fileType';
          final file = File('${_bitdriveDir!}/$fileName');
          
          // Save file
          await file.writeAsBytes(content);
          restoredCount++;
          
          log.d('BitDrive: Restored file: $fileName');
          log.d('BitDrive: - File type: $fileType');
          log.d('BitDrive: - Encrypted: $isEncrypted');
          log.d('BitDrive: - Timestamp: $timestamp');
        } catch (e) {
          log.e('BitDrive: Error processing OP_RETURN ${opReturn.txid}: $e');
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

      // Store content using BitwindowAPI
      final txid = await api.bitwindowd.storeContent(
        content: content.toList(),
        encrypt: shouldEncrypt,
        fee: fee,
      );

      log.d('Content stored in transaction: $txid');
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

  Future<List<BitDriveContent>> retrieveAllContent() async {
    final contents = <BitDriveContent>[];
    
    try {
      // Get recent transactions
      final txResponse = await api.wallet.listTransactions();

      for (final tx in txResponse) {
        try {
          // Check if transaction has OP_RETURN data
          if (!await api.bitwindowd.hasOpReturn(tx.txid)) continue;

          // Retrieve content
          final content = await api.bitwindowd.retrieveContent(tx.txid);
          
          // For now, use txid as filename since we don't have metadata
          contents.add(BitDriveContent(
            fileName: '${tx.txid}.bin',
            content: Uint8List.fromList(content),
          ),);
        } catch (e) {
          // Skip this transaction if there's an error
          continue;
        }
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }

    return contents;
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