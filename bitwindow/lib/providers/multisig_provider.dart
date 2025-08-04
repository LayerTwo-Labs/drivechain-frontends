import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

// Helper function to log multisig debugging information to file
Future<void> _logToFile(String message) async {
  try {
    final dir = Directory(path.dirname(path.current));
    final file = File(path.join(dir.path, 'bitwindow', 'multisig_output.txt'));
    
    // Ensure parent directory exists
    await file.parent.create(recursive: true);
    
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString('[$timestamp] MULTISIG_PROVIDER: $message\n', mode: FileMode.append);
  } catch (e) {
    // Failed to write log file - continue silently
  }
}

/// Result of PSBT signing operation
class SigningResult {
  final String signedPsbt;
  final bool isComplete;
  final int signaturesAdded;
  final List<String> errors;
  
  SigningResult({
    required this.signedPsbt,
    required this.isComplete,
    required this.signaturesAdded,
    this.errors = const [],
  });
}

/// Handles PSBT signing for multisig wallets using descriptorprocesspsbt
class MultisigRPCSigner {
  final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();
  final HDWalletProvider _hdWallet = GetIt.I.get<HDWalletProvider>();

  /// Signs a PSBT using Bitcoin Core descriptorprocesspsbt RPC
  Future<SigningResult> signPSBT({
    required String psbtBase64,
    required MultisigGroup group,
    required String mnemonic,
    required List<MultisigKey> walletKeys,
    bool isMainnet = false,
  }) async {
    await _logToFile('=== STARTING MULTISIG PSBT SIGNING ===');
    await _logToFile('Group: ${group.name} (${group.m}-of-${group.n})');
    await _logToFile('Total keys in group: ${group.keys.length}');
    await _logToFile('Wallet keys to sign with: ${walletKeys.length}');
    await _logToFile('Network: ${isMainnet ? "mainnet" : "signet/testnet"}');
    
    final errors = <String>[];
    
    try {
      // Validate we have the required descriptors
      if (group.descriptorReceive == null || group.descriptorChange == null) {
        throw Exception('Group missing descriptors - cannot sign');
      }
      
      await _logToFile('\nMultisig descriptors:');
      await _logToFile('  Receive: ${group.descriptorReceive!.substring(0, 50)}...');
      await _logToFile('  Change: ${group.descriptorChange!.substring(0, 50)}...');
      
      // Sign with each participant wallet
      final participantPSBTs = <String>[];
      int totalSignaturesAdded = 0;
      
      for (int i = 0; i < walletKeys.length; i++) {
        final walletKey = walletKeys[i];
        await _logToFile('\n=== Participant ${i + 1}/${walletKeys.length}: ${walletKey.owner} ===');
        
        try {
          final result = await _signWithParticipant(
            walletKey: walletKey,
            mnemonic: mnemonic,
            psbtBase64: psbtBase64,
            group: group,
            isMainnet: isMainnet,
          );
          
          if (result != null) {
            participantPSBTs.add(result.signedPsbt);
            totalSignaturesAdded += result.signaturesAdded;
            await _logToFile('✓ Participant signed successfully, added ${result.signaturesAdded} signatures');
          }
          
        } catch (e) {
          final error = 'Failed to sign with ${walletKey.owner}: $e';
          errors.add(error);
          await _logToFile('✗ $error');
          // Continue with other participants
        }
      }
      
      if (participantPSBTs.isEmpty) {
        throw Exception('No participants could sign the PSBT');
      }
      
      // Combine PSBTs if multiple participants signed
      String finalPsbt;
      if (participantPSBTs.length > 1) {
        await _logToFile('\n=== Combining ${participantPSBTs.length} signed PSBTs ===');
        finalPsbt = await _rpc.callRAW('combinepsbt', [participantPSBTs]) as String;
        await _logToFile('✓ PSBTs combined successfully');
      } else {
        finalPsbt = participantPSBTs[0];
        await _logToFile('✓ Using single participant PSBT');
      }
      
      // Check if complete
      final isComplete = await _checkPsbtComplete(finalPsbt, group.m);
      
      
      await _logToFile('\n=== SIGNING SUMMARY ===');
      await _logToFile('Participants who signed: ${participantPSBTs.length}/${walletKeys.length}');
      await _logToFile('Total signatures added: $totalSignaturesAdded');
      await _logToFile('Required signatures: ${group.m}');
      await _logToFile('Transaction complete: $isComplete');
      
      // Only return success if we actually added signatures
      if (totalSignaturesAdded == 0 && participantPSBTs.isNotEmpty) {
        errors.add('No signatures were added despite successful processing');
        await _logToFile('WARNING: Signing completed but no signatures were added');
      }
      
      return SigningResult(
        signedPsbt: finalPsbt,
        isComplete: isComplete,
        signaturesAdded: totalSignaturesAdded,
        errors: errors,
      );
      
    } catch (e) {
      await _logToFile('\nCRITICAL ERROR: $e');
      throw Exception('Multisig PSBT signing failed: $e');
    }
  }
  
