import 'package:bitwindow/models/multisig_group_enhanced.dart';

/// Transaction status for multisig PSBT workflow
enum TxStatus {
  needsSignatures,
  readyForBroadcast,
  broadcasted,
  confirmed,
  completed,
  voided,
}

extension TxStatusExtension on TxStatus {
  String get displayName {
    switch (this) {
      case TxStatus.needsSignatures:
        return 'Needs Signatures';
      case TxStatus.readyForBroadcast:
        return 'Ready to Broadcast';
      case TxStatus.broadcasted:
        return 'Broadcasted';
      case TxStatus.confirmed:
        return 'Confirmed';
      case TxStatus.completed:
        return 'Completed';
      case TxStatus.voided:
        return 'Voided';
    }
  }

  static TxStatus fromString(String status) {
    switch (status) {
      case 'needsSignatures':
        return TxStatus.needsSignatures;
      case 'readyForBroadcast':
        return TxStatus.readyForBroadcast;
      case 'broadcasted':
        return TxStatus.broadcasted;
      case 'confirmed':
        return TxStatus.confirmed;
      case 'completed':
        return TxStatus.completed;
      case 'voided':
        return TxStatus.voided;
      default:
        throw ArgumentError('Unknown TxStatus: $status');
    }
  }

  String toJson() => toString().split('.').last;
}


/// Key-specific PSBT signing status
class KeyPSBTStatus {
  final String keyId; // xpub or key identifier
  final String? psbt; // The PSBT for this key
  final bool isSigned;
  final DateTime? signedAt;
  
  const KeyPSBTStatus({
    required this.keyId,
    this.psbt,
    required this.isSigned,
    this.signedAt,
  });
  
  factory KeyPSBTStatus.fromJson(Map<String, dynamic> json) {
    return KeyPSBTStatus(
      keyId: json['keyId'] as String,
      psbt: json['psbt'] as String?,
      isSigned: json['isSigned'] as bool,
      signedAt: json['signedAt'] != null 
        ? DateTime.parse(json['signedAt'] as String)
        : null,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'keyId': keyId,
    'psbt': psbt,
    'isSigned': isSigned,
    'signedAt': signedAt?.toIso8601String(),
  };
}

/// Multisig transaction tracking PSBT workflow state
class MultisigTransaction {
  final String id; // MuSIG_TXID
  final String groupId;
  final String initialPSBT;
  final List<KeyPSBTStatus> keyPSBTs; // Track each key's PSBT status
  final String? combinedPSBT;
  final String? finalHex;
  final String? txid;
  final TxStatus status;
  final DateTime created;
  final DateTime? broadcastTime;
  final double amount;
  final String destination;
  final double fee;
  final List<UtxoInfo> inputs;
  final int confirmations;

  const MultisigTransaction({
    required this.id,
    required this.groupId,
    required this.initialPSBT,
    this.keyPSBTs = const [],
    this.combinedPSBT,
    this.finalHex,
    this.txid,
    this.status = TxStatus.needsSignatures,
    required this.created,
    this.broadcastTime,
    required this.amount,
    required this.destination,
    required this.fee,
    required this.inputs,
    this.confirmations = 0,
  });
  
  // Helper getters
  List<String> get signedPSBTs => keyPSBTs
    .where((k) => k.isSigned && k.psbt != null)
    .map((k) => k.psbt!)
    .toList();
    
  int get signatureCount => keyPSBTs.where((k) => k.isSigned).length;
  
  // Note: This should be the threshold (m), not total keys (n)
  // The actual threshold is passed via TransactionStorage.updateKeyPSBT
  int get requiredSignatures => keyPSBTs.length; // This is wrong, but kept for compatibility

  factory MultisigTransaction.fromJson(Map<String, dynamic> json) {
    return MultisigTransaction(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      initialPSBT: json['initialPSBT'] as String,
      keyPSBTs: (json['keyPSBTs'] as List<dynamic>?)
        ?.map((k) => KeyPSBTStatus.fromJson(k as Map<String, dynamic>))
        .toList() ?? [],
      combinedPSBT: json['combinedPSBT'] as String?,
      finalHex: json['finalHex'] as String?,
      txid: json['txid'] as String?,
      status: TxStatusExtension.fromString(json['status'] as String),
      created: DateTime.parse(json['created'] as String),
      broadcastTime: json['broadcastTime'] != null
          ? DateTime.parse(json['broadcastTime'] as String)
          : null,
      amount: (json['amount'] as num).toDouble(),
      destination: json['destination'] as String,
      fee: (json['fee'] as num).toDouble(),
      inputs: (json['inputs'] as List<dynamic>)
          .map((input) => UtxoInfo.fromJson(input as Map<String, dynamic>))
          .toList(),
      confirmations: json['confirmations'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'initialPSBT': initialPSBT,
      'keyPSBTs': keyPSBTs.map((k) => k.toJson()).toList(),
      if (combinedPSBT != null) 'combinedPSBT': combinedPSBT,
      if (finalHex != null) 'finalHex': finalHex,
      if (txid != null) 'txid': txid,
      'status': status.toJson(),
      'created': created.toIso8601String(),
      if (broadcastTime != null) 'broadcastTime': broadcastTime!.toIso8601String(),
      'amount': amount,
      'destination': destination,
      'fee': fee,
      'inputs': inputs.map((input) => input.toJson()).toList(),
      'confirmations': confirmations,
    };
  }

  /// Create a copy with updated fields
  MultisigTransaction copyWith({
    String? id,
    String? groupId,
    String? initialPSBT,
    List<KeyPSBTStatus>? keyPSBTs,
    String? combinedPSBT,
    String? finalHex,
    String? txid,
    TxStatus? status,
    DateTime? created,
    DateTime? broadcastTime,
    double? amount,
    String? destination,
    double? fee,
    List<UtxoInfo>? inputs,
    int? confirmations,
  }) {
    return MultisigTransaction(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      initialPSBT: initialPSBT ?? this.initialPSBT,
      keyPSBTs: keyPSBTs ?? this.keyPSBTs,
      combinedPSBT: combinedPSBT ?? this.combinedPSBT,
      finalHex: finalHex ?? this.finalHex,
      txid: txid ?? this.txid,
      status: status ?? this.status,
      created: created ?? this.created,
      broadcastTime: broadcastTime ?? this.broadcastTime,
      amount: amount ?? this.amount,
      destination: destination ?? this.destination,
      fee: fee ?? this.fee,
      inputs: inputs ?? this.inputs,
      confirmations: confirmations ?? this.confirmations,
    );
  }

  /// Get short transaction ID for display
  String get shortId => id.length > 8 ? '${id.substring(0, 8)}...' : id;

  /// Get short txid for display if broadcasted
  String? get shortTxid => txid != null && txid!.length > 8 
      ? '${txid!.substring(0, 8)}...' 
      : txid;

  /// Check if transaction needs more signatures
  bool get needsMoreSignatures {
    return status == TxStatus.needsSignatures && signedPSBTs.isEmpty;
  }

  /// Check if transaction is ready to combine
  bool get readyToCombine {
    return status == TxStatus.needsSignatures && signedPSBTs.isNotEmpty;
  }

  /// Check if transaction can be broadcasted
  bool get canBroadcast {
    return status == TxStatus.readyForBroadcast && finalHex != null;
  }
}