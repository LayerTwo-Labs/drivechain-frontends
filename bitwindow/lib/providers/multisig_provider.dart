import 'dart:async';

import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart' as tspb;
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/multisig/v1/multisig.pb.dart' as multisigpb;
import 'package:sail_ui/gen/multisiglounge/v1/multisiglounge.pb.dart' as mlpb;
import 'package:sail_ui/sail_ui.dart';

OrchestratorMultisigLoungeRPC get _multisigLounge => GetIt.I.get<OrchestratorRPC>().multisigLounge;

mlpb.MultisigGroup _groupToLoungeProto(MultisigGroup group) {
  return mlpb.MultisigGroup(
    m: group.m,
    n: group.n,
    keys: group.keys.map(
      (k) => mlpb.MultisigKey(
        xpub: k.xpub,
        derivationPath: k.derivationPath,
        fingerprint: k.fingerprint ?? '',
        originPath: k.originPath ?? '',
        isWallet: k.isWallet,
      ),
    ),
  );
}

/// Builds the full GroupData wire message (with per-key derivation paths) used
/// by sign/combine/publish RPCs.
mlpb.GroupData multisigGroupToProto(MultisigGroup group) {
  return mlpb.GroupData(
    id: group.id,
    name: group.name,
    n: group.n,
    m: group.m,
    keys: group.keys.map(
      (k) => mlpb.GroupKey(
        owner: k.owner,
        xpub: k.xpub,
        derivationPath: k.derivationPath,
        fingerprint: k.fingerprint ?? '',
        originPath: k.originPath ?? '',
        isWallet: k.isWallet,
      ),
    ),
    created: Int64(group.created),
    descriptorReceive: group.descriptorReceive ?? '',
    descriptorChange: group.descriptorChange ?? '',
    watchWalletName: group.watchWalletName ?? '',
    txid: group.txid ?? '',
  );
}

/// Retained for API compatibility. No-op now that storage is backend-owned.
class FileOperationLock {
  static Future<T> withLock<T>(String lockKey, Future<T> Function() operation) async {
    return await operation();
  }
}

// Shared helper now lives in sail_ui as `bitcoindRpcCall`.
Future<dynamic> _coreRaw(String method, [List<dynamic>? params]) => bitcoindRpcCall(method, params: params);

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
      TxStatus.needsSignatures: [TxStatus.awaitingSignedPSBTs, TxStatus.readyToCombine, TxStatus.voided],
      TxStatus.awaitingSignedPSBTs: [TxStatus.readyToCombine, TxStatus.voided],
      // Combine+finalize+broadcast is one atomic orchestrator call, so a
      // readyToCombine tx jumps straight to broadcasted. readyForBroadcast stays
      // reachable from the single-shot signing path (psbt coordinator).
      TxStatus.readyToCombine: [TxStatus.broadcasted, TxStatus.readyForBroadcast, TxStatus.voided],
      TxStatus.readyForBroadcast: [TxStatus.broadcasted, TxStatus.voided],
      TxStatus.broadcasted: [TxStatus.confirmed, TxStatus.voided],
      TxStatus.confirmed: [TxStatus.completed],
    };
    return validTransitions[from]?.contains(to) ?? false;
  }
}

class PSBTValidator {
  /// Validates a PSBT via orchestrator MultisigLoungeService. requiredSigs is
  /// the group threshold (m); validation is pure stateless logic backend-side.
  static Future<mlpb.ValidatePsbtResponse> _validate(String psbtBase64, int requiredSigs) {
    return _multisigLounge.validatePsbt(psbtBase64: psbtBase64, requiredSigs: requiredSigs);
  }

  /// Checks if any partial signatures are present on the PSBT.
  static Future<bool> hasAnySignatures(String psbtBase64, int totalKeysInGroup) async {
    try {
      final res = await _validate(psbtBase64, totalKeysInGroup);
      if (res.error.isNotEmpty) return false;
      return res.hasSignatures;
    } catch (e) {
      GetIt.I.get<Logger>().e('Error in hasAnySignatures: $e');
      return false;
    }
  }

  /// Checks if the PSBT has at least requiredSigs signatures (or is finalizable).
  static Future<bool> hasValidSignatures(String psbtBase64, int requiredSigs, {int? totalKeys}) async {
    try {
      final res = await _validate(psbtBase64, requiredSigs);
      if (res.error.isNotEmpty) return false;
      return res.finalizable || res.signatureCount >= requiredSigs;
    } catch (e) {
      GetIt.I.get<Logger>().e('Error checking valid signatures: $e');
      return false;
    }
  }