  /// Sign PSBT with a single participant using descriptorprocesspsbt
  Future<SigningResult?> _signWithParticipant({
    required MultisigKey walletKey,
    required String mnemonic,
    required String psbtBase64,
    required MultisigGroup group,
    required bool isMainnet,
  }) async {
    try {
      // Step 1: Derive private key for this participant
      await _logToFile('Deriving private key for path: ${walletKey.derivationPath}');
      final keyInfo = await _hdWallet.deriveExtendedKeyInfo(mnemonic, walletKey.derivationPath, isMainnet);
      final xprv = keyInfo['xprv'];
      final fingerprint = keyInfo['fingerprint'];
      
      if (xprv == null || xprv.isEmpty) {
        throw Exception('Failed to derive extended private key for ${walletKey.owner}');
      }
      
      await _logToFile('Derived ${isMainnet ? "mainnet" : "testnet"} private key for ${walletKey.owner}');
      
      // Step 2: Build descriptors with private keys for this participant
      final descriptors = await _buildPrivateDescriptors(
        group, walletKey, xprv, fingerprint!,
      );
      
      await _logToFile('Built descriptors for signing: ${descriptors.length} descriptors');
      
      // Step 3: Use descriptorprocesspsbt to sign directly
      await _logToFile('Signing PSBT with descriptorprocesspsbt');
      await _logToFile('RPC call: descriptorprocesspsbt');
      await _logToFile('  PSBT: ${psbtBase64.substring(0, 50)}...');
      await _logToFile('  Descriptors: $descriptors');
      await _logToFile('  Parameters: sighashtype=ALL, bip32derivs=true, finalize=false');
      
      final result = await _rpc.callRAW('descriptorprocesspsbt', [
        psbtBase64,
        descriptors,
        'ALL', // sighashtype
        true,  // bip32derivs
        false, // finalize
      ]);
      
      await _logToFile('RPC response: $result');
      
      if (result is Map) {
        final signedPsbt = result['psbt'] as String;
        final isComplete = result['complete'] as bool? ?? false;
        
        // Count signatures added
        final signaturesAdded = await _countNewSignatures(psbtBase64, signedPsbt);
        
        await _logToFile('Signing result - complete: $isComplete, signatures: $signaturesAdded');
        
        return SigningResult(
          signedPsbt: signedPsbt,
          isComplete: isComplete,
          signaturesAdded: signaturesAdded,
          errors: [],
        );
      }
      
      throw Exception('Invalid response from descriptorprocesspsbt');
      
    } catch (e) {
      await _logToFile('Error signing with participant: $e');
      rethrow;
    }
  }
  
  
  
