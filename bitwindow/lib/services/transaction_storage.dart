import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:path/path.dart' as path;

/// Service for managing multisig transaction storage in transactions.json
class TransactionStorage {
  static const String _fileName = 'transactions.json';

  /// Get the path to the transactions.json file
  static Future<String> _getTransactionsFilePath() async {
    final appDir = await Environment.datadir();
    final bitdriveDir = Directory(path.join(appDir.path, 'bitdrive'));
    
    // Ensure bitdrive directory exists
    if (!await bitdriveDir.exists()) {
      await bitdriveDir.create(recursive: true);
    }
    
    return path.join(bitdriveDir.path, _fileName);
  }

  /// Load all transactions from transactions.json
  static Future<List<MultisigTransaction>> loadTransactions() async {
    try {
      final filePath = await _getTransactionsFilePath();
      final file = File(filePath);
      
      if (!await file.exists()) {
        // Return empty list if file doesn't exist yet
        return [];
      }
      
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return [];
      }
      
      final jsonList = json.decode(content) as List<dynamic>;
      return jsonList
          .map((txJson) => MultisigTransaction.fromJson(txJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  /// Save all transactions to transactions.json
  static Future<void> saveTransactions(List<MultisigTransaction> transactions) async {
    try {
      final filePath = await _getTransactionsFilePath();
      final file = File(filePath);
      
      final jsonList = transactions.map((tx) => tx.toJson()).toList();
      final content = json.encode(jsonList);
      
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to save transactions: $e');
    }
  }

  /// Add or update a single transaction
  static Future<void> saveTransaction(MultisigTransaction transaction) async {
    final transactions = await loadTransactions();
    
    // Find existing transaction with same ID
    final existingIndex = transactions.indexWhere((tx) => tx.id == transaction.id);
    
    if (existingIndex != -1) {
      // Update existing transaction
      transactions[existingIndex] = transaction;
    } else {
      // Add new transaction
      transactions.add(transaction);
    }
    
    await saveTransactions(transactions);
  }

  /// Get a specific transaction by ID
  static Future<MultisigTransaction?> getTransaction(String transactionId) async {
    final transactions = await loadTransactions();
    try {
      return transactions.firstWhere((tx) => tx.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  /// Get all transactions for a specific multisig group
  static Future<List<MultisigTransaction>> getTransactionsForGroup(String groupId) async {
    final transactions = await loadTransactions();
    return transactions.where((tx) => tx.groupId == groupId).toList();
  }

  /// Delete a transaction
  static Future<void> deleteTransaction(String transactionId) async {
    final transactions = await loadTransactions();
    transactions.removeWhere((tx) => tx.id == transactionId);
    await saveTransactions(transactions);
  }

  /// Update transaction status and related fields
  static Future<void> updateTransactionStatus(
    String transactionId,
    TxStatus status, {
    String? txid,
    DateTime? broadcastTime,
    int? confirmations,
    String? combinedPSBT,
    String? finalHex,
  }) async {
    final transaction = await getTransaction(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    final updatedTransaction = transaction.copyWith(
      status: status,
      txid: txid ?? transaction.txid,
      broadcastTime: broadcastTime ?? transaction.broadcastTime,
      confirmations: confirmations ?? transaction.confirmations,
      combinedPSBT: combinedPSBT ?? transaction.combinedPSBT,
      finalHex: finalHex ?? transaction.finalHex,
    );

    await saveTransaction(updatedTransaction);
  }

  /// Update a key's PSBT signing status
  static Future<void> updateKeyPSBT(
    String transactionId,
    String keyId,
    String signedPSBT, {
    int? signatureThreshold,
  }) async {
    final transaction = await getTransaction(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    // Find and update the specific key's PSBT status
    final updatedKeyPSBTs = transaction.keyPSBTs.map((keyPSBT) {
      if (keyPSBT.keyId == keyId) {
        return KeyPSBTStatus(
          keyId: keyId,
          psbt: signedPSBT,
          isSigned: true,
          signedAt: DateTime.now(),
        );
      }
      return keyPSBT;
    }).toList();

    // Check if we have enough signatures
    final signedCount = updatedKeyPSBTs.where((k) => k.isSigned).length;
    final threshold = signatureThreshold ?? transaction.requiredSignatures;
    final newStatus = signedCount >= threshold
      ? TxStatus.readyForBroadcast
      : TxStatus.needsSignatures;

    final updatedTransaction = transaction.copyWith(
      keyPSBTs: updatedKeyPSBTs,
      status: newStatus,
    );

    await saveTransaction(updatedTransaction);
  }

  /// Get transactions that need confirmation updates (broadcasted but not confirmed)
  static Future<List<MultisigTransaction>> getTransactionsNeedingConfirmationUpdate() async {
    final transactions = await loadTransactions();
    return transactions.where((tx) => 
      tx.status == TxStatus.broadcasted && tx.txid != null,
    ).toList();
  }

  /// Update transaction with combined PSBT
  static Future<void> updateCombinedPSBT(
    String transactionId,
    String combinedPSBT,
  ) async {
    final transaction = await getTransaction(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    final updatedTransaction = transaction.copyWith(
      combinedPSBT: combinedPSBT,
      status: TxStatus.readyForBroadcast,
    );

    await saveTransaction(updatedTransaction);
  }

  /// Update transaction with finalized hex for broadcasting
  static Future<void> updateFinalHex(
    String transactionId,
    String finalHex,
  ) async {
    final transaction = await getTransaction(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    final updatedTransaction = transaction.copyWith(
      finalHex: finalHex,
      status: TxStatus.readyForBroadcast,
    );

    await saveTransaction(updatedTransaction);
  }

  /// Add or update a key PSBT status (for import flow)
  static Future<void> addOrUpdateKeyPSBT(
    String transactionId,
    String keyId,
    String psbt,
    bool isSigned, {
    int? signatureThreshold,
  }) async {
    final transaction = await getTransaction(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    final keyPSBTs = List<KeyPSBTStatus>.from(transaction.keyPSBTs);
    final existingIndex = keyPSBTs.indexWhere((k) => k.keyId == keyId);
    
    final newKeyPSBT = KeyPSBTStatus(
      keyId: keyId,
      psbt: psbt,
      isSigned: isSigned,
      signedAt: isSigned ? DateTime.now() : null,
    );

    if (existingIndex != -1) {
      keyPSBTs[existingIndex] = newKeyPSBT;
    } else {
      keyPSBTs.add(newKeyPSBT);
    }

    // Check if we have enough signatures
    final signedCount = keyPSBTs.where((k) => k.isSigned).length;
    final threshold = signatureThreshold ?? transaction.requiredSignatures;
    final newStatus = signedCount >= threshold
      ? TxStatus.readyForBroadcast
      : TxStatus.needsSignatures;

    final updatedTransaction = transaction.copyWith(
      keyPSBTs: keyPSBTs,
      status: newStatus,
    );

    await saveTransaction(updatedTransaction);
  }
}