  static Future<bool> isReadyForBroadcast(String psbtBase64, int requiredSigs) async {
    try {
      final res = await _validate(psbtBase64, requiredSigs);
      if (res.error.isNotEmpty) return false;
      return res.finalizable;
    } catch (e) {
      return false;
    }
  }

  static Future<int> countSignatures(String psbtBase64, {int? totalKeys}) async {
    try {
      final res = await _validate(psbtBase64, totalKeys ?? 0);
      if (res.error.isNotEmpty) return 0;
      return res.signatureCount;
    } catch (e) {
      GetIt.I.get<Logger>().e('Error counting signatures: $e');
      return 0;
    }
  }
}

class BalanceManager {
  static WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  /// Syncs a group's watch-only wallet server-side (creating it from the
  /// Phase-1 descriptors if missing), persists the confirmed balance + utxo
  /// count, then restores any new transaction history.
  static Future<void> updateGroupBalance(MultisigGroup group) async {
    final lockKey = 'balance_${group.id}';

    return await FileOperationLock.withLock(lockKey, () async {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) return;

      final resp = await _multisigLounge.syncGroup(
        group: multisigGroupToProto(group),
        walletId: walletId,
      );

      final balanceBtc = resp.confirmedSats.toInt() / 100000000.0;
      await MultisigStorage.updateGroupBalance(group.id, balanceBtc, resp.utxoCount);

      try {
        await MultisigStorage.restoreTransactionHistory(group);
      } catch (e) {
        // Failed to refresh history - not critical to the balance update.
      }
    });
  }

  static Future<void> updateAllGroupBalances(List<MultisigGroup> groups) async {
    await Future.wait(
      groups.map((group) => updateGroupBalance(group)),
    );
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
}

class MultisigDescriptorBuilder {
  static Future<MultisigDescriptors> buildWatchOnlyDescriptors(MultisigGroup group) async {
    final resp = await _multisigLounge.buildDescriptors(_groupToLoungeProto(group));
    return MultisigDescriptors(
      receive: resp.receiveDescriptor,
      change: resp.changeDescriptor,
    );
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
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  /// Signs a multisig PSBT server-side: the orchestrator derives the wallet's
  /// keys from its seed, builds the signing descriptor, and runs
  /// descriptorprocesspsbt. No mnemonic leaves the daemon.
  Future<SigningResult> signPSBT({
    required String psbtBase64,
    required MultisigGroup group,
  }) async {
    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      final resp = await _multisigLounge.signTransaction(
        psbtBase64: psbtBase64,
        group: multisigGroupToProto(group),
        walletId: walletId,
      );

      return SigningResult(
        signedPsbt: resp.psbtBase64,
        isComplete: resp.isComplete,
        signaturesAdded: resp.addedSignatures,
      );
    } catch (e) {
      throw Exception('Multisig PSBT signing failed: $e');
    }
  }
}

class TransactionStorage {
  static final _notifier = MultisigTransactionNotifier();
  static MultisigAPI get _api => GetIt.I.get<BitwindowRPC>().multisig;