  /// Count new signatures added to PSBT
  Future<int> _countNewSignatures(String psbtBefore, String psbtAfter) async {
    try {
      // If PSBTs are different, assume signatures were added
      if (psbtBefore != psbtAfter) {
        await _logToFile('PSBT changed - assuming 1 signature added');
        return 1;
      }
      
      await _logToFile('PSBT unchanged - no signatures added');
      return 0;
    } catch (e) {
      await _logToFile('Could not count signatures: $e');
      return 0;
    }
  }
  
  /// Build descriptors with private keys for descriptorprocesspsbt
  Future<List<String>> _buildPrivateDescriptors(
    MultisigGroup group,
    MultisigKey thisKey,
    String thisXprv,
    String thisFingerprint,
  ) async {
    final originPath = thisKey.derivationPath.startsWith('m/') 
        ? thisKey.derivationPath.substring(2) 
        : thisKey.derivationPath;
    
    // Build multisig descriptors with this participant's private key
    final receiveDesc = await _buildMultisigDescriptorWithPrivateKey(
      group, thisKey, thisXprv, thisFingerprint, originPath, false, // external
    );
    
    final changeDesc = await _buildMultisigDescriptorWithPrivateKey(
      group, thisKey, thisXprv, thisFingerprint, originPath, true, // internal
    );
    
    await _logToFile('Built multisig descriptors with private key for ${thisKey.owner}');
    await _logToFile('  Receive: ${receiveDesc.substring(0, 60)}...');
    await _logToFile('  Change: ${changeDesc.substring(0, 60)}...');
    
    return [receiveDesc, changeDesc];
  }
  
  /// Build multisig descriptor with private key for this participant
  Future<String> _buildMultisigDescriptorWithPrivateKey(
    MultisigGroup group,
    MultisigKey thisKey,
    String thisXprv,
    String thisFingerprint,
    String thisOriginPath,
    bool isInternal,
  ) async {
    final chain = isInternal ? '1' : '0';
    final keys = <String>[];
    
    await _logToFile('Building descriptor for ${thisKey.owner}:');
    await _logToFile('  Private key: ${thisXprv.substring(0, 20)}...');
    await _logToFile('  Fingerprint: $thisFingerprint');
    await _logToFile('  Origin path: $thisOriginPath');
    await _logToFile('  Chain: $chain (${isInternal ? "internal" : "external"})');
    
    // Add all keys to the multisig
    for (final key in group.keys) {
      final keyOriginPath = key.derivationPath.startsWith('m/') 
          ? key.derivationPath.substring(2) 
          : key.derivationPath;
      
      if (key == thisKey) {
        // Use private key for this participant
        final keyDesc = '[$thisFingerprint/$thisOriginPath]$thisXprv/$chain/*';
        keys.add(keyDesc);
        await _logToFile('  Added THIS key (private): ${keyDesc.substring(0, 60)}...');
      } else {
        // Use public key for other participants
        final keyDesc = '[${key.fingerprint}/$keyOriginPath]${key.xpub}/$chain/*';
        keys.add(keyDesc);
        await _logToFile('  Added OTHER key (public): ${keyDesc.substring(0, 60)}...');
      }
    }
    
    // Sort keys for BIP 67 compliance (sortedmulti)
    keys.sort();
    await _logToFile('  Keys after sorting: ${keys.length} keys');
    
    // Build the descriptor (no checksum needed for descriptorprocesspsbt)
    final descriptor = 'wsh(sortedmulti(${group.m},${keys.join(',')}))';
    await _logToFile('  Final descriptor: ${descriptor.substring(0, 80)}...');
    
    return descriptor;
  }
  
  
  /// Check if PSBT has enough signatures
  Future<bool> _checkPsbtComplete(String psbt, int requiredSigs) async {
    try {
      final analysis = await _rpc.callRAW('analyzepsbt', [psbt]);
      
      if (analysis is Map) {
        final next = analysis['next'] as String?;
        final isComplete = next == 'finalizer' || next == 'extractor';
        
        await _logToFile('\nPSBT Analysis:');
        await _logToFile('  Next step: $next');
        await _logToFile('  Complete: $isComplete');
        
        // Check each input
        final inputs = analysis['inputs'] as List? ?? [];
        bool allInputsReady = true;
        
        for (int i = 0; i < inputs.length; i++) {
          final input = inputs[i] as Map?;
          if (input != null) {
            final sigs = (input['partial_signatures'] as Map?)?.length ?? 0;
            final hasUtxo = input['has_utxo'] as bool? ?? false;
            final isFinal = input['is_final'] as bool? ?? false;
            
            await _logToFile('  Input $i: signatures=$sigs/$requiredSigs, has_utxo=$hasUtxo, final=$isFinal');
            
            if (sigs < requiredSigs) {
              allInputsReady = false;
            }
          }
        }
        
        return isComplete && allInputsReady;
      }
      
      return false;
    } catch (e) {
      await _logToFile('Error analyzing PSBT: $e');
      return false;
    }
  }
}

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

