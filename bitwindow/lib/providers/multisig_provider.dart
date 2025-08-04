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
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

// Centralized logging utility for multisig operations
class MultisigLogger {
  static final Logger _logger = GetIt.I.get<Logger>();
  
  static void info(String message) {
    _logger.i('[MULTISIG] $message');
  }
  
  static void error(String message) {
    _logger.e('[MULTISIG] $message');
  }
  
  static void debug(String message) {
    _logger.d('[MULTISIG] $message');
  }
}

/// Centralized descriptor building utility for multisig operations
/// This ensures consistent descriptor format across all multisig functionality
class MultisigDescriptorBuilder {
  static final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();
  
  /// Build a watch-only multisig descriptor (for wallet creation and funding)
  static Future<MultisigDescriptors> buildWatchOnlyDescriptors(MultisigGroup group) async {
    final sortedKeys = _sortKeysByBIP67(group.keys);
    
    final keyDescriptors = sortedKeys.map((key) {
      if (key.isWallet && key.fingerprint != null && key.originPath != null) {
        return '[${key.fingerprint}/${key.originPath}]${key.xpub}';
      } else {
        return key.xpub;
      }
    }).join(',');
    
    final receiveDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/0/*))';
    final changeDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/1/*))';
    
    // Add checksums using Bitcoin Core
    final receiveWithChecksum = await _addChecksum(receiveDesc);
    final changeWithChecksum = await _addChecksum(changeDesc);
    
    return MultisigDescriptors(
      receive: receiveWithChecksum,
      change: changeWithChecksum,
    );
  }
  
  /// Build a signing descriptor with private keys (for PSBT signing)
  static Future<List<String>> buildSigningDescriptors(
    MultisigGroup group,
    MultisigKey signingKey,
    String privateKeyXprv,
    String fingerprint,
  ) async {
    final sortedKeys = _sortKeysByBIP67(group.keys);
    final originPath = signingKey.derivationPath.startsWith('m/') 
        ? signingKey.derivationPath.substring(2) 
        : signingKey.derivationPath;
    
    final receiveKeys = <String>[];
    final changeKeys = <String>[];
    
    for (final key in sortedKeys) {
      final keyOriginPath = key.derivationPath.startsWith('m/') 
          ? key.derivationPath.substring(2) 
          : key.derivationPath;
      
      if (key == signingKey) {
        // Use private key for this participant
        receiveKeys.add('[$fingerprint/$originPath]$privateKeyXprv/0/*');
        changeKeys.add('[$fingerprint/$originPath]$privateKeyXprv/1/*');
      } else {
        // Use public key for other participants
        final keyDesc = key.fingerprint != null && key.originPath != null
            ? '[${key.fingerprint}/${key.originPath}]${key.xpub}'
            : key.xpub;
        receiveKeys.add('$keyDesc/0/*');
        changeKeys.add('$keyDesc/1/*');
      }
    }
    
    // Build descriptors (no checksum needed for descriptorprocesspsbt)
    final receiveDesc = 'wsh(sortedmulti(${group.m},${receiveKeys.join(',')}))';
    final changeDesc = 'wsh(sortedmulti(${group.m},${changeKeys.join(',')}))';
    
    return [receiveDesc, changeDesc];
  }
  
  /// Sort keys by BIP67 order (lexicographic order of xpubs)
  static List<MultisigKey> _sortKeysByBIP67(List<MultisigKey> keys) {
    final sortedKeys = List<MultisigKey>.from(keys);
    sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
    return sortedKeys;
  }
  
  /// Add checksum to descriptor using Bitcoin Core's getdescriptorinfo
  static Future<String> _addChecksum(String descriptor) async {
    try {
      if (descriptor.contains('#')) {
        return descriptor; // Already has checksum
      }
      
      final result = await _rpc.callRAW('getdescriptorinfo', [descriptor]);
      
      if (result is Map && result['descriptor'] != null) {
        return result['descriptor'] as String;
      }
      
      throw Exception('Bitcoin Core getdescriptorinfo returned invalid response: $result');
    } catch (e) {
      MultisigLogger.error('Failed to add checksum to descriptor: $e');
      throw Exception('Failed to add checksum to descriptor: $e');
    }
  }
}

/// Container for multisig descriptors
class MultisigDescriptors {
  final String receive;
  final String change;
  
  const MultisigDescriptors({
    required this.receive,
    required this.change,
  });
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
    MultisigLogger.info('Signing PSBT for group ${group.name} (${group.m}-of-${group.n}) with ${walletKeys.length} wallet keys');
    
    final errors = <String>[];
    
    try {
      // Validate we have the required descriptors
      if (group.descriptorReceive == null || group.descriptorChange == null) {
        throw Exception('Group missing descriptors - cannot sign');
      }
      
      
      // Sign with each participant wallet
      final participantPSBTs = <String>[];
      int totalSignaturesAdded = 0;
      
      for (int i = 0; i < walletKeys.length; i++) {
        final walletKey = walletKeys[i];
        
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
          }
          
        } catch (e) {
          final error = 'Failed to sign with ${walletKey.owner}: $e';
          errors.add(error);
          MultisigLogger.error(error);
          // Continue with other participants
        }
      }
      
      if (participantPSBTs.isEmpty) {
        throw Exception('No participants could sign the PSBT');
      }
      
      // Combine PSBTs if multiple participants signed
      String finalPsbt;
      if (participantPSBTs.length > 1) {
        finalPsbt = await _rpc.callRAW('combinepsbt', [participantPSBTs]) as String;
      } else {
        finalPsbt = participantPSBTs[0];
      }
      
      // Check if complete
      final isComplete = await _checkPsbtComplete(finalPsbt, group.m);
      
      
      MultisigLogger.info('PSBT signing complete: ${participantPSBTs.length}/${walletKeys.length} participants signed, $totalSignaturesAdded signatures added, transaction complete: $isComplete');
      
      // Only return success if we actually added signatures
      if (totalSignaturesAdded == 0 && participantPSBTs.isNotEmpty) {
        errors.add('No signatures were added despite successful processing');
        MultisigLogger.error('Signing completed but no signatures were added');
      }
      
      return SigningResult(
        signedPsbt: finalPsbt,
        isComplete: isComplete,
        signaturesAdded: totalSignaturesAdded,
        errors: errors,
      );
      
    } catch (e) {
      MultisigLogger.error('PSBT signing failed: $e');
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
      final keyInfo = await _hdWallet.deriveExtendedKeyInfo(mnemonic, walletKey.derivationPath, isMainnet);
      final xprv = keyInfo['xprv'];
      final fingerprint = keyInfo['fingerprint'];
      
      if (xprv == null || xprv.isEmpty) {
        throw Exception('Failed to derive extended private key for ${walletKey.owner}');
      }
      
      
      // Step 2: Build descriptors with private keys for this participant
      final descriptors = await MultisigDescriptorBuilder.buildSigningDescriptors(
        group, walletKey, xprv, fingerprint!,
      );
      
      
      // Step 3: Use descriptorprocesspsbt to sign directly
      
      final result = await _rpc.callRAW('descriptorprocesspsbt', [
        psbtBase64,
        descriptors,
        'ALL', // sighashtype
        true,  // bip32derivs
        false, // finalize
      ]);
      
      
      if (result is Map) {
        final signedPsbt = result['psbt'] as String;
        final isComplete = result['complete'] as bool? ?? false;
        
        // Count signatures added
        final signaturesAdded = await _countNewSignatures(psbtBase64, signedPsbt);
        
        
        return SigningResult(
          signedPsbt: signedPsbt,
          isComplete: isComplete,
          signaturesAdded: signaturesAdded,
          errors: [],
        );
      }
      
      throw Exception('Invalid response from descriptorprocesspsbt');
      
    } catch (e) {
      rethrow;
    }
  }
  
  
  
  /// Count new signatures added to PSBT
  Future<int> _countNewSignatures(String psbtBefore, String psbtAfter) async {
    try {
      // If PSBTs are different, assume signatures were added
      if (psbtBefore != psbtAfter) {
        return 1;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  
  
  /// Check if PSBT has enough signatures
  Future<bool> _checkPsbtComplete(String psbt, int requiredSigs) async {
    try {
      final analysis = await _rpc.callRAW('analyzepsbt', [psbt]);
      
      if (analysis is Map) {
        final next = analysis['next'] as String?;
        final isComplete = next == 'finalizer' || next == 'extractor';
        
        // Check each input
        final inputs = analysis['inputs'] as List? ?? [];
        bool allInputsReady = true;
        
        for (int i = 0; i < inputs.length; i++) {
          final input = inputs[i] as Map?;
          if (input != null) {
            final sigs = (input['partial_signatures'] as Map?)?.length ?? 0;
            
            if (sigs < requiredSigs) {
              allInputsReady = false;
            }
          }
        }
        
        return isComplete && allInputsReady;
      }
      
      return false;
    } catch (e) {
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
        return;
      }

      await _rpc.callRAW('loadwallet', [walletName]);
    } catch (e) {
      if (e.toString().contains('already loaded')) {
        return;
      }
      MultisigLogger.error('Failed to load wallet $walletName: $e');
      rethrow;
    }
  }

  /// Unload a specific wallet
  Future<void> unloadWallet(String walletName) async {
    try {
      await _rpc.callRAW('unloadwallet', [walletName]);
    } catch (e) {
      if (e.toString().contains('not found') || 
          e.toString().contains('not loaded')) {
        return;
      }
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
      
      
      final data = response.data;
      if (data['error'] != null) {
        final error = data['error'];
        throw Exception('RPC Error ${error['code']}: ${error['message']}');
      }
      return data['result'] as T;
    } catch (e) {
      MultisigLogger.error('Wallet RPC failed for $walletName.$method: $e');
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
      MultisigLogger.error('Failed to unload all wallets: $e');
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
        return false;
      }
    });
  }

  /// Rescan wallet from a specific block height or timestamp
  Future<void> rescanWallet(String walletName, {int? startHeight, int? startTime}) async {
    return await withWallet<void>(walletName, () async {
      MultisigLogger.info('Starting rescan for wallet: $walletName');
      
      // Use rescanblockchain to rescan from a specific point
      if (startHeight != null) {
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startHeight]);
      } else if (startTime != null) {
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startTime]);
      } else {
        // Rescan from the beginning (genesis block)
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', []);
      }
      MultisigLogger.info('Wallet $walletName rescanned successfully');
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
      
      await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startHeight]);
      MultisigLogger.info('Recent rescan completed for wallet $walletName');
    });
  }

  /// Get wallet balance, UTXO count, and detailed UTXO information
  Future<Map<String, dynamic>> getWalletBalanceAndUtxos(String walletName) async {
    return await withWallet<Map<String, dynamic>>(walletName, () async {
      
      // First, check if wallet is properly loaded by getting wallet info
      final walletInfo = await callWalletRPC<Map<String, dynamic>>(walletName, 'getwalletinfo', []);
      
      // Get detailed balance info
      final balances = await callWalletRPC<Map<String, dynamic>>(walletName, 'getbalances', []);
      
      final balance = await callWalletRPC<dynamic>(walletName, 'getbalance', [null, 0, true]);
      final utxos = await callWalletRPC<List<dynamic>>(walletName, 'listunspent', [0, 9999999, null, true]);
      
      
      // List all descriptors to verify they're imported
      try {
        final descriptors = await callWalletRPC<Map<String, dynamic>>(walletName, 'listdescriptors', []);
      } catch (e) {
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

/// Service for managing multisig group storage
class MultisigStorage {
  static const String _fileName = 'multisig.json';

  /// Get the path to the multisig.json file
  static Future<String> _getGroupsFilePath() async {
    final appDir = await Environment.datadir();
    final bitdriveDir = Directory(path.join(appDir.path, 'bitdrive'));
    return path.join(bitdriveDir.path, _fileName);
  }

  /// Load all groups from multisig.json
  static Future<List<MultisigGroup>> loadGroups() async {
    try {
      final filePath = await _getGroupsFilePath();
      final file = File(filePath);
      
      if (!await file.exists()) {
        // Return empty list if file doesn't exist yet
        return [];
      }
      
      final content = await file.readAsString();
      final jsonList = json.decode(content) as List<dynamic>;
      
      return jsonList
          .map((json) => MultisigGroup.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load groups: $e');
    }
  }

  /// Save all groups to multisig.json
  static Future<void> saveGroups(List<MultisigGroup> groups) async {
    try {
      final filePath = await _getGroupsFilePath();
      final file = File(filePath);
      
      // Ensure directory exists
      await file.parent.create(recursive: true);
      
      final jsonList = groups.map((group) => group.toJson()).toList();
      final content = json.encode(jsonList);
      
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Failed to save groups: $e');
    }
  }

  /// Save a single group to multisig.json
  static Future<void> saveGroup(MultisigGroup group) async {
    final groups = await loadGroups();
    
    // Find existing group with same ID
    final existingIndex = groups.indexWhere((g) => g.id == group.id);
    
    if (existingIndex != -1) {
      // Update existing group
      groups[existingIndex] = group;
    } else {
      // Add new group
      groups.add(group);
    }
    
    await saveGroups(groups);
  }

  /// Get a specific group by ID
  static Future<MultisigGroup?> getGroup(String groupId) async {
    final groups = await loadGroups();
    try {
      return groups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return null;
    }
  }

  /// Delete a group by ID
  static Future<void> deleteGroup(String groupId) async {
    final groups = await loadGroups();
    groups.removeWhere((group) => group.id == groupId);
    await saveGroups(groups);
  }

  /// Update group balance and UTXO count
  static Future<void> updateGroupBalance(String groupId, double balance, int utxoCount) async {
    final groups = await loadGroups();
    final groupIndex = groups.indexWhere((g) => g.id == groupId);
    
    if (groupIndex != -1) {
      // Create updated group with new balance and utxo count
      final group = groups[groupIndex];
      final updatedGroup = MultisigGroup(
        id: group.id,
        name: group.name,
        n: group.n,
        m: group.m,
        keys: group.keys,
        created: group.created,
        descriptorReceive: group.descriptorReceive,
        descriptorChange: group.descriptorChange,
        watchWalletName: group.watchWalletName,
        txid: group.txid,
        addresses: group.addresses,
        nextReceiveIndex: group.nextReceiveIndex,
        balance: balance,
        utxos: utxoCount,
        utxoDetails: group.utxoDetails,
      );
      
      groups[groupIndex] = updatedGroup;
      await saveGroups(groups);
    }
  }
}