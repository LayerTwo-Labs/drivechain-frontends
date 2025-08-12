import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

class FileOperationLock {
  static final Map<String, Completer<void>> _locks = {};
  
  static Future<T> withLock<T>(String lockKey, Future<T> Function() operation) async {
    while (_locks.containsKey(lockKey)) {
      await _locks[lockKey]!.future;
    }
    
    final completer = Completer<void>();
    _locks[lockKey] = completer;
    
    try {
      return await operation();
    } finally {
      _locks.remove(lockKey);
      completer.complete();
    }
  }
}

class TransactionStatusManager {
  static Future<void> updateTransactionStatus({
    required String transactionId,
    required TxStatus newStatus,
    String? txid,
    DateTime? broadcastTime,
    int? confirmations,
    String? combinedPSBT,
    String? finalHex,
    String? reason,
  }) async {
    final transaction = await TransactionStorage.getTransaction(transactionId);
    
    if (transaction == null) {
      throw Exception('Transaction not found: $transactionId');
    }
    
    if (!_isValidStatusTransition(transaction.status, newStatus)) {
      throw Exception('Invalid status transition from ${transaction.status} to $newStatus');
    }
    
    final updatedTransaction = transaction.copyWith(
      status: newStatus,
      txid: txid ?? transaction.txid,
      broadcastTime: broadcastTime ?? transaction.broadcastTime,
      confirmations: confirmations ?? transaction.confirmations,
      combinedPSBT: combinedPSBT ?? transaction.combinedPSBT,
      finalHex: finalHex ?? transaction.finalHex,
    );
    
    await TransactionStorage.saveTransaction(updatedTransaction);
  }
  
  static bool _isValidStatusTransition(TxStatus from, TxStatus to) {
    if (from == to) return true;
    
    const validTransitions = {
      TxStatus.needsSignatures: [TxStatus.awaitingSignedPSBTs, TxStatus.readyForBroadcast, TxStatus.voided],
      TxStatus.awaitingSignedPSBTs: [TxStatus.readyForBroadcast, TxStatus.voided],
      TxStatus.readyForBroadcast: [TxStatus.broadcasted, TxStatus.voided],
      TxStatus.broadcasted: [TxStatus.confirmed, TxStatus.voided],
      TxStatus.confirmed: [TxStatus.completed],
    };
    return validTransitions[from]?.contains(to) ?? false;
  }
  
}

class PSBTValidationResult {
  final bool isValid;
  final bool isSigned;
  final bool isComplete;
  final int signatureCount;
  final List<String> errors;

  PSBTValidationResult({
    required this.isValid,
    required this.isSigned,
    required this.isComplete,
    required this.signatureCount,
    required this.errors,
  });
}

class PSBTValidator {
  static final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();

  static Future<PSBTValidationResult> validatePSBT({
    required String psbtBase64,
    required MultisigGroup group,
    required String keyId,
  }) async {
    try {
      final cleanPsbt = psbtBase64.replaceAll(RegExp(r'\s'), '');

      final analyzePsbt = await _rpc.callRAW('analyzepsbt', [cleanPsbt]);

      if (analyzePsbt is! Map) {
        throw Exception('Invalid PSBT format');
      }

      bool isActuallySigned = false;
      bool isComplete = false;

      final inputs = analyzePsbt['inputs'] as List<dynamic>? ?? [];
      for (final input in inputs) {
        if (input is Map<String, dynamic>) {
          final isInputFinal = input['is_final'] as bool? ?? false;
          final missing = input['missing'] as Map<String, dynamic>?;
          final missingSignatures = missing?['signatures'] as List<dynamic>? ?? [];

          final totalMissing = missingSignatures.length;
          final totalKeys = group.n; // Total number of keys in the multisig

          final hasSomeSignatures = totalMissing < totalKeys;

          if (isInputFinal || hasSomeSignatures) {
            isActuallySigned = true;
            break;
          }
        }
      }

      final nextRole = analyzePsbt['next'] as String?;
      isComplete = (nextRole == 'extractor' || nextRole == null);

      return PSBTValidationResult(
        isValid: true,
        isSigned: isActuallySigned,
        isComplete: isComplete,
        signatureCount: _calculateSignatureCount(analyzePsbt as Map<String, dynamic>, group.n),
        errors: [],
      );

    } catch (e) {
      return PSBTValidationResult(
        isValid: false,
        isSigned: false,
        isComplete: false,
        signatureCount: 0,
        errors: [e.toString()],
      );
    }
  }

  static int _calculateSignatureCount(Map<String, dynamic> analyzePsbt, int totalKeys) {
    final inputs = analyzePsbt['inputs'] as List<dynamic>? ?? [];
    int totalSigs = 0;

    for (final input in inputs) {
      if (input is Map<String, dynamic>) {
        final missing = input['missing'] as Map<String, dynamic>?;
        final missingSignatures = missing?['signatures'] as List<dynamic>? ?? [];
        final currentSigs = totalKeys - missingSignatures.length;
        totalSigs += currentSigs > 0 ? currentSigs : 0;
      }
    }

    return totalSigs;
  }

