import 'dart:convert';

class CoreTransaction {
  final String address;
  final String category;
  final double amount;
  final String label;
  final int vout;
  final double fee;
  final int confirmations;
  final bool trusted;
  final String blockhash;
  final int blockindex;
  final int blocktime;
  final String txid;
  final DateTime time;
  final DateTime timereceived;
  final String comment;
  final String bip125Replaceable;
  final bool abandoned;
  final String raw;

  CoreTransaction({
    required this.address,
    required this.category,
    required this.amount,
    required this.label,
    required this.vout,
    required this.fee,
    required this.confirmations,
    required this.trusted,
    required this.blockhash,
    required this.blockindex,
    required this.blocktime,
    required this.txid,
    required this.time,
    required this.timereceived,
    required this.comment,
    required this.bip125Replaceable,
    required this.abandoned,
    required this.raw,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CoreTransaction && other.raw == raw;
  }

  @override
  int get hashCode => Object.hash(txid, raw);

  factory CoreTransaction.fromMap(Map<String, dynamic> map) {
    return CoreTransaction(
      address: map['address'] ?? '',
      category: map['category'] ?? '',
      amount: map['amount'] ?? 0.0,
      label: map['label'] ?? '',
      vout: map['vout'] ?? 0,
      fee: map['fee'] ?? 0.0,
      confirmations: map['confirmations'] ?? 0,
      trusted: map['trusted'] ?? false,
      blockhash: map['blockhash'] ?? '',
      blockindex: map['blockindex'] ?? 0,
      blocktime: map['blocktime'] ?? 0,
      txid: map['txid'] ?? '',
      time: DateTime.fromMillisecondsSinceEpoch((map['time'] ?? 0) * 1000),
      timereceived: DateTime.fromMillisecondsSinceEpoch((map['timereceived'] ?? 0) * 1000),
      comment: map['comment'] ?? '',
      bip125Replaceable: map['bip125-replaceable'] ?? 'unknown',
      abandoned: map['abandoned'] ?? false,
      raw: jsonEncode(map),
    );
  }

  static CoreTransaction fromJson(String json) => CoreTransaction.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
    'address': address,
    'category': category,
    'amount': amount,
    'label': label,
    'vout': vout,
    'fee': fee,
    'confirmations': confirmations,
    'trusted': trusted,
    'blockhash': blockhash,
    'blockindex': blockindex,
    'blocktime': blocktime,
    'txid': txid,
    'time': time.millisecondsSinceEpoch ~/ 1000,
    'timereceived': timereceived.millisecondsSinceEpoch ~/ 1000,
    'comment': comment,
    'bip125-replaceable': bip125Replaceable,
    'abandoned': abandoned,
  };
}
