import 'dart:convert';

class UTXO {
  final String txid;
  final int vout;
  final String address;
  final String account;
  final String redeemScript;
  final String scriptPubKey;
  final double amount;
  final int confirmations;
  final bool spendable;
  final bool solvable;
  final bool safe;
  final int? time;
  final String raw;

  UTXO({
    required this.txid,
    required this.vout,
    required this.address,
    required this.account,
    required this.redeemScript,
    required this.scriptPubKey,
    required this.amount,
    required this.confirmations,
    required this.spendable,
    required this.solvable,
    required this.safe,
    required this.time,
    required this.raw,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UTXO && other.raw == raw;
  }

  @override
  int get hashCode => Object.hash(txid, raw);

  factory UTXO.fromMap(Map<String, dynamic> map) {
    return UTXO(
      txid: map['txid'] ?? '',
      vout: map['vout'] ?? 0,
      address: map['address'] ?? '',
      account: map['account'] ?? '',
      redeemScript: map['redeemScript'] ?? '',
      scriptPubKey: map['scriptPubKey'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      confirmations: map['confirmations'] ?? 0,
      spendable: map['spendable'] ?? false,
      solvable: map['solvable'] ?? false,
      safe: map['safe'] ?? false,
      time: map['time'],
      raw: jsonEncode(map),
    );
  }

  static UTXO fromJson(String json) => UTXO.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
    'txid': txid,
    'vout': vout,
    'address': address,
    'account': account,
    'redeemScript': redeemScript,
    'scriptPubKey': scriptPubKey,
    'amount': amount,
    'confirmations': confirmations,
    'spendable': spendable,
    'solvable': solvable,
    'safe': safe,
    'time': time,
    'raw': raw,
  };
}