class WalletRPCManager {
  static final WalletRPCManager _instance = WalletRPCManager._internal();
  factory WalletRPCManager() => _instance;
  WalletRPCManager._internal();

  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();
  String? _currentlyLoadedWallet;
  final Map<String, Completer<void>> _loadingOperations = {};

  /// Execute wallet-specific operations on an existing wallet
  Future<T> withWallet<T>(
    String walletName,
    Future<T> Function() operation,
  ) async {
    // Load wallet if not already loaded
    if (!await isWalletLoaded(walletName)) {
      try {
        await loadWallet(walletName);
      } catch (e) {
        throw Exception('Wallet $walletName does not exist and could not be loaded: $e');
      }
    }

    // Execute the operation using wallet-specific endpoint
    return await operation();
  }

  /// Load a specific wallet
  Future<void> loadWallet(String walletName) async {
    try {
      // Check if wallet is already loaded
      final loadedWallets = await _rpc.callRAW('listwallets', []);
      if (loadedWallets is List && loadedWallets.contains(walletName)) {
        await _logToFile('Wallet $walletName is already loaded');
        return;
      }

      await _logToFile('Loading wallet: $walletName');
      await _rpc.callRAW('loadwallet', [walletName]);
      await _logToFile('Successfully loaded wallet: $walletName');
    } catch (e) {
      if (e.toString().contains('already loaded')) {
        await _logToFile('Wallet $walletName is already loaded (caught error)');
        return;
      }
      await _logToFile('Failed to load wallet $walletName: $e');
      rethrow;
    }
  }

  /// Unload a specific wallet
  Future<void> unloadWallet(String walletName) async {
    try {
      await _logToFile('Unloading wallet: $walletName');
      await _rpc.callRAW('unloadwallet', [walletName]);
      await _logToFile('Successfully unloaded wallet: $walletName');
    } catch (e) {
      if (e.toString().contains('not found') || 
          e.toString().contains('not loaded')) {
        await _logToFile('Wallet $walletName was not loaded (ignoring error)');
        return;
      }
      await _logToFile('Failed to unload wallet $walletName: $e');
      // Don't rethrow - we want to continue even if unloading fails
    }
  }

  /// Make a wallet-specific RPC call
  Future<T> callWalletRPC<T>(String walletName, String method, List<dynamic> params) async {
    final rpcLive = _rpc as MainchainRPCLive;
    final conf = rpcLive.conf;
    
    final dio = Dio();
    dio.options.baseUrl = 'http://${conf.host}:${conf.port}';
    dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Basic auth
    final auth = 'Basic ${base64Encode(utf8.encode('${conf.username}:${conf.password}'))}';
    dio.options.headers['Authorization'] = auth;

    // Build JSON-RPC payload
    final payload = {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      final response = await dio.post(
        '/wallet/$walletName', 
        data: payload,
      );
      
      await _logToFile('Wallet RPC URL: ${response.requestOptions.uri}');
      
      final data = response.data;
      if (data['error'] != null) {
        final error = data['error'];
        throw Exception('RPC Error ${error['code']}: ${error['message']}');
      }
      return data['result'] as T;
    } catch (e) {
      await _logToFile('Wallet RPC failed for $walletName.$method: $e');
      rethrow;
    }
  }