  static Future<bool> isComplete(String psbtBase64, int requiredSigs) async {
    try {
      final analysis = await _rpc.callRAW('analyzepsbt', [psbtBase64]);
      
      if (analysis is Map) {
        final next = analysis['next'] as String?;
        final isComplete = next == 'finalizer' || next == 'extractor';
        
        final inputs = analysis['inputs'] as List? ?? [];
        bool allInputsReady = true;
        
        for (final input in inputs) {
          if (input is Map) {
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

  static Future<int> countSignatureDifference(String psbtBefore, String psbtAfter) async {
    try {
      if (psbtBefore == psbtAfter) {
        return 0;
      }
      
      final beforeAnalysis = await _rpc.callRAW('analyzepsbt', [psbtBefore]);
      final afterAnalysis = await _rpc.callRAW('analyzepsbt', [psbtAfter]);
      
      if (beforeAnalysis is Map && afterAnalysis is Map) {
        final beforeInputs = beforeAnalysis['inputs'] as List? ?? [];
        final afterInputs = afterAnalysis['inputs'] as List? ?? [];
        
        int signaturesAdded = 0;
        for (int i = 0; i < beforeInputs.length && i < afterInputs.length; i++) {
          final beforeSigs = (beforeInputs[i]['partial_signatures'] as Map?)?.length ?? 0;
          final afterSigs = (afterInputs[i]['partial_signatures'] as Map?)?.length ?? 0;
          signaturesAdded += afterSigs - beforeSigs;
        }
        
        return signaturesAdded > 0 ? signaturesAdded : 1;
      }
      
      return 1;
    } catch (e) {
      return psbtBefore != psbtAfter ? 1 : 0;
    }
  }
}

class BalanceManager {
  static Future<void> updateGroupBalance(MultisigGroup group) async {
    final lockKey = 'balance_${group.id}';
    
    return await FileOperationLock.withLock(lockKey, () async {
      final walletManager = WalletRPCManager();
      final walletName = group.watchWalletName ?? 'multisig_${group.id}';
      final logger = GetIt.I.get<Logger>();
      
      try {
        await walletManager.getWalletInfo(walletName);
      } catch (e) {
        await _createWatchOnlyWallet(group, walletManager);
      }
      
      final balance = await walletManager.getWalletBalance(walletName);
      final utxos = await walletManager.listUnspent(walletName);
      final utxoCount = utxos.length;
      
      await MultisigStorage.updateGroupBalance(group.id, balance, utxoCount);
      
      // Check for new transactions when balance updates
      try {
        logger.d('Checking for new transactions in wallet: $walletName');
        final transactions = await walletManager.callWalletRPC<List<dynamic>>(
          walletName,
          'listtransactions',
          ['*', 100, 0, true], // Get last 100 transactions
        );
        
        final rpc = GetIt.I.get<MainchainRPC>();
        int newTxCount = 0;
        
        for (final walletTx in transactions) {
          if (walletTx is Map<String, dynamic>) {
            final txid = walletTx['txid'] as String?;
            if (txid != null) {
              // Check if transaction already exists
              final existingTx = await TransactionStorage.getTransaction(txid);
              if (existingTx == null) {
                // Process new transaction
                logger.i('Found new transaction: $txid');
                await MultisigStorage._processHistoricalTransaction(group, walletTx, rpc);
                newTxCount++;
              }
            }
          }
        }
        
        if (newTxCount > 0) {
          logger.i('Added $newTxCount new transaction(s) for group: ${group.name}');
          // Notify UI of new transactions
          TransactionStorage.notifier.notifyTransactionChange();
        }
      } catch (e) {
        logger.e('Error checking for new transactions: $e');
      }
    });
  }
  
  static Future<void> updateAllGroupBalances(List<MultisigGroup> groups) async {
    await Future.wait(
      groups.map((group) => updateGroupBalance(group)),
    );
  }
  
  static Future<void> _createWatchOnlyWallet(MultisigGroup group, WalletRPCManager walletManager) async {
    try {
      final walletName = group.watchWalletName ?? 'multisig_${group.id}';
      
      await walletManager.createWallet(
        walletName,
        disablePrivateKeys: true,
        blank: true,
        descriptors: true,
      );
      
      if (group.descriptorReceive != null && group.descriptorChange != null) {
        final descriptors = [
          {
            'desc': group.descriptorReceive!,
            'active': true,
            'internal': false,
            'timestamp': 'now',
          },
          {
            'desc': group.descriptorChange!,
            'active': true,
            'internal': true,
            'timestamp': 'now',
          },
        ];
        
        await walletManager.importDescriptors(walletName, descriptors);
      }
      
    } catch (e) {
      rethrow;
    }
  }
}

class MultisigStateManager extends ChangeNotifier {
  static final MultisigStateManager _instance = MultisigStateManager._internal();
  factory MultisigStateManager() => _instance;
  MultisigStateManager._internal();

  List<MultisigGroup> _groups = [];
  List<MultisigTransaction> _transactions = [];
  MultisigGroup? _selectedGroup;
  bool _isLoading = false;
  String? _errorMessage;

  List<MultisigGroup> get groups => List.unmodifiable(_groups);
  List<MultisigTransaction> get transactions => List.unmodifiable(_transactions);
  MultisigGroup? get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MultisigGroup? findGroupById(String groupId) {
    try {
      return _groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  void setSelectedGroup(MultisigGroup? group) {
    _selectedGroup = group;
    notifyListeners();
  }

  Future<void> refreshData() async {
    return await FileOperationLock.withLock('state_refresh', () async {
      _setLoading(true);
      _clearError();

      try {
        _groups = await MultisigStorage.loadGroups();
        _transactions = await TransactionStorage.loadTransactions();
        await BalanceManager.updateAllGroupBalances(_groups);
        _groups = await MultisigStorage.loadGroups();
      } catch (e) {
        _setError(e.toString());
      } finally {
        _setLoading(false);
      }

      notifyListeners();
    });
  }

  Future<void> addGroup(MultisigGroup group) async {
    return await FileOperationLock.withLock('add_group', () async {
      _groups.add(group);
      await MultisigStorage.saveGroups(_groups);
      notifyListeners();
    });
  }

  Future<void> updateGroup(MultisigGroup updatedGroup) async {
    return await FileOperationLock.withLock('update_group', () async {
      final index = _groups.indexWhere((g) => g.id == updatedGroup.id);
      if (index != -1) {
        _groups[index] = updatedGroup;
        await MultisigStorage.saveGroups(_groups);
        notifyListeners();
      }
    });
  }

  Future<void> addTransaction(MultisigTransaction transaction) async {
    return await FileOperationLock.withLock('add_transaction', () async {
      _transactions.add(transaction);
      await TransactionStorage.saveTransactions(_transactions);
      notifyListeners();
    });
  }

  void selectGroup(MultisigGroup? group) {
    _selectedGroup = group;
    notifyListeners();
  }

  void _setLoading(bool loading) => _isLoading = loading;
  void _clearError() => _errorMessage = null;
  void _setError(String error) => _errorMessage = error;
}

class SigningCoordinator extends ChangeNotifier {
  static final SigningCoordinator _instance = SigningCoordinator._internal();
  factory SigningCoordinator() => _instance;
  SigningCoordinator._internal();

  String? _currentlySigningTxId;
  bool _isSigningInProgress = false;

  String? get currentlySigningTxId => _currentlySigningTxId;
  bool get isSigningInProgress => _isSigningInProgress;

  Future<void> signTransaction({
    required String transactionId,
    required MultisigGroup group,
    required Future<void> Function() signFunction,
  }) async {
    if (_isSigningInProgress) {
      throw Exception('Another signing operation is in progress');
    }

    return await FileOperationLock.withLock('signing_$transactionId', () async {
      _isSigningInProgress = true;
      _currentlySigningTxId = transactionId;
      notifyListeners();

      try {
        await signFunction();

        await MultisigStateManager().refreshData();

      } finally {
        _isSigningInProgress = false;
        _currentlySigningTxId = null;
        notifyListeners();
      }
    });
  }
}

class MultisigTransactionNotifier extends ChangeNotifier {
  static final MultisigTransactionNotifier _instance = MultisigTransactionNotifier._internal();
  
  factory MultisigTransactionNotifier() => _instance;
  
  MultisigTransactionNotifier._internal();
  
  void notifyTransactionChange() {
    notifyListeners();
  }
}

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

class MultisigDescriptorBuilder {
  static final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();
  
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
    
    final receiveWithChecksum = await _addChecksum(receiveDesc);
    final changeWithChecksum = await _addChecksum(changeDesc);
    
    return MultisigDescriptors(
      receive: receiveWithChecksum,
      change: changeWithChecksum,
    );
  }
  
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
      if (key == signingKey) {
        receiveKeys.add('[$fingerprint/$originPath]$privateKeyXprv/0/*');
        changeKeys.add('[$fingerprint/$originPath]$privateKeyXprv/1/*');
      } else {
        final keyDesc = key.fingerprint != null && key.originPath != null
            ? '[${key.fingerprint}/${key.originPath}]${key.xpub}'
            : key.xpub;
        receiveKeys.add('$keyDesc/0/*');
        changeKeys.add('$keyDesc/1/*');
      }
    }
    
    final receiveDesc = 'wsh(sortedmulti(${group.m},${receiveKeys.join(',')}))';
    final changeDesc = 'wsh(sortedmulti(${group.m},${changeKeys.join(',')}))';
    
    return [receiveDesc, changeDesc];
  }
  
  static List<MultisigKey> _sortKeysByBIP67(List<MultisigKey> keys) {
    final sortedKeys = List<MultisigKey>.from(keys);
    sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
    return sortedKeys;
  }
  
  static Future<String> _addChecksum(String descriptor) async {
    try {
      if (descriptor.contains('#')) {
        return descriptor;
      }
      
      final result = await _rpc.callRAW('getdescriptorinfo', [descriptor]);
      
      if (result is Map && result['descriptor'] != null) {
        return result['descriptor'] as String;
      }
      
      throw Exception('Bitcoin Core getdescriptorinfo returned invalid response: $result');
    } catch (e) {
      GetIt.I.get<Logger>().e('Failed to add checksum to descriptor: $e');
      throw Exception('Failed to add checksum to descriptor: $e');
    }
  }
}

class MultisigDescriptors {
  final String receive;
  final String change;
  
  const MultisigDescriptors({
    required this.receive,
    required this.change,
  });
}

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

class MultisigRPCSigner {
  final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();
  final HDWalletProvider _hdWallet = GetIt.I.get<HDWalletProvider>();

  Future<SigningResult> signPSBT({
    required String psbtBase64,
    required MultisigGroup group,
    required String mnemonic,
    required List<MultisigKey> walletKeys,
    bool isMainnet = false,
  }) async {
    
    final errors = <String>[];
    
    try {
      if (group.descriptorReceive == null || group.descriptorChange == null) {
        throw Exception('Group missing descriptors - cannot sign');
      }
      
      
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
        }
      }
      
      if (participantPSBTs.isEmpty) {
        throw Exception('No participants could sign the PSBT');
      }
      
      String finalPsbt;
      if (participantPSBTs.length > 1) {
        finalPsbt = await _rpc.callRAW('combinepsbt', [participantPSBTs]) as String;
      } else {
        finalPsbt = participantPSBTs[0];
      }
      
      final isComplete = await PSBTValidator.isComplete(finalPsbt, group.m);
      
      
      
      if (totalSignaturesAdded == 0 && participantPSBTs.isNotEmpty) {
        errors.add('No signatures were added despite successful processing');
      }
      
      if (totalSignaturesAdded == 0 && participantPSBTs.isEmpty) {
        throw Exception('No wallet keys were able to sign this transaction. Check that the keys match the multisig configuration.');
      }
      
      
      return SigningResult(
        signedPsbt: finalPsbt,
        isComplete: isComplete,
        signaturesAdded: totalSignaturesAdded,
        errors: errors,
      );
      
    } catch (e) {
      throw Exception('Multisig PSBT signing failed: $e');
    }
  }
  
  Future<SigningResult?> _signWithParticipant({
    required MultisigKey walletKey,
    required String mnemonic,
    required String psbtBase64,
    required MultisigGroup group,
    required bool isMainnet,
  }) async {
    try {
      final keyInfo = await _hdWallet.deriveExtendedKeyInfo(mnemonic, walletKey.derivationPath, isMainnet);
      final xprv = keyInfo['xprv'];
      final fingerprint = keyInfo['fingerprint'];
      
      if (xprv == null || xprv.isEmpty) {
        throw Exception('Failed to derive extended private key for ${walletKey.owner}');
      }
      
      
      final descriptors = await MultisigDescriptorBuilder.buildSigningDescriptors(
        group, walletKey, xprv, fingerprint!,
      );
      
      
      final result = await _rpc.callRAW('descriptorprocesspsbt', [
        psbtBase64,
        descriptors,
        'ALL',
        true,
        false,
      ]);
      
      if (result is Map) {
        final signedPsbt = result['psbt'] as String;
        final isComplete = result['complete'] as bool? ?? false;
        final signaturesAdded = await PSBTValidator.countSignatureDifference(psbtBase64, signedPsbt);
        
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
  
}

class TransactionStorage {
  static const String _fileName = 'transactions.json';
  static final _notifier = MultisigTransactionNotifier();

  static Future<String> _getTransactionsFilePath() async {
    final appDir = await Environment.datadir();
    final bitdriveDir = Directory(path.join(appDir.path, 'bitdrive'));
    
    if (!await bitdriveDir.exists()) {
      await bitdriveDir.create(recursive: true);
    }
    
    return path.join(bitdriveDir.path, _fileName);
  }

  static Future<List<MultisigTransaction>> loadTransactions() async {
    return await FileOperationLock.withLock('transactions.json', () async {
      try {
        final filePath = await _getTransactionsFilePath();
        final file = File(filePath);
        
        if (!await file.exists()) {
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
    });
  }

  static Future<void> saveTransactions(List<MultisigTransaction> transactions) async {
    return await FileOperationLock.withLock('transactions.json', () async {
      try {
        final filePath = await _getTransactionsFilePath();
        final file = File(filePath);
        
        final jsonList = transactions.map((tx) => tx.toJson()).toList();
        final content = json.encode(jsonList);
        
        await file.writeAsString(content);
        
        _notifier.notifyTransactionChange();
      } catch (e) {
        throw Exception('Failed to save transactions: $e');
      }
    });
  }

  static Future<void> saveTransaction(MultisigTransaction transaction) async {
    final transactions = await loadTransactions();
    
    final existingIndex = transactions.indexWhere((tx) => tx.id == transaction.id);
    
    if (existingIndex != -1) {
      transactions[existingIndex] = transaction;
    } else {
      transactions.add(transaction);
    }
    
    await saveTransactions(transactions);
  }
  
  static MultisigTransactionNotifier get notifier => _notifier;
  
    static Future<String> getTransactionFilePath() => _getTransactionsFilePath();

  static Future<MultisigTransaction?> getTransaction(String transactionId) async {
    final transactions = await loadTransactions();
    try {
      return transactions.firstWhere((tx) => tx.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<MultisigTransaction>> getTransactionsForGroup(String groupId) async {
    final transactions = await loadTransactions();
    return transactions.where((tx) => tx.groupId == groupId).toList();
  }



  static Future<void> updateKeyPSBT(
    String transactionId,
    String keyId,
    String signedPSBT, {
    int? signatureThreshold,
    bool? isOwnedKey,
  }) async {
    final transaction = await getTransaction(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found: $transactionId');
    }

    final groups = await MultisigStorage.loadGroups();
    final group = groups.firstWhere(
      (g) => g.id == transaction.groupId,
      orElse: () => throw Exception('Group not found: ${transaction.groupId}'),
    );

    final validationResult = await PSBTValidator.validatePSBT(
      psbtBase64: signedPSBT,
      group: group,
      keyId: keyId,
    );
    
    final isActuallySigned = validationResult.isSigned;

    final updatedKeyPSBTs = transaction.keyPSBTs.map((keyPSBT) {
      if (keyPSBT.keyId == keyId) {
        return KeyPSBTStatus(
          keyId: keyId,
          psbt: signedPSBT,
          isSigned: isActuallySigned, // Use RPC validation result instead of hardcoded true
          signedAt: isActuallySigned ? DateTime.now() : null,
        );
      }
      return keyPSBT;
    }).toList();

    final signedCount = updatedKeyPSBTs.where((k) => k.isSigned).length;
    final threshold = signatureThreshold ?? transaction.requiredSignatures;
    
    TxStatus newStatus;
    if (signedCount >= threshold) {
      newStatus = TxStatus.readyForBroadcast;
    } else if (isOwnedKey == true && signedCount > 0) {
      newStatus = TxStatus.awaitingSignedPSBTs;
    } else {
      newStatus = TxStatus.needsSignatures;
    }

    final updatedTransaction = transaction.copyWith(
      keyPSBTs: updatedKeyPSBTs,
      status: newStatus,
    );

    await saveTransaction(updatedTransaction);
    
    if (isOwnedKey == true) {
      await _storePSBTInMultisigFile(transactionId, keyId, transaction.initialPSBT, signedPSBT);
    }
  }

  static Future<void> _storePSBTInMultisigFile(
    String transactionId,
    String keyId,
    String initialPSBT,
    String signedPSBT,
  ) async {
    try {
      final groups = await MultisigStorage.loadGroups();
      bool groupUpdated = false;
      
      final updatedGroups = groups.map((group) {
        if (group.transactionIds.contains(transactionId)) {
          final updatedKeys = group.keys.map((key) {
            if (key.xpub == keyId && key.isWallet) {
              final currentActivePSBTs = Map<String, String>.from(key.activePSBTs ?? {});
              final currentInitialPSBTs = Map<String, String>.from(key.initialPSBTs ?? {});
              
              currentActivePSBTs[transactionId] = signedPSBT;
              currentInitialPSBTs[transactionId] = initialPSBT;
              
              groupUpdated = true;
              return key.copyWith(
                activePSBTs: currentActivePSBTs,
                initialPSBTs: currentInitialPSBTs,
              );
            }
            return key;
          }).toList();
          
          if (groupUpdated) {
            return group.copyWith(keys: updatedKeys);
          }
        }
        return group;
      }).toList();
      
      if (groupUpdated) {
        await MultisigStorage.saveGroups(updatedGroups);
      }
    } catch (e) {
      GetIt.I.get<Logger>().e('Failed to store PSBT data: $e');
    }
  }

  static Future<void> cleanupPSBTFromMultisigFile(String transactionId) async {
    try {
      final groups = await MultisigStorage.loadGroups();
      bool groupUpdated = false;
      
      final updatedGroups = groups.map((group) {
        if (group.transactionIds.contains(transactionId)) {
          final updatedKeys = group.keys.map((key) {
            if (key.isWallet && (key.activePSBTs?.containsKey(transactionId) == true || key.initialPSBTs?.containsKey(transactionId) == true)) {
              final currentActivePSBTs = Map<String, String>.from(key.activePSBTs ?? {});
              final currentInitialPSBTs = Map<String, String>.from(key.initialPSBTs ?? {});
              
              currentActivePSBTs.remove(transactionId);
              currentInitialPSBTs.remove(transactionId);
              
              groupUpdated = true;
              return key.copyWith(
                activePSBTs: currentActivePSBTs.isEmpty ? null : currentActivePSBTs,
                initialPSBTs: currentInitialPSBTs.isEmpty ? null : currentInitialPSBTs,
              );
            }
            return key;
          }).toList();
          
          if (groupUpdated) {
            return group.copyWith(keys: updatedKeys);
          }
        }
        return group;
      }).toList();
      
      if (groupUpdated) {
        await MultisigStorage.saveGroups(updatedGroups);
      }
    } catch (e) {
      GetIt.I.get<Logger>().w('Failed to cleanup PSBT data: $e');
    }
  }



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

    final groups = await MultisigStorage.loadGroups();
    final group = groups.firstWhere(
      (g) => g.id == transaction.groupId,
      orElse: () => throw Exception('Group not found: ${transaction.groupId}'),
    );

    final validationResult = await PSBTValidator.validatePSBT(
      psbtBase64: psbt,
      group: group,
      keyId: keyId,
    );
    
    final actualSignedStatus = validationResult.isSigned;
    
    if (isSigned != actualSignedStatus) {
    }

    final keyPSBTs = List<KeyPSBTStatus>.from(transaction.keyPSBTs);
    final existingIndex = keyPSBTs.indexWhere((k) => k.keyId == keyId);
    
    final newKeyPSBT = KeyPSBTStatus(
      keyId: keyId,
      psbt: psbt,
      isSigned: actualSignedStatus, // Use validated status instead of claimed status
      signedAt: actualSignedStatus ? DateTime.now() : null,
    );

    if (existingIndex != -1) {
      keyPSBTs[existingIndex] = newKeyPSBT;
    } else {
      keyPSBTs.add(newKeyPSBT);
    }

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

  Future<T> withWallet<T>(
    String walletName,
    Future<T> Function() operation,
  ) async {
    if (!await isWalletLoaded(walletName)) {
      try {
        await loadWallet(walletName);
      } catch (e) {
        throw Exception('Wallet $walletName does not exist and could not be loaded: $e');
      }
    }

    return await operation();
  }

  Future<void> loadWallet(String walletName) async {
    try {
      final loadedWallets = await _rpc.callRAW('listwallets', []);
      if (loadedWallets is List && loadedWallets.contains(walletName)) {
        return;
      }

      await _rpc.callRAW('loadwallet', [walletName]);
    } catch (e) {
      if (e.toString().contains('already loaded')) {
        return;
      }
      GetIt.I.get<Logger>().e('Failed to load wallet $walletName: $e');
      rethrow;
    }
  }

  Future<void> unloadWallet(String walletName) async {
    try {
      await _rpc.callRAW('unloadwallet', [walletName]);
    } catch (e) {
      if (e.toString().contains('not found') || 
          e.toString().contains('not loaded')) {
        return;
      }
    }
  }

  Future<T> callWalletRPC<T>(String walletName, String method, List<dynamic> params) async {
    final rpcLive = _rpc as MainchainRPCLive;
    final conf = rpcLive.conf;
    
    final dio = Dio();
    dio.options.baseUrl = 'http://${conf.host}:${conf.port}';
    dio.options.headers = {
      'Content-Type': 'application/json',
    };

    final auth = 'Basic ${base64Encode(utf8.encode('${conf.username}:${conf.password}'))}';
    dio.options.headers['Authorization'] = auth;

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
      rethrow;
    }
  }

  Future<double> getWalletBalance(String walletName, {
    int minConf = 0,
    bool includeWatchOnly = true,
  }) async {
    return await withWallet<double>(walletName, () async {
      final result = await callWalletRPC<dynamic>(walletName, 'getbalance', [null, minConf, includeWatchOnly]);
      return result is num ? result.toDouble() : 0.0;
    });
  }

  Future<Map<String, dynamic>> getWalletInfo(String walletName) async {
    return await withWallet<Map<String, dynamic>>(walletName, () async {
      return await callWalletRPC<Map<String, dynamic>>(walletName, 'getwalletinfo', []);
    });
  }

  Future<List<dynamic>> listUnspent(String walletName, {
    int minConf = 0,
    int maxConf = 9999999,
  }) async {
    return await withWallet<List<dynamic>>(walletName, () async {
      return await callWalletRPC<List<dynamic>>(walletName, 'listunspent', [minConf, maxConf]);
    });
  }

  Future<String> getNewAddress(String walletName, {String? label, String? addressType}) async {
    return await withWallet<String>(walletName, () async {
      final params = <dynamic>[];
      if (label != null) params.add(label);
      if (addressType != null) params.add(addressType);
      
      return await callWalletRPC<String>(walletName, 'getnewaddress', params);
    });
  }

  Future<List<dynamic>> importDescriptors(String walletName, List<Map<String, dynamic>> descriptors) async {
    return await withWallet<List<dynamic>>(walletName, () async {
      return await callWalletRPC<List<dynamic>>(walletName, 'importdescriptors', [descriptors]);
    });
  }

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
      walletName,  // Create directly in network folder
      disablePrivateKeys,
      blank,
      passphrase ?? '',
      avoidReuse,
      descriptors,
      loadOnStartup,
    ];

    return await _rpc.callRAW('createwallet', params) as Map<String, dynamic>;
  }

  Future<void> importWallet(String walletName, String filename) async {
    await withWallet<void>(walletName, () async {
      await callWalletRPC<dynamic>(walletName, 'importwallet', [filename]);
    });
  }

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
      GetIt.I.get<Logger>().w('Failed to unload wallets: $e');
    }
  }

  String? get currentWallet => _currentlyLoadedWallet;

  Future<bool> isWalletLoaded(String walletName) async {
    try {
      final loadedWallets = await _rpc.callRAW('listwallets', []);
      return loadedWallets is List && loadedWallets.contains(walletName);
    } catch (e) {
      return false;
    }
  }

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

  Future<void> rescanWallet(String walletName, {int? startHeight, int? startTime}) async {
    return await withWallet<void>(walletName, () async {
      
      if (startHeight != null) {
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startHeight]);
      } else if (startTime != null) {
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startTime]);
      } else {
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', []);
      }
    });
  }

  Future<void> rescanRecentBlocks(String walletName, {int hoursBack = 24}) async {
    return await withWallet<void>(walletName, () async {
      final blockchainInfo = await _rpc.callRAW('getblockchaininfo', []);
      
      if (blockchainInfo is! Map || blockchainInfo['blocks'] is! int) {
        throw Exception('getblockchaininfo returned invalid response: $blockchainInfo');
      }
      
      final currentHeight = blockchainInfo['blocks'] as int;
      
      final blocksBack = hoursBack * 6;
      final startHeight = (currentHeight - blocksBack).clamp(0, currentHeight);
      
      await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startHeight]);
    });
  }

  Future<Map<String, dynamic>> getWalletBalanceAndUtxos(String walletName) async {
    return await withWallet<Map<String, dynamic>>(walletName, () async {
      final balance = await callWalletRPC<dynamic>(walletName, 'getbalance', [null, 0, true]);
      final utxos = await callWalletRPC<List<dynamic>>(walletName, 'listunspent', [0, 9999999, null, true]);
      
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

class MultisigStorage {
  static const String _fileName = 'multisig.json';

  static Future<String> _getGroupsFilePath() async {
    final appDir = await Environment.datadir();
    final multisigDir = Directory(path.join(appDir.path, 'bitdrive', 'multisig'));
    await multisigDir.create(recursive: true);
    return path.join(multisigDir.path, _fileName);
  }

  static Future<List<MultisigGroup>> loadGroups() async {
    return await FileOperationLock.withLock('multisig.json', () async {
      try {
        final filePath = await _getGroupsFilePath();
        final file = File(filePath);
        
        if (!await file.exists()) {
          return [];
        }
        
        final content = await file.readAsString();
        final jsonData = json.decode(content) as Map<String, dynamic>;
        
        final groupsList = jsonData['groups'] as List<dynamic>? ?? [];
        return groupsList
            .map((json) => MultisigGroup.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw Exception('Failed to load groups: $e');
      }
    });
  }

  static Future<void> saveGroups(List<MultisigGroup> groups) async {
    return await FileOperationLock.withLock('multisig.json', () async {
      final filePath = await _getGroupsFilePath();
      final file = File(filePath);
      
      await file.parent.create(recursive: true);
      
      // Preserve existing solo_keys if file exists and is valid
      final soloKeys = await _loadExistingSoloKeys(file);
      
      final jsonData = {
        'groups': groups.map((group) => group.toJson()).toList(),
        'solo_keys': soloKeys,
      };
      
      final content = json.encode(jsonData);
      await file.writeAsString(content);
    });
  }

  static Future<List<Map<String, dynamic>>> _loadExistingSoloKeys(File file) async {
    if (!await file.exists()) return [];
    
    final existingContent = await file.readAsString();
    if (existingContent.trim().isEmpty) return [];
    
    final existingData = json.decode(existingContent);
    if (existingData is Map<String, dynamic> && existingData['solo_keys'] is List) {
      return List<Map<String, dynamic>>.from(existingData['solo_keys']);
    }
    
    return [];
  }



  static Future<void> updateGroupBalance(String groupId, double balance, int utxoCount) async {
    final groups = await loadGroups();
    final groupIndex = groups.indexWhere((g) => g.id == groupId);
    
    if (groupIndex != -1) {
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
  
  static Future<String> getMultisigFilePath() => _getGroupsFilePath();
  
  static Future<List<Map<String, dynamic>>> loadSoloKeys() async {
    try {
      final filePath = await _getGroupsFilePath();
      final file = File(filePath);
      
      if (!await file.exists()) {
        return [];
      }
      
      final content = await file.readAsString();
      final jsonData = json.decode(content);
      
      if (jsonData is Map<String, dynamic> && jsonData['solo_keys'] is List) {
        return List<Map<String, dynamic>>.from(jsonData['solo_keys']);
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> addSoloKey(Map<String, dynamic> keyData) async {
    try {
      final soloKeys = await loadSoloKeys();
      
      final existingIndex = soloKeys.indexWhere((key) => key['xpub'] == keyData['xpub']);
      
      if (existingIndex == -1) {
        soloKeys.add(keyData);
        
        final groups = await loadGroups();
        final filePath = await _getGroupsFilePath();
        final file = File(filePath);
        
        await file.parent.create(recursive: true);
        
        final jsonData = {
          'groups': groups.map((group) => group.toJson()).toList(),
          'solo_keys': soloKeys,
        };
        
        final content = json.encode(jsonData);
        await file.writeAsString(content);
      }
    } catch (e) {
      throw Exception('Failed to add solo key: $e');
    }
  }
  
  static Future<void> restoreTransactionHistory(MultisigGroup group) async {
    final logger = GetIt.I.get<Logger>();
    
    try {
      logger.i('Restoring transaction history for group: ${group.name} (ID: ${group.id})');
      
      if (group.watchWalletName == null) {
        logger.w('No watch wallet name found for group: ${group.name}, skipping transaction restoration');
        return;
      }
      
      logger.d('Using watch wallet: ${group.watchWalletName}');
      
      final walletManager = WalletRPCManager();
      final rpc = GetIt.I.get<MainchainRPC>();
      
      logger.d('Calling listtransactions on wallet: ${group.watchWalletName}');
      final transactions = await walletManager.callWalletRPC<List<dynamic>>(
        group.watchWalletName!,
        'listtransactions',
        ['*', 1000, 0, true], // label, count, skip, include_watchonly
      );
      
      logger.i('Found ${transactions.length} total transactions from wallet RPC');
      
      final relevantTxs = <Map<String, dynamic>>[];
      final allTxs = <Map<String, dynamic>>[];
      
      for (final tx in transactions) {
        if (tx is Map<String, dynamic>) {
          final txid = tx['txid'] as String?;
          final confirmations = tx['confirmations'] as int? ?? 0;
          final amount = tx['amount'] as num? ?? 0;
          
          allTxs.add(tx);
          logger.d('TX: $txid, confirmations: $confirmations, amount: $amount');
          
          // Include transactions with 0 confirmations too (recently broadcasted)
          if (txid != null && confirmations >= 0) {
            relevantTxs.add(tx);
          }
        }
      }
      
      logger.i('Found ${relevantTxs.length} relevant transactions (including 0-conf)');
      
      int processedCount = 0;
      int errorCount = 0;
      
      for (final walletTx in relevantTxs) {
        try {
          final txid = walletTx['txid'] as String;
          logger.d('Processing historical transaction: $txid');
          await _processHistoricalTransaction(group, walletTx, rpc);
          processedCount++;
        } catch (e) {
          errorCount++;
          logger.e('Error processing historical transaction: $e');
        }
      }
      
      logger.i('Transaction restoration completed: $processedCount processed, $errorCount errors');
      
    } catch (e) {
      logger.e('Failed to restore transaction history for group ${group.name}: $e');
      throw Exception('Transaction history restoration failed: $e');
    }
  }
  
  static Future<void> _processHistoricalTransaction(
    MultisigGroup group,
    Map<String, dynamic> walletTx,
    MainchainRPC rpc,
  ) async {
    final logger = GetIt.I.get<Logger>();
    final txid = walletTx['txid'] as String;
    final originalAmount = (walletTx['amount'] as num?)?.toDouble() ?? 0.0;
    final amount = originalAmount.abs();
    final isDeposit = originalAmount > 0;
    final confirmations = walletTx['confirmations'] as int? ?? 0;
    
    logger.d('Processing transaction $txid: amount=$amount, confirmations=$confirmations');
    
    final existingTx = await TransactionStorage.getTransaction(txid);
    if (existingTx != null) {
      logger.d('Transaction $txid already exists in storage, skipping');
      return;
    }
    
    logger.d('Fetching raw transaction details for $txid');
    final txDetails = await rpc.callRAW('getrawtransaction', [txid, true]) as Map<String, dynamic>;
    
    if (txDetails.isEmpty) {
      logger.w('No transaction data for $txid, skipping');
      return;
    }
    
    final outputs = txDetails['vout'] as List<dynamic>? ?? [];
    final inputs = txDetails['vin'] as List<dynamic>? ?? [];
    
    logger.d('Transaction $txid has ${inputs.length} inputs and ${outputs.length} outputs');
    
    String destination = 'Unknown';
    if (outputs.isNotEmpty) {
      final firstOutput = outputs.first as Map<String, dynamic>;
      final scriptPubKey = firstOutput['scriptPubKey'] as Map<String, dynamic>?;
      destination = scriptPubKey?['address'] as String? ?? 'Unknown';
    }
    
    // Count signatures in the transaction
    int signatureCount = _countSignaturesInTransaction(inputs, group);
    logger.d('Transaction $txid has $signatureCount signatures out of ${group.m} required');
    
    // Create keyPSBTs to properly represent the signature status
    final keyPSBTs = group.keys.map((key) {
      // For historical transactions, we assume all required signatures are present
      // since the transaction is confirmed
      final isSigned = signatureCount >= group.m;
      return KeyPSBTStatus(
        keyId: key.xpub,
        psbt: null, // Historical transactions don't have PSBTs
        isSigned: isSigned,
        signedAt: isSigned ? DateTime.fromMillisecondsSinceEpoch((walletTx['time'] as int? ?? 0) * 1000) : null,
      );
    }).toList();
    
    // Determine transaction status based on confirmations and type
    TxStatus status;
    if (confirmations == 0) {
      status = TxStatus.broadcasted; // 0-conf, recently broadcasted
    } else if (confirmations >= 6) {
      status = TxStatus.confirmed; // Fully confirmed
    } else {
      status = TxStatus.broadcasted; // Has confirmations but not fully confirmed
    }
    
    final historicalTx = MultisigTransaction(
      id: txid,
      groupId: group.id,
      initialPSBT: '', // Historical transactions don't have PSBTs
      keyPSBTs: keyPSBTs,
      inputs: inputs.map((input) => UtxoInfo(
        txid: input['txid'] ?? '',
        vout: input['vout'] ?? 0,
        amount: 0.0, // We don't have input amounts easily accessible
        confirmations: confirmations,
        address: '',
      ),).toList(),
      destination: destination,
      amount: amount,
      status: status,
      type: isDeposit ? TxType.deposit : TxType.withdrawal,
      created: DateTime.fromMillisecondsSinceEpoch((walletTx['time'] as int? ?? 0) * 1000),
      fee: 0.0, // Fee calculation for historical txs is complex
      confirmations: confirmations,
      broadcastTime: DateTime.fromMillisecondsSinceEpoch((walletTx['time'] as int? ?? 0) * 1000),
      finalHex: txDetails['hex'] as String?,
      txid: txid, // Set the actual transaction ID
    );
    
    logger.i('Saving historical transaction $txid to storage (status: ${status.displayName}, confirmations: $confirmations)');
    await TransactionStorage.saveTransaction(historicalTx);
    logger.d('Successfully saved transaction $txid');
  }

  static int _countSignaturesInTransaction(List<dynamic> inputs, MultisigGroup group) {
    int totalSignatures = 0;
    
    for (final input in inputs) {
      if (input is Map<String, dynamic>) {
        // Check scriptSig for signatures
        final scriptSig = input['scriptSig'] as Map<String, dynamic>?;
        if (scriptSig != null) {
          final asm = scriptSig['asm'] as String?;
          if (asm != null) {
            // Count non-empty signatures in the ASM
            // Multisig scriptSig format: OP_0 <sig1> <sig2> ... <redeemScript>
            final parts = asm.split(' ');
            int sigCount = 0;
            for (final part in parts) {
              // Signatures are typically 70-72 bytes (140-144 hex chars) and don't start with OP_
              if (part.length >= 140 && part.length <= 150 && !part.startsWith('OP_')) {
                sigCount++;
              }
            }
            totalSignatures += sigCount;
          }
        }
        
        // Also check witness data for P2WSH multisig
        final txinwitness = input['txinwitness'] as List<dynamic>?;
        if (txinwitness != null) {
          int witnessSignatures = 0;
          for (final witness in txinwitness) {
            if (witness is String && witness.length >= 140 && witness.length <= 150) {
              witnessSignatures++;
            }
          }
          totalSignatures += witnessSignatures;
        }
      }
    }
    
    return totalSignatures;
  }

  static Future<void> createMultisigWallet(String walletName, String descriptorReceive, String descriptorChange) async {
    final rpc = GetIt.I.get<MainchainRPC>();
    final logger = GetIt.I.get<Logger>();
    
    try {
      logger.d('Creating multisig wallet: $walletName');
      
      // Create wallet directly in network folder, no wallets/ subdirectory
      await rpc.callRAW('createwallet', [
        walletName,  // Create directly in network folder
        true,   // disable_private_keys - DISABLE private keys (watch-only)
        true,   // blank (start empty)
        '',     // passphrase (empty)
        false,  // avoid_reuse 
        true,   // descriptors (modern descriptor wallet format)
        false,  // load_on_startup
      ]);
      
      try {
        await rpc.callRAW('loadwallet', [walletName]);
      } catch (e) {
        // Wallet might already be loaded
      }
      
      final descriptorsToImport = [
        {
          'desc': descriptorReceive,
          'active': true,
          'internal': false,
          'timestamp': 'now',
          'range': [0, 999],
        },
        {
          'desc': descriptorChange,
          'active': true,
          'internal': true,
          'timestamp': 'now',
          'range': [0, 999],
        },
      ];
      
      final walletManager = WalletRPCManager();
      final importResult = await walletManager.importDescriptors(walletName, descriptorsToImport);
      
      for (int i = 0; i < importResult.length; i++) {
        final result = importResult[i] as Map<String, dynamic>;
        final success = result['success'] as bool? ?? false;
        final desc = i == 0 ? 'receive' : 'change';
        
        if (!success) {
          final error = result['error'] ?? 'Unknown error';
          logger.e('Failed to import $desc descriptor: $error');
          throw Exception('Failed to import $desc descriptor: $error');
        }
      }
      
      logger.i('Successfully created multisig wallet: $walletName');
      
    } catch (e) {
      if (e.toString().contains('already exists') || e.toString().contains('Database already exists')) {
        logger.d('Wallet $walletName already exists, skipping creation');
        return; // Not a fatal error
      }
      
      logger.e('Failed to create multisig wallet $walletName: $e');
      throw Exception('Failed to create multisig wallet: $e');
    }
  }
}

class MultisigFileWatcher extends ChangeNotifier {
  static final MultisigFileWatcher _instance = MultisigFileWatcher._internal();
  factory MultisigFileWatcher() => _instance;
  MultisigFileWatcher._internal();

  Timer? _watchTimer;
  String? _lastGroupsHash;
  String? _lastTransactionsHash;
  bool _isWatching = false;

  bool get isWatching => _isWatching;

  void startWatching() {
    if (_isWatching) return;
    
    _isWatching = true;
    _watchTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (await _filesChanged()) {
        notifyListeners();
      }
    });
  }

  void stopWatching() {
    _isWatching = false;
    _watchTimer?.cancel();
    _watchTimer = null;
  }

  Future<bool> _filesChanged() async {
    try {
      final groupsPath = await MultisigStorage.getMultisigFilePath();
      final transactionsPath = await TransactionStorage.getTransactionFilePath();

      final currentGroupsHash = await _getFileHash(groupsPath);
      final currentTransactionsHash = await _getFileHash(transactionsPath);

      final groupsChanged = _lastGroupsHash != currentGroupsHash;
      final transactionsChanged = _lastTransactionsHash != currentTransactionsHash;

      if (groupsChanged || transactionsChanged) {
        _lastGroupsHash = currentGroupsHash;
        _lastTransactionsHash = currentTransactionsHash;
        return true;
      }

      return false;
    } catch (e) {
      return true; // Assume changed on error
    }
  }

  Future<String?> _getFileHash(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final contents = await file.readAsBytes();
      final digest = sha256.convert(contents);
      return digest.toString();
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    stopWatching();
    super.dispose();
  }
}