  static Future<List<MultisigTransaction>> loadTransactions() async {
    try {
      final pbTxns = await _api.listTransactions();
      return pbTxns.map(_protoToTransaction).toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  static Future<void> saveTransactions(List<MultisigTransaction> transactions) async {
    for (final tx in transactions) {
      await saveTransaction(tx);
    }
    _notifier.notifyTransactionChange();
  }

  static Future<void> saveTransaction(MultisigTransaction transaction) async {
    await _api.saveTransaction(_transactionToProto(transaction));
    _notifier.notifyTransactionChange();
  }

  static MultisigTransactionNotifier get notifier => _notifier;

  static Future<MultisigTransaction?> getTransaction(String transactionId) async {
    try {
      final pb = await _api.getTransaction(transactionId);
      return _protoToTransaction(pb);
    } catch (e) {
      return null;
    }
  }

  static Future<List<MultisigTransaction>> getTransactionsForGroup(String groupId) async {
    final pbTxns = await _api.listTransactions(groupId: groupId);
    return pbTxns.map(_protoToTransaction).toList();
  }

  static Future<MultisigTransaction?> getTransactionByTxid(String txid) async {
    try {
      final pb = await _api.getTransactionByTxid(txid);
      return _protoToTransaction(pb);
    } catch (e) {
      return null;
    }
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

    final isActuallySigned = await PSBTValidator.hasAnySignatures(signedPSBT, group.n);

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
      newStatus = TxStatus.readyToCombine;
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
      await _storePSBTInGroup(transactionId, keyId, transaction.initialPSBT, signedPSBT);
    }
  }

  static Future<void> _storePSBTInGroup(
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

  static Future<void> cleanupPSBTFromGroup(String transactionId) async {
    try {
      final groups = await MultisigStorage.loadGroups();
      bool groupUpdated = false;

      final updatedGroups = groups.map((group) {
        if (group.transactionIds.contains(transactionId)) {
          final updatedKeys = group.keys.map((key) {
            if (key.isWallet &&
                (key.activePSBTs?.containsKey(transactionId) == true ||
                    key.initialPSBTs?.containsKey(transactionId) == true)) {
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

    final actualSignedStatus = await PSBTValidator.hasAnySignatures(psbt, group.n);

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
    final newStatus = signedCount >= threshold ? TxStatus.readyToCombine : TxStatus.needsSignatures;

    final updatedTransaction = transaction.copyWith(
      keyPSBTs: keyPSBTs,
      status: newStatus,
    );

    await saveTransaction(updatedTransaction);
  }

  // ─── Proto ↔ Model converters ─────────────────────────────────────

  static MultisigTransaction _protoToTransaction(multisigpb.MultisigTransaction pb) {
    return MultisigTransaction(
      id: pb.id,
      groupId: pb.groupId,
      initialPSBT: pb.initialPsbt,
      keyPSBTs: pb.keyPsbts
          .map(
            (kp) => KeyPSBTStatus(
              keyId: kp.keyId,
              psbt: kp.psbt.isEmpty ? null : kp.psbt,
              isSigned: kp.isSigned,
              signedAt: kp.hasSignedAt() ? kp.signedAt.toDateTime() : null,
            ),
          )
          .toList(),
      combinedPSBT: pb.combinedPsbt.isEmpty ? null : pb.combinedPsbt,
      finalHex: pb.finalHex.isEmpty ? null : pb.finalHex,
      txid: pb.txid.isEmpty ? null : pb.txid,
      status: _protoStatusToTxStatus(pb.status),
      type: pb.type == multisigpb.TxType.TX_TYPE_WITHDRAWAL ? TxType.withdrawal : TxType.deposit,
      created: pb.hasCreated() ? pb.created.toDateTime() : DateTime.now(),
      broadcastTime: pb.hasBroadcastTime() ? pb.broadcastTime.toDateTime() : null,
      amount: pb.amount,
      destination: pb.destination,
      fee: pb.fee,
      inputs: pb.inputs
          .map(
            (inp) => UtxoInfo(
              txid: inp.txid,
              vout: inp.vout,
              address: inp.address,
              amount: inp.amount,
              confirmations: inp.confirmations,
            ),
          )
          .toList(),
      confirmations: pb.confirmations,
    );
  }

  static multisigpb.MultisigTransaction _transactionToProto(MultisigTransaction tx) {
    return multisigpb.MultisigTransaction(
      id: tx.id,
      groupId: tx.groupId,
      initialPsbt: tx.initialPSBT,
      keyPsbts: tx.keyPSBTs
          .map(
            (kp) => multisigpb.KeyPSBTStatus(
              keyId: kp.keyId,
              psbt: kp.psbt ?? '',
              isSigned: kp.isSigned,
              signedAt: kp.signedAt != null ? tspb.Timestamp.fromDateTime(kp.signedAt!) : null,
            ),
          )
          .toList(),
      combinedPsbt: tx.combinedPSBT ?? '',
      finalHex: tx.finalHex ?? '',
      txid: tx.txid ?? '',
      status: _txStatusToProto(tx.status),
      type: tx.type == TxType.withdrawal ? multisigpb.TxType.TX_TYPE_WITHDRAWAL : multisigpb.TxType.TX_TYPE_DEPOSIT,
      created: tspb.Timestamp.fromDateTime(tx.created),
      broadcastTime: tx.broadcastTime != null ? tspb.Timestamp.fromDateTime(tx.broadcastTime!) : null,
      amount: tx.amount,
      destination: tx.destination,
      fee: tx.fee,
      inputs: tx.inputs
          .map(
            (inp) => multisigpb.UtxoDetail(
              txid: inp.txid,
              vout: inp.vout,
              address: inp.address,
              amount: inp.amount,
              confirmations: inp.confirmations,
            ),
          )
          .toList(),
      confirmations: tx.confirmations,
      requiredSignatures: tx.requiredSignatures,
    );
  }

  static TxStatus _protoStatusToTxStatus(multisigpb.TxStatus s) {
    switch (s) {
      case multisigpb.TxStatus.TX_STATUS_NEEDS_SIGNATURES:
        return TxStatus.needsSignatures;
      case multisigpb.TxStatus.TX_STATUS_AWAITING_SIGNED_PSBTS:
        return TxStatus.awaitingSignedPSBTs;
      case multisigpb.TxStatus.TX_STATUS_READY_TO_COMBINE:
        return TxStatus.readyToCombine;
      case multisigpb.TxStatus.TX_STATUS_READY_FOR_BROADCAST:
        return TxStatus.readyForBroadcast;
      case multisigpb.TxStatus.TX_STATUS_BROADCASTED:
        return TxStatus.broadcasted;
      case multisigpb.TxStatus.TX_STATUS_CONFIRMED:
        return TxStatus.confirmed;
      case multisigpb.TxStatus.TX_STATUS_COMPLETED:
        return TxStatus.completed;
      case multisigpb.TxStatus.TX_STATUS_VOIDED:
        return TxStatus.voided;
      default:
        return TxStatus.needsSignatures;
    }
  }

  static multisigpb.TxStatus _txStatusToProto(TxStatus s) {
    switch (s) {
      case TxStatus.needsSignatures:
        return multisigpb.TxStatus.TX_STATUS_NEEDS_SIGNATURES;
      case TxStatus.awaitingSignedPSBTs:
        return multisigpb.TxStatus.TX_STATUS_AWAITING_SIGNED_PSBTS;
      case TxStatus.readyToCombine:
        return multisigpb.TxStatus.TX_STATUS_READY_TO_COMBINE;
      case TxStatus.readyForBroadcast:
        return multisigpb.TxStatus.TX_STATUS_READY_FOR_BROADCAST;
      case TxStatus.broadcasted:
        return multisigpb.TxStatus.TX_STATUS_BROADCASTED;
      case TxStatus.confirmed:
        return multisigpb.TxStatus.TX_STATUS_CONFIRMED;
      case TxStatus.completed:
        return multisigpb.TxStatus.TX_STATUS_COMPLETED;
      case TxStatus.voided:
        return multisigpb.TxStatus.TX_STATUS_VOIDED;
    }
  }
}

class WalletRPCManager {
  static final WalletRPCManager _instance = WalletRPCManager._internal();
  factory WalletRPCManager() => _instance;
  WalletRPCManager._internal();

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
      final loadedWallets = await _coreRaw('listwallets', []);
      if (loadedWallets is List && loadedWallets.contains(walletName)) {
        return;
      }

      await _coreRaw('loadwallet', [walletName]);
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
      await _coreRaw('unloadwallet', [walletName]);
    } catch (e) {
      if (e.toString().contains('not found') || e.toString().contains('not loaded')) {
        return;
      }
    }
  }

  Future<T> callWalletRPC<T>(String walletName, String method, List<dynamic> params) async {
    final result = await bitcoindRpcCall(method, params: params, wallet: walletName);
    return result as T;
  }

  Future<double> getWalletBalance(
    String walletName, {
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

  Future<List<dynamic>> listUnspent(
    String walletName, {
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
      walletName, // Create directly in network folder
      disablePrivateKeys,
      blank,
      passphrase ?? '',
      avoidReuse,
      descriptors,
      loadOnStartup,
    ];

    return await _coreRaw('createwallet', params) as Map<String, dynamic>;
  }

  Future<void> importWallet(String walletName, String filename) async {
    await withWallet<void>(walletName, () async {
      await callWalletRPC<dynamic>(walletName, 'importwallet', [filename]);
    });
  }

  Future<void> unloadAllWallets() async {
    try {
      final loadedWallets = await _coreRaw('listwallets', []);
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
      final loadedWallets = await _coreRaw('listwallets', []);
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
      final blockchainInfo = await _coreRaw('getblockchaininfo', []);

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
  static MultisigAPI get _api => GetIt.I.get<BitwindowRPC>().multisig;
  static WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  static Future<List<MultisigGroup>> loadGroups() async {
    try {
      final pbGroups = await _api.listGroups();
      return pbGroups.map(_protoToGroup).toList();
    } catch (e) {
      throw Exception('Failed to load groups: $e');
    }
  }

  static Future<void> saveGroups(List<MultisigGroup> groups) async {
    for (final group in groups) {
      await _api.saveGroup(_groupToProto(group));
    }
  }

  static Future<void> updateGroupBalance(String groupId, double balance, int utxoCount) async {
    final groups = await loadGroups();
    final groupIndex = groups.indexWhere((g) => g.id == groupId);

    if (groupIndex != -1) {
      final group = groups[groupIndex];
      final updatedGroup = group.copyWith(
        balance: balance,
        utxos: utxoCount,
      );
      await _api.saveGroup(_groupToProto(updatedGroup));
    }
  }

  static Future<List<Map<String, dynamic>>> loadSoloKeys() async {
    try {
      final pbKeys = await _api.listSoloKeys();
      return pbKeys
          .map(
            (k) => {
              'xpub': k.xpub,
              'path': k.derivationPath,
              'fingerprint': k.fingerprint,
              'origin_path': k.originPath,
              'owner': k.owner,
            },
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addSoloKey(Map<String, dynamic> keyData) async {
    try {
      await _api.addSoloKey(
        multisigpb.SoloKey(
          xpub: keyData['xpub'] as String? ?? '',
          derivationPath: keyData['path'] as String? ?? '',
          fingerprint: keyData['fingerprint'] as String? ?? '',
          originPath: keyData['origin_path'] as String? ?? '',
          owner: keyData['owner'] as String? ?? '',
        ),
      );
    } catch (e) {
      throw Exception('Failed to add solo key: $e');
    }
  }

  static Future<void> restoreTransactionHistory(MultisigGroup group) async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) return;

    try {
      final resp = await _multisigLounge.restoreHistory(
        group: multisigGroupToProto(group),
        walletId: walletId,
      );

      for (final tx in resp.transactions) {
        final existingTx = await TransactionStorage.getTransactionByTxid(tx.txid);
        if (existingTx != null) {
          continue;
        }
        await TransactionStorage.saveTransaction(_historyToTransaction(group, tx));
        TransactionStorage.notifier.notifyTransactionChange();
      }
    } catch (e) {
      throw Exception('Transaction history restoration failed: $e');
    }
  }

  static MultisigTransaction _historyToTransaction(MultisigGroup group, mlpb.MultisigHistoryTx tx) {
    final amount = tx.amountSats.toInt() / 100000000.0;
    final isSigned = tx.signatureCount >= group.m;
    final signedAt = isSigned ? DateTime.fromMillisecondsSinceEpoch(tx.time.toInt() * 1000) : null;
    final time = DateTime.fromMillisecondsSinceEpoch(tx.time.toInt() * 1000);

    return MultisigTransaction(
      id: tx.txid,
      groupId: group.id,
      initialPSBT: '',
      keyPSBTs: group.keys
          .map((key) => KeyPSBTStatus(keyId: key.xpub, psbt: null, isSigned: isSigned, signedAt: signedAt))
          .toList(),
      inputs: tx.inputs
          .map((i) => UtxoInfo(txid: i.txid, vout: i.vout, amount: 0.0, confirmations: tx.confirmations, address: ''))
          .toList(),
      destination: tx.destination,
      amount: amount,
      status: tx.status == 'confirmed' ? TxStatus.confirmed : TxStatus.broadcasted,
      type: tx.isDeposit ? TxType.deposit : TxType.withdrawal,
      created: time,
      fee: 0.0,
      confirmations: tx.confirmations,
      broadcastTime: time,
      finalHex: tx.finalHex.isEmpty ? null : tx.finalHex,
      txid: tx.txid,
    );
  }

  static Future<void> createMultisigWallet(String walletName, String descriptorReceive, String descriptorChange) async {
    try {
      // Create wallet directly in network folder, no wallets/ subdirectory
      await _coreRaw('createwallet', [
        walletName, // Create directly in network folder
        true, // disable_private_keys - DISABLE private keys (watch-only)
        true, // blank (start empty)
        '', // passphrase (empty)
        false, // avoid_reuse
        true, // descriptors (modern descriptor wallet format)
        false, // load_on_startup
      ]);

      try {
        await _coreRaw('loadwallet', [walletName]);
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
          throw Exception('Failed to import $desc descriptor: $error');
        }
      }
    } catch (e) {
      if (e.toString().contains('already exists') || e.toString().contains('Database already exists')) {
        return; // Not a fatal error
      }

      throw Exception('Failed to create multisig wallet: $e');
    }
  }

  // ─── Proto ↔ Model converters ─────────────────────────────────────

  static MultisigGroup _protoToGroup(multisigpb.MultisigGroup pb) {
    return MultisigGroup(
      id: pb.id,
      name: pb.name,
      n: pb.n,
      m: pb.m,
      keys: pb.keys
          .map(
            (k) => MultisigKey(
              owner: k.owner,
              xpub: k.xpub,
              derivationPath: k.derivationPath,
              fingerprint: k.fingerprint.isEmpty ? null : k.fingerprint,
              originPath: k.originPath.isEmpty ? null : k.originPath,
              isWallet: k.isWallet,
              activePSBTs: k.activePsbts.isNotEmpty ? Map<String, String>.from(k.activePsbts) : null,
              initialPSBTs: k.initialPsbts.isNotEmpty ? Map<String, String>.from(k.initialPsbts) : null,
            ),
          )
          .toList(),
      created: pb.created.toInt(),
      txid: pb.txid.isEmpty ? null : pb.txid,
      descriptor: pb.baseDescriptor.isEmpty ? null : pb.baseDescriptor,
      descriptorReceive: pb.descriptorReceive.isEmpty ? null : pb.descriptorReceive,
      descriptorChange: pb.descriptorChange.isEmpty ? null : pb.descriptorChange,
      watchWalletName: pb.watchWalletName.isEmpty ? null : pb.watchWalletName,
      addresses: {
        'receive': pb.receiveAddresses
            .map(
              (a) => AddressInfo(
                index: a.index,
                address: a.address,
                used: a.used,
              ),
            )
            .toList(),
        'change': pb.changeAddresses
            .map(
              (a) => AddressInfo(
                index: a.index,
                address: a.address,
                used: a.used,
              ),
            )
            .toList(),
      },
      utxoDetails: pb.utxoDetails
          .map(
            (u) => UtxoInfo(
              txid: u.txid,
              vout: u.vout,
              address: u.address,
              amount: u.amount,
              confirmations: u.confirmations,
              scriptPubKey: u.scriptPubKey.isEmpty ? null : u.scriptPubKey,
              spendable: u.spendable,
              solvable: u.solvable,
              safe: u.safe,
            ),
          )
          .toList(),
      balance: pb.balance,
      utxos: pb.utxos,
      nextReceiveIndex: pb.nextReceiveIndex,
      nextChangeIndex: pb.nextChangeIndex,
      transactionIds: pb.transactionIds.toList(),
    );
  }

  static multisigpb.MultisigGroup _groupToProto(MultisigGroup g) {
    return multisigpb.MultisigGroup(
      id: g.id,
      name: g.name,
      n: g.n,
      m: g.m,
      keys: g.keys
          .map(
            (k) => multisigpb.MultisigKey(
              owner: k.owner,
              xpub: k.xpub,
              derivationPath: k.derivationPath,
              fingerprint: k.fingerprint ?? '',
              originPath: k.originPath ?? '',
              isWallet: k.isWallet,
              activePsbts: k.activePSBTs ?? {},
              initialPsbts: k.initialPSBTs ?? {},
            ),
          )
          .toList(),
      created: Int64(g.created),
      txid: g.txid ?? '',
      baseDescriptor: g.descriptor ?? '',
      descriptorReceive: g.descriptorReceive ?? '',
      descriptorChange: g.descriptorChange ?? '',
      watchWalletName: g.watchWalletName ?? '',
      receiveAddresses: (g.addresses['receive'] ?? [])
          .map(
            (a) => multisigpb.AddressInfo(
              index: a.index,
              address: a.address,
              used: a.used,
            ),
          )
          .toList(),
      changeAddresses: (g.addresses['change'] ?? [])
          .map(
            (a) => multisigpb.AddressInfo(
              index: a.index,
              address: a.address,
              used: a.used,
            ),
          )
          .toList(),
      utxoDetails: g.utxoDetails
          .map(
            (u) => multisigpb.UtxoDetail(
              txid: u.txid,
              vout: u.vout,
              address: u.address,
              amount: u.amount,
              confirmations: u.confirmations,
              scriptPubKey: u.scriptPubKey ?? '',
              spendable: u.spendable,
              solvable: u.solvable,
              safe: u.safe,
            ),
          )
          .toList(),
      balance: g.balance,
      utxos: g.utxos,
      nextReceiveIndex: g.nextReceiveIndex,
      nextChangeIndex: g.nextChangeIndex,
      transactionIds: g.transactionIds,
    );
  }
}