  /// Get wallet balance
  Future<double> getWalletBalance(String walletName, {
    int minConf = 0,
    bool includeWatchOnly = true,
  }) async {
    return await withWallet<double>(walletName, () async {
      final result = await callWalletRPC<dynamic>(walletName, 'getbalance', [null, minConf, includeWatchOnly]);
      return result is num ? result.toDouble() : 0.0;
    });
  }

  /// Get wallet info
  Future<Map<String, dynamic>> getWalletInfo(String walletName) async {
    return await withWallet<Map<String, dynamic>>(walletName, () async {
      return await callWalletRPC<Map<String, dynamic>>(walletName, 'getwalletinfo', []);
    });
  }

  /// List unspent outputs
  Future<List<dynamic>> listUnspent(String walletName, {
    int minConf = 0,
    int maxConf = 9999999,
  }) async {
    return await withWallet<List<dynamic>>(walletName, () async {
      return await callWalletRPC<List<dynamic>>(walletName, 'listunspent', [minConf, maxConf]);
    });
  }

  /// Get new address
  Future<String> getNewAddress(String walletName, {String? label, String? addressType}) async {
    return await withWallet<String>(walletName, () async {
      final params = <dynamic>[];
      if (label != null) params.add(label);
      if (addressType != null) params.add(addressType);
      
      return await callWalletRPC<String>(walletName, 'getnewaddress', params);
    });
  }

  /// Import descriptors
  Future<List<dynamic>> importDescriptors(String walletName, List<Map<String, dynamic>> descriptors) async {
    return await withWallet<List<dynamic>>(walletName, () async {
      return await callWalletRPC<List<dynamic>>(walletName, 'importdescriptors', [descriptors]);
    });
  }

  /// Create wallet
  Future<Map<String, dynamic>> createWallet(
    String walletName, {
    bool disablePrivateKeys = false,
    bool blank = false,
    String? passphrase,
    bool avoidReuse = false,
    bool descriptors = true,
    bool loadOnStartup = false,
  }) async {
    final params = <dynamic>[
      walletName,
      disablePrivateKeys,
      blank,
      passphrase ?? '',
      avoidReuse,
      descriptors,
      loadOnStartup,
    ];

    return await _rpc.callRAW('createwallet', params) as Map<String, dynamic>;
  }

  /// Import wallet from file
  Future<void> importWallet(String walletName, String filename) async {
    await withWallet<void>(walletName, () async {
      await callWalletRPC<dynamic>(walletName, 'importwallet', [filename]);
    });
  }

  /// Unload all wallets (cleanup method)
  Future<void> unloadAllWallets() async {
    try {
      final loadedWallets = await _rpc.callRAW('listwallets', []);
      if (loadedWallets is List) {
        for (final walletName in loadedWallets) {
          if (walletName is String) {
            await unloadWallet(walletName);
          }
        }
      }
      _currentlyLoadedWallet = null;
    } catch (e) {
      await _logToFile('Failed to unload all wallets: $e');
    }
  }

  /// Get currently loaded wallet name
  String? get currentWallet => _currentlyLoadedWallet;

  /// Check if a wallet is loaded
  Future<bool> isWalletLoaded(String walletName) async {
    try {
      final loadedWallets = await _rpc.callRAW('listwallets', []);
      return loadedWallets is List && loadedWallets.contains(walletName);
    } catch (e) {
      return false;
    }
  }

