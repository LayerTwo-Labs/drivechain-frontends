import 'dart:convert';

class ShieldedUTXO {
  final String txid;
  final String pool;
  final String type;
  final int outindex;
  final int confirmations;
  final bool spendable;
  final String address;
  final double amount;
  final double amountZat;
  final String memo;
  final bool change;
  final String raw;

  ShieldedUTXO({
    required this.txid,
    required this.pool,
    required this.type,
    required this.outindex,
    required this.confirmations,
    required this.spendable,
    required this.address,
    required this.amount,
    required this.amountZat,
    required this.memo,
    required this.change,
    required this.raw,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ShieldedUTXO && other.raw == raw;
  }

  @override
  int get hashCode => Object.hash(
        txid,
        raw,
      );

  factory ShieldedUTXO.fromMap(Map<String, dynamic> map) {
    return ShieldedUTXO(
      txid: map['txid'] ?? '',
      pool: map['pool'] ?? '',
      type: map['type'] ?? '',
      outindex: map['outindex'] ?? 0,
      confirmations: map['confirmations'] ?? 0,
      spendable: map['spendable'] ?? false,
      address: map['address'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      amountZat: map['amountZat']?.toDouble() ?? 0.0,
      memo: map['memo'] ?? '',
      change: map['change'] ?? false,
      raw: map['raw'] ?? jsonEncode(map),
    );
  }

  static ShieldedUTXO fromJson(String json) => ShieldedUTXO.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'txid': txid,
      'pool': pool,
      'type': type,
      'outindex': outindex,
      'confirmations': confirmations,
      'spendable': spendable,
      'address': address,
      'amount': amount,
      'amountZat': amountZat,
      'memo': memo,
      'change': change,
      'raw': raw,
    };
  }
}

class UnshieldedUTXO {
  final String txid;
  final String address;
  final double amount;
  final int confirmations;
  final bool generated;
  final String raw;

  UnshieldedUTXO({
    required this.txid,
    required this.address,
    required this.amount,
    required this.confirmations,
    required this.generated,
    required this.raw,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UnshieldedUTXO && other.raw == raw;
  }

  @override
  int get hashCode => Object.hash(
        txid,
        raw,
      );

  factory UnshieldedUTXO.fromMap(Map<String, dynamic> map) {
    return UnshieldedUTXO(
      txid: map['txid'] ?? '',
      address: map['address'] ?? '',
      amount: map['amount'] ?? 0.0,
      confirmations: map['confirmations'] ?? 0.0,
      generated: map['generated'] ?? 0.0,
      raw: jsonEncode(map),
    );
  }

  static UnshieldedUTXO fromJson(String json) => UnshieldedUTXO.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'txid': txid,
        'address': address,
        'amount': amount,
        'confirmations': confirmations,
        'generated': generated,
      };
}

class OperationStatus {
  final String id;
  final String status;
  final String error;
  final String method;
  final String params;
  final DateTime creationTime;
  final String raw;

  OperationStatus({
    required this.id,
    required this.status,
    required this.error,
    required this.method,
    required this.params,
    required this.creationTime,
    required this.raw,
  });

  factory OperationStatus.fromMap(Map<String, dynamic> map) {
    return OperationStatus(
      id: map['id'] ?? '',
      status: map['status'] ?? '',
      error: map.containsKey('error') ? jsonEncode(map['error']) : '',
      method: map['method'] ?? '',
      params: jsonEncode(map['params']),
      creationTime: DateTime.fromMillisecondsSinceEpoch((map['creation_time'] ?? 0) * 1000),
      raw: jsonEncode(map),
    );
  }

  static OperationStatus fromJson(String json) => OperationStatus.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
        'id': id,
        'statu': status,
        'error': error,
        'method': method,
        'params': params,
        'creation_time': creationTime.millisecondsSinceEpoch ~/ 1000,
      };
}
