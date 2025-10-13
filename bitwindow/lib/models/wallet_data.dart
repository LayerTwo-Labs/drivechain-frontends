import 'dart:convert';

/// Main wallet data structure containing all wallet information
class WalletData {
  final int version;
  final MasterWallet master;
  final L1Wallet l1;
  final List<SidechainWallet> sidechains;

  WalletData({
    required this.version,
    required this.master,
    required this.l1,
    required this.sidechains,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'master': master.toJson(),
      'l1': l1.toJson(),
      'sidechains': sidechains.map((s) => s.toJson()).toList(),
    };
  }

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      version: json['version'] as int? ?? 1,
      master: MasterWallet.fromJson(json['master'] as Map<String, dynamic>),
      l1: L1Wallet.fromJson(json['l1'] as Map<String, dynamic>),
      sidechains:
          (json['sidechains'] as List<dynamic>?)
              ?.map((s) => SidechainWallet.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory WalletData.fromJsonString(String jsonString) {
    return WalletData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}

/// Master wallet containing the root seed and keys
class MasterWallet {
  final String mnemonic;
  final String seedHex;
  final String masterKey;
  final String chainCode;
  final String? bip39Binary;
  final String? bip39Checksum;
  final String? bip39ChecksumHex;
  final String name;

  MasterWallet({
    required this.mnemonic,
    required this.seedHex,
    required this.masterKey,
    required this.chainCode,
    this.bip39Binary,
    this.bip39Checksum,
    this.bip39ChecksumHex,
    this.name = 'Master',
  });

  Map<String, dynamic> toJson() {
    final json = {
      'mnemonic': mnemonic,
      'seed_hex': seedHex,
      'master_key': masterKey,
      'chain_code': chainCode,
      'name': name,
    };

    if (bip39Binary != null) json['bip39_binary'] = bip39Binary!;
    if (bip39Checksum != null) json['bip39_checksum'] = bip39Checksum!;
    if (bip39ChecksumHex != null) json['bip39_checksum_hex'] = bip39ChecksumHex!;

    return json;
  }

  factory MasterWallet.fromJson(Map<String, dynamic> json) {
    return MasterWallet(
      mnemonic: json['mnemonic'] as String,
      seedHex: json['seed_hex'] as String,
      masterKey: json['master_key'] as String,
      chainCode: json['chain_code'] as String,
      bip39Binary: json['bip39_binary'] as String?,
      bip39Checksum: json['bip39_checksum'] as String?,
      bip39ChecksumHex: json['bip39_checksum_hex'] as String?,
      name: json['name'] as String? ?? 'Master',
    );
  }
}

/// Layer 1 (Bitcoin Core) wallet
class L1Wallet {
  final String mnemonic;
  final String name;

  L1Wallet({
    required this.mnemonic,
    this.name = 'Bitcoin Core (Patched)',
  });

  Map<String, dynamic> toJson() {
    return {
      'mnemonic': mnemonic,
      'name': name,
    };
  }

  factory L1Wallet.fromJson(Map<String, dynamic> json) {
    return L1Wallet(
      mnemonic: json['mnemonic'] as String,
      name: json['name'] as String? ?? 'Bitcoin Core (Patched)',
    );
  }
}

/// Sidechain wallet
class SidechainWallet {
  final int slot;
  final String name;
  final String mnemonic;

  SidechainWallet({
    required this.slot,
    required this.name,
    required this.mnemonic,
  });

  Map<String, dynamic> toJson() {
    return {
      'slot': slot,
      'name': name,
      'mnemonic': mnemonic,
    };
  }

  factory SidechainWallet.fromJson(Map<String, dynamic> json) {
    return SidechainWallet(
      slot: json['slot'] as int,
      name: json['name'] as String,
      mnemonic: json['mnemonic'] as String,
    );
  }
}