  /// Check if an address belongs to a wallet
  Future<bool> isAddressMine(String walletName, String address) async {
    return await withWallet<bool>(walletName, () async {
      try {
        final result = await callWalletRPC<Map<String, dynamic>>(
          walletName,
          'getaddressinfo',
          [address],
        );
        return result['ismine'] == true || result['iswatchonly'] == true;
      } catch (e) {
        await _logToFile('Failed to check address ownership: $e');
        return false;
      }
    });
  }

  /// Rescan wallet from a specific block height or timestamp
  Future<void> rescanWallet(String walletName, {int? startHeight, int? startTime}) async {
    return await withWallet<void>(walletName, () async {
      await _logToFile('Starting rescan for wallet: $walletName');
      
      // Use rescanblockchain to rescan from a specific point
      if (startHeight != null) {
        await _logToFile('Rescanning from block height: $startHeight');
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startHeight]);
      } else if (startTime != null) {
        await _logToFile('Rescanning from timestamp: $startTime');
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startTime]);
      } else {
        // Rescan from the beginning (genesis block)
        await _logToFile('Rescanning entire blockchain');
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', []);
      }
      await _logToFile('Wallet $walletName rescanned successfully');
    });
  }

  /// Force rescan of recent blocks for a wallet (useful when UTXOs are missing)
  Future<void> rescanRecentBlocks(String walletName, {int hoursBack = 24}) async {
    return await withWallet<void>(walletName, () async {
      // Get current block height
      final blockchainInfo = await _rpc.callRAW('getblockchaininfo', []);
      
      if (blockchainInfo is! Map || blockchainInfo['blocks'] is! int) {
        throw Exception('getblockchaininfo returned invalid response: $blockchainInfo');
      }
      
      final currentHeight = blockchainInfo['blocks'] as int;
      
      // Calculate start height (approximately 6 blocks per hour)
      final blocksBack = hoursBack * 6;
      final startHeight = (currentHeight - blocksBack).clamp(0, currentHeight);
      
      await _logToFile('Rescanning wallet $walletName from height $startHeight to $currentHeight (last $hoursBack hours)');
      await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startHeight]);
      await _logToFile('Recent rescan completed for wallet $walletName');
    });
  }

  /// Get wallet balance, UTXO count, and detailed UTXO information
  Future<Map<String, dynamic>> getWalletBalanceAndUtxos(String walletName) async {
    return await withWallet<Map<String, dynamic>>(walletName, () async {
      await _logToFile('Fetching balance and UTXOs for wallet: $walletName');
      
      // First, check if wallet is properly loaded by getting wallet info
      final walletInfo = await callWalletRPC<Map<String, dynamic>>(walletName, 'getwalletinfo', []);
      await _logToFile('Wallet $walletName info: scanning=${walletInfo['scanning']}, txcount=${walletInfo['txcount']}');
      
      // Get detailed balance info
      final balances = await callWalletRPC<Map<String, dynamic>>(walletName, 'getbalances', []);
      await _logToFile('Wallet $walletName detailed balances: $balances');
      
      final balance = await callWalletRPC<dynamic>(walletName, 'getbalance', [null, 0, true]);
      final utxos = await callWalletRPC<List<dynamic>>(walletName, 'listunspent', [0, 9999999, null, true]);
      
      await _logToFile('Wallet $walletName balance: $balance, UTXOs: ${utxos.length}');
      
      // List all descriptors to verify they're imported
      try {
        final descriptors = await callWalletRPC<Map<String, dynamic>>(walletName, 'listdescriptors', []);
        await _logToFile('Wallet $walletName has ${descriptors['descriptors']?.length ?? 0} descriptors');
      } catch (e) {
        await _logToFile('Failed to list descriptors: $e');
      }
      
      // Fail fast if balance is not a number
      if (balance is! num) {
        throw Exception('getbalance returned invalid type: ${balance.runtimeType} for wallet $walletName');
      }
      
      return {
        'balance': balance.toDouble(),
        'utxos': utxos.length,
        'utxo_details': utxos.cast<Map<String, dynamic>>(),
      };
    });
  }
}