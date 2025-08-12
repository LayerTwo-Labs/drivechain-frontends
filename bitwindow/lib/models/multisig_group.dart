import 'package:bitwindow/widgets/create_multisig_modal.dart';

class MultisigGroup {
  final String id;
  final String name;
  final int n;
  final int m;
  final List<MultisigKey> keys;
  final int created;
  final String? txid;
  
  final String? descriptor;
  final String? descriptorReceive;
  final String? descriptorChange;
  final String? watchWalletName;
  final Map<String, List<AddressInfo>> addresses;
  final List<UtxoInfo> utxoDetails;
  final double balance;
  final int utxos;
  final int nextReceiveIndex;
  final int nextChangeIndex;
  final List<String> transactionIds;
  
  MultisigGroup({
    required this.id,
    required this.name,
    required this.n,
    required this.m,
    required this.keys,
    required this.created,
    this.txid,
    this.descriptor,
    this.descriptorReceive,
    this.descriptorChange,
    this.watchWalletName,
    Map<String, List<AddressInfo>>? addresses,
    List<UtxoInfo>? utxoDetails,
    this.balance = 0.0,
    this.utxos = 0,
    this.nextReceiveIndex = 0,
    this.nextChangeIndex = 0,
    List<String>? transactionIds,
  }) : addresses = addresses ?? {'receive': [], 'change': []},
       utxoDetails = utxoDetails ?? [],
       transactionIds = transactionIds ?? [];

