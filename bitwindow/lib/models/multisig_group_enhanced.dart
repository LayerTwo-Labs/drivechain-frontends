import 'package:bitwindow/widgets/create_multisig_modal.dart';

/// Enhanced MultisigGroup with full Bitcoin Core integration support
class MultisigGroupEnhanced {
  final String id;
  final String name;
  final int n;
  final int m;
  final List<MultisigKey> keys;
  final int created;
  final String? txid;
  
  // New fields for Bitcoin Core integration
  final String? descriptor;  // Full descriptor with checksum (legacy, single address)
  final String? descriptorReceive;  // Ranged descriptor for receive addresses
  final String? descriptorChange;   // Ranged descriptor for change addresses
  final String? watchWalletName;    // Name of watch-only wallet in Core
  final Map<String, List<AddressInfo>> addresses;  // receive/change addresses
  final List<UtxoInfo> utxoDetails;  // Detailed UTXO information
  final double balance;  // Total balance in BTC
  final int utxos;  // UTXO count
  final int nextReceiveIndex;  // For address generation
  final int nextChangeIndex;   // For change addresses
  
  MultisigGroupEnhanced({
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
  }) : addresses = addresses ?? {'receive': [], 'change': []},
       utxoDetails = utxoDetails ?? [];

  factory MultisigGroupEnhanced.fromJson(Map<String, dynamic> json) {
    return MultisigGroupEnhanced(
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
      descriptor: json['descriptor'], // Legacy field, may be null
      descriptorReceive: json['descriptor_receive'], // Legacy field, may be null
      descriptorChange: json['descriptor_change'], // Legacy field, may be null
      watchWalletName: json['watch_wallet_name'] ?? 'multisig_${json['id']}', // Generate default
      addresses: _parseAddresses(json['addresses']), // May be null
      utxoDetails: _parseUtxos(json['utxo_details']), // May be null
      balance: (json['balance'] ?? 0.0).toDouble(), // Default to 0
      utxos: json['utxos'] ?? 0, // Default to 0
      nextReceiveIndex: json['next_receive_index'] ?? 0, // Default to 0
      nextChangeIndex: json['next_change_index'] ?? 0, // Default to 0
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
        'descriptor_receive': descriptorReceive,
        'descriptor_change': descriptorChange,
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
  
  /// Get all addresses (both receive and change)
  List<String> get allAddresses {
    final List<String> all = [];
    addresses['receive']?.forEach((a) => all.add(a.address));
    addresses['change']?.forEach((a) => all.add(a.address));
    return all;
  }
  
  /// Check if this group has a valid descriptor (legacy or ranged)
  bool get hasDescriptor => (descriptor != null && descriptor!.isNotEmpty) ||
      (descriptorReceive != null && descriptorReceive!.isNotEmpty);
  
  /// Check if this group uses ranged descriptors (xPub-based)
  /// Since we've moved to xpub-only model, all groups are now xpub-based
  bool get hasRangedDescriptors => true;
}

/// Address information with index
class AddressInfo {
  final int index;
  final String address;
  final bool used;  // Has received funds
  
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

/// UTXO information from Bitcoin Core
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
  
  /// Get outpoint for PSBT creation
  Map<String, dynamic> get outpoint => {
        'txid': txid,
        'vout': vout,
      };
}