  factory MultisigGroup.fromJson(Map<String, dynamic> json) {
    return MultisigGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      n: json['n'] ?? 0,
      m: json['m'] ?? 0,
      keys: (json['keys'] as List<dynamic>?)
              ?.map((k) => MultisigKey.fromJson(k))
              .toList() ??
          [],
      created: json['created'] ?? 0,
      txid: json['txid'],
      descriptor: json['descriptor'],
      descriptorReceive: json['descriptorReceive'] ?? json['descriptor_receive'],
      descriptorChange: json['descriptorChange'] ?? json['descriptor_change'],
      watchWalletName: json['watch_wallet_name'] ?? 'multisig_${json['id']}',
      addresses: _parseAddresses(json['addresses']),
      utxoDetails: _parseUtxos(json['utxo_details']),
      balance: (json['balance'] ?? 0.0).toDouble(),
      utxos: json['utxos'] ?? 0,
      nextReceiveIndex: json['next_receive_index'] ?? 0,
      nextChangeIndex: json['next_change_index'] ?? 0,
      transactionIds: List<String>.from(json['transaction_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'n': n,
        'm': m,
        'keys': keys.map((k) => k.toJson()).toList(),
        'created': created,
        'txid': txid,
        'descriptor': descriptor,
        'descriptorReceive': descriptorReceive,
        'descriptorChange': descriptorChange,
        'watch_wallet_name': watchWalletName,
        'addresses': {
          'receive': addresses['receive']?.map((a) => a.toJson()).toList() ?? [],
          'change': addresses['change']?.map((a) => a.toJson()).toList() ?? [],
        },
        'utxo_details': utxoDetails.map((u) => u.toJson()).toList(),
        'balance': balance,
        'utxos': utxos,
        'next_receive_index': nextReceiveIndex,
        'next_change_index': nextChangeIndex,
        'transaction_ids': transactionIds,
      };

  static Map<String, List<AddressInfo>> _parseAddresses(dynamic json) {
    if (json == null) return {'receive': [], 'change': []};
    final Map<String, List<AddressInfo>> result = {'receive': [], 'change': []};
    if (json is Map) {
      if (json['receive'] is List) {
        result['receive'] = (json['receive'] as List)
            .map((a) => AddressInfo.fromJson(a))
            .toList();
      }
      if (json['change'] is List) {
        result['change'] = (json['change'] as List)
            .map((a) => AddressInfo.fromJson(a))
            .toList();
      }
    }
    return result;
  }

  static List<UtxoInfo> _parseUtxos(dynamic json) {
    if (json == null || json is! List) return [];
    return json.map((u) => UtxoInfo.fromJson(u)).toList();
  }

  String get participantNames => keys.map((k) => k.owner).join(', ');
  
  List<String> get allAddresses {
    final List<String> all = [];
    addresses['receive']?.forEach((a) => all.add(a.address));
    addresses['change']?.forEach((a) => all.add(a.address));
    return all;
  }
  bool get hasDescriptor => (descriptor != null && descriptor!.isNotEmpty) ||
      (descriptorReceive != null && descriptorReceive!.isNotEmpty);
  bool get hasRangedDescriptors => true;

  MultisigGroup copyWith({
    String? id,
    String? name,
    int? n,
    int? m,
    List<MultisigKey>? keys,
    int? created,
    String? txid,
    String? descriptor,
    String? descriptorReceive,
    String? descriptorChange,
    String? watchWalletName,
    Map<String, List<AddressInfo>>? addresses,
    List<UtxoInfo>? utxoDetails,
    double? balance,
    int? utxos,
    int? nextReceiveIndex,
    int? nextChangeIndex,
    List<String>? transactionIds,
  }) {
    return MultisigGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      n: n ?? this.n,
      m: m ?? this.m,
      keys: keys ?? this.keys,
      created: created ?? this.created,
      txid: txid ?? this.txid,
      descriptor: descriptor ?? this.descriptor,
      descriptorReceive: descriptorReceive ?? this.descriptorReceive,
      descriptorChange: descriptorChange ?? this.descriptorChange,
      watchWalletName: watchWalletName ?? this.watchWalletName,
      addresses: addresses ?? this.addresses,
      utxoDetails: utxoDetails ?? this.utxoDetails,
      balance: balance ?? this.balance,
      utxos: utxos ?? this.utxos,
      nextReceiveIndex: nextReceiveIndex ?? this.nextReceiveIndex,
      nextChangeIndex: nextChangeIndex ?? this.nextChangeIndex,
      transactionIds: transactionIds ?? this.transactionIds,
    );
  }
}

class AddressInfo {
  final int index;
  final String address;
  final bool used;
  AddressInfo({
    required this.index,
    required this.address,
    this.used = false,
  });
  factory AddressInfo.fromJson(Map<String, dynamic> json) => AddressInfo(
        index: json['index'] ?? 0,
        address: json['address'] ?? '',
        used: json['used'] ?? false,
      );
  Map<String, dynamic> toJson() => {
        'index': index,
        'address': address,
        'used': used,
      };
}

class UtxoInfo {
  final String txid;
  final int vout;
  final String address;
  final double amount;
  final int confirmations;
  final String? scriptPubKey;
  final bool spendable;
  final bool solvable;
  final bool safe;
  
  UtxoInfo({
    required this.txid,
    required this.vout,
    required this.address,
    required this.amount,
    required this.confirmations,
    this.scriptPubKey,
    this.spendable = true,
    this.solvable = true,
    this.safe = true,
  });
  
  factory UtxoInfo.fromJson(Map<String, dynamic> json) => UtxoInfo(
        txid: json['txid'] ?? '',
        vout: json['vout'] ?? 0,
        address: json['address'] ?? '',
        amount: (json['amount'] ?? 0.0).toDouble(),
        confirmations: json['confirmations'] ?? 0,
        scriptPubKey: json['scriptPubKey'],
        spendable: json['spendable'] ?? true,
        solvable: json['solvable'] ?? true,
        safe: json['safe'] ?? true,
      );
  Map<String, dynamic> toJson() => {
        'txid': txid,
        'vout': vout,
        'address': address,
        'amount': amount,
        'confirmations': confirmations,
        'scriptPubKey': scriptPubKey,
        'spendable': spendable,
        'solvable': solvable,
        'safe': safe,
      };
  Map<String, dynamic> get outpoint => {
        'txid': txid,
        'vout': vout,
      };
}