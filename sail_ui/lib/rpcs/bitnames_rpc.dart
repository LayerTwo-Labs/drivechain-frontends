import 'dart:convert';

import 'package:convert/convert.dart' show hex;
import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/sidechains.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/settings/client_settings.dart';
import 'package:sail_ui/settings/hash_plaintext_settings.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// API to the bitnames server.
abstract class BitnamesRPC extends SidechainRPC {
  BitnamesRPC({
    required super.conf,
    required super.binary,
    required super.restartOnFailure,
    required super.chain,
  });

  /// Get balance in sats
  Future<BalanceResponse> getBalance();

  /// Get BitName data
  Future<BitNameData?> getBitNameData(String name);

  /// List all BitNames
  Future<List<BitnameEntry>> listBitNames();

  /// Connect to a peer
  Future<void> connectPeer(String address);

  /// List peers
  Future<List<BitnamesPeerInfo>> listPeers();

  /// Register a BitName
  Future<String> registerBitName(String plainName, BitNameData? data);

  /// Reserve a BitName
  Future<String> reserveBitName(String name);

  /// Get block data
  Future<Map<String, dynamic>?> getBlock(String hash);

  /// Get mainchain blocks that commit to a specified block hash
  Future<String> getBMMInclusions(String blockHash);

  /// Get the best known mainchain block hash
  Future<String?> getBestMainchainBlockHash();

  /// Get the best sidechain block hash known by Bitnames
  Future<String?> getBestSidechainBlockHash();

  /// Get the height of the latest failed withdrawal bundle
  Future<int?> getLatestFailedWithdrawalBundleHeight();

  /// Get pending withdrawal bundle
  Future<Map<String, dynamic>?> getPendingWithdrawalBundle();

  /// Generate a mnemonic seed phrase
  Future<String> generateMnemonic();

  /// Set the wallet seed from a mnemonic seed phrase
  Future<void> setSeedFromMnemonic(String mnemonic);

  /// Get total sidechain wealth in sats
  Future<int> getSidechainWealth();

  /// Get a new encryption key
  Future<String> getNewEncryptionKey();

  /// Get a new verifying/signing key
  Future<String> getNewVerifyingKey();

  /// Create a deposit to an address
  Future<String> createDeposit({required String address, required int feeSats, required int valueSats});

  /// Decrypt a message with the specified encryption key
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey});

  /// Encrypt a message to the specified encryption pubkey
  Future<String> encryptMsg({required String msg, required String encryptionPubkey});

  /// Get a new address
  Future<String> getNewAddress();

  /// Get the current block count
  Future<int> getBlockCount();

  /// Get all paymail
  Future<Map<String, dynamic>> getPaymail();

  /// Get wallet addresses, sorted by base58 encoding
  Future<List<String>> getWalletAddresses();

  /// Get wallet UTXOs
  Future<List<dynamic>> getWalletUTXOs();

  /// List all UTXOs
  @override
  Future<List<SidechainUTXO>> listUTXOs();

  /// List owned UTXOs
  Future<List<dynamic>> myUTXOs();

  /// Get OpenAPI schema
  Future<Map<String, dynamic>> openapiSchema();

  /// Resolve a commitment from a BitName
  Future<String> resolveCommit(String bitname);

  /// Sign an arbitrary message with the specified verifying key
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey});

  /// Sign an arbitrary message with the secret key for the specified address
  Future<Map<String, String>> signArbitraryMsgAsAddr({required String msg, required String address});

  /// Stop the node
  @override
  Future<void> stop();

  /// Transfer funds to the specified address
  Future<String> transfer({required String dest, required int value, required int fee, String? memo});

  /// Initiate a withdrawal to the specified mainchain address
  Future<String> withdraw({
    required String mainchainAddress,
    required int amountSats,
    required int feeSats,
    required int mainchainFeeSats,
  });
}

class BitnamesLive extends BitnamesRPC {
  RPCClient _client() {
    final client = RPCClient(
      host: '127.0.0.1',
      port: binary.port,
      username: conf.username,
      password: conf.password,
      useSSL: false,
    );

    client.dioClient = Dio();
    return client;
  }

  // Private constructor
  BitnamesLive._create({
    required super.conf,
    required super.binary,
    required super.restartOnFailure,
    required super.chain,
  });

  // Async factory
  static Future<BitnamesLive> create({
    required Binary binary,
    required Sidechain chain,
  }) async {
    final conf = await readConf();

    final instance = BitnamesLive._create(
      conf: conf,
      binary: binary,
      restartOnFailure: true,
      chain: chain,
    );

    await instance._init();
    return instance;
  }

  Future<void> _init() async {
    await startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    return ['--headless'] + binary.extraBootArgs;
  }

  @override
  Future<int> ping() async {
    final response = await getBalance();
    return response.totalSats;
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<(double confirmed, double unconfirmed)> balance() async {
    final response = await getBalance();
    final confirmed = satoshiToBTC(response.availableSats);
    final unconfirmed = satoshiToBTC(response.totalSats - response.availableSats);
    return (confirmed, unconfirmed);
  }

  @override
  Future<void> stopRPC() async {
    await _client().call('stop');
    // can't trust the rpc, give it a moment to stop
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final blocks = await _client().call('getblockcount') as int;
    // can't trust the rpc, give it a moment to stop
    await Future.delayed(const Duration(seconds: 5));
    return BlockchainInfo(
      chain: 'signet',
      blocks: blocks,
      headers: blocks,
      bestBlockHash: '',
      difficulty: 0,
      time: 0,
      medianTime: 0,
      verificationProgress: 100.0,
      initialBlockDownload: false,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  List<String> getMethods() {
    return bitnamesRPCMethods;
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    return await _client().call(method, params).catchError((err) {
      log.t('rpc: $method threw exception: $err');
      throw err;
    });
  }

  @override
  Future<String> getDepositAddress() async {
    final response = await _client().call('get_new_address') as String;
    return formatDepositAddress(response, chain.slot);
  }

  @override
  Future<String> getSideAddress() async {
    final response = await _client().call('get_new_address') as String;
    return response;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    throw UnimplementedError();
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) async {
    final response = await _client().call('withdraw', {
      'mainchain_address': address,
      'amount_sats': btcToSatoshi(amount),
      'fee_sats': btcToSatoshi(sidechainFee),
      'mainchain_fee_sats': btcToSatoshi(mainchainFee),
    });
    return response as String;
  }

  @override
  Future<double> sideEstimateFee() async {
    // Bitnames has fixed fees for now
    return 0.00001;
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final response = await _client().call('transfer', {
      'dest': address,
      'value': btcToSatoshi(amount),
      'fee': btcToSatoshi(0.00001), // Fixed fee
      'memo': null,
    });
    return response as String;
  }

  @override
  Future<BalanceResponse> getBalance() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    return BalanceResponse.fromJson(response);
  }

  @override
  Future<BitNameData?> getBitNameData(String name) async {
    final response = await _client().call('bitname_data', name) as Map<String, dynamic>?;
    return response != null ? BitNameData.fromJson(response) : null;
  }

  @override
  Future<List<BitnameEntry>> listBitNames() async {
    final clientSettings = GetIt.I.get<ClientSettings>();

    Map<String, String>? hashNameMapping;
    try {
      final settingValue = await clientSettings.getValue(HashNameMappingSetting());
      hashNameMapping = Map.fromEntries(
        settingValue.value.entries.map((e) => MapEntry(e.key, e.value.name)),
      );
    } catch (e) {
      // do nothing
    }

    final response = await _client().call('bitnames') as List<dynamic>;
    return response.map<BitnameEntry>((item) {
      if (item is! List || item.length != 2) {
        throw FormatException('Invalid bitname entry format: $item');
      }

      final hash = item[0] as String;
      final detailsMap = item[1] as Map<String, dynamic>;

      // Handle commitment which can be a List<int> or String
      String? parseCommitment(dynamic value) {
        if (value == null) return null;
        if (value is String) return value;
        if (value is List) {
          // Convert List<int> to hex string
          return value.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
        }
        return value.toString();
      }

      // Create a new map with the commitment properly parsed
      final parsedDetails = Map<String, dynamic>.from(detailsMap);
      if (detailsMap.containsKey('commitment')) {
        parsedDetails['commitment'] = parseCommitment(detailsMap['commitment']);
      }

      final details = BitnameDetails.fromJson(parsedDetails);
      return BitnameEntry(
        hash: hash,
        details: details,
        plaintextName: hashNameMapping?[hash],
      );
    }).toList();
  }

  @override
  Future<void> connectPeer(String address) async {
    await _client().call('connect_peer', address);
  }

  @override
  Future<List<BitnamesPeerInfo>> listPeers() async {
    final response = await _client().call('list_peers') as List<dynamic>;
    return response.map((e) => BitnamesPeerInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<String> registerBitName(String plainName, BitNameData? data) async {
    final response = await _client().call('register_bitname', [
      plainName,
      data?.toJson(),
    ]);
    return response as String;
  }

  @override
  Future<String> reserveBitName(String name) async {
    final response = await _client().call('reserve_bitname', [name]) as String;

    return response;
  }

  /// Additional methods from OpenAPI schema

  /// Sign an arbitrary message with the specified verifying key
  Future<String> signArbitraryMessage(String message, String verifyingKey) async {
    final response = await _client().call('sign_arbitrary_msg', {
      'msg': message,
      'verifying_key': verifyingKey,
    });
    return response as String;
  }

  /// Sign a message with the secret key for the specified address
  Future<Map<String, String>> signArbitraryMessageAsAddress(String message, String address) async {
    final response = await _client().call('sign_arbitrary_msg_as_addr', {
      'msg': message,
      'address': address,
    });
    return {
      'verifying_key': response['verifying_key'] as String,
      'signature': response['signature'] as String,
    };
  }

  /// Get paymail information
  @override
  Future<Map<String, dynamic>> getPaymail() async {
    final response = await _client().call('get_paymail');
    return response as Map<String, dynamic>;
  }

  @override
  Future<List<BitnamesUTXO>> listUTXOs() async {
    final response = await _client().call('get_wallet_utxos') as List<dynamic>;
    return response.map((e) => BitnamesUTXO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) async {
    final response = await _client().call('get_block', hash);
    return response as Map<String, dynamic>?;
  }

  @override
  Future<String> getBMMInclusions(String blockHash) async {
    final response = await _client().call('get_bmm_inclusions', blockHash);
    return response as String;
  }

  @override
  Future<String?> getBestMainchainBlockHash() async {
    final response = await _client().call('get_best_mainchain_block_hash');
    return response as String?;
  }

  @override
  Future<String?> getBestSidechainBlockHash() async {
    final response = await _client().call('get_best_sidechain_block_hash');
    return response as String?;
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async {
    final response = await _client().call('latest_failed_withdrawal_bundle_height');
    return response as int?;
  }

  @override
  Future<Map<String, dynamic>?> getPendingWithdrawalBundle() async {
    final response = await _client().call('pending_withdrawal_bundle');
    return response as Map<String, dynamic>?;
  }

  @override
  Future<String> generateMnemonic() async {
    final response = await _client().call('generate_mnemonic');
    return response as String;
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    await _client().call('set_seed_from_mnemonic', mnemonic);
  }

  @override
  Future<int> getSidechainWealth() async {
    final response = await _client().call('sidechain_wealth_sats');
    return response as int;
  }

  @override
  Future<String> getNewEncryptionKey() async {
    final response = await _client().call('get_new_encryption_key');
    return response as String;
  }

  @override
  Future<String> getNewVerifyingKey() async {
    final response = await _client().call('get_new_verifying_key');
    return response as String;
  }

  @override
  Future<String> createDeposit({required String address, required int feeSats, required int valueSats}) async {
    final response = await _client().call('create_deposit', {
      'address': address,
      'fee_sats': feeSats,
      'value_sats': valueSats,
    });
    return response as String;
  }

  @override
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey}) async {
    final response = await _client().call('decrypt_msg', [
      encryptionPubkey,
      ciphertext,
      true,
    ]);
    // convert hex to string
    final bytes = hex.decode(response as String);
    final decoded = utf8.decode(bytes);
    return decoded;
  }

  @override
  Future<String> encryptMsg({required String msg, required String encryptionPubkey}) async {
    final response = await _client().call(
      'encrypt_msg',
      [encryptionPubkey, msg],
    );
    return response as String;
  }

  @override
  Future<String> getNewAddress() async {
    final response = await _client().call('get_new_address');
    return response as String;
  }

  @override
  Future<int> getBlockCount() async {
    final response = await _client().call('get_blockcount');
    return response as int;
  }

  @override
  Future<List<String>> getWalletAddresses() async {
    final response = await _client().call('get_wallet_addresses') as List<dynamic>;
    return response.cast<String>();
  }

  @override
  Future<List<dynamic>> getWalletUTXOs() async {
    final response = await _client().call('get_wallet_utxos') as List<dynamic>;
    return response;
  }

  @override
  Future<List<dynamic>> myUTXOs() async {
    final response = await _client().call('my_utxos') as List<dynamic>;
    return response;
  }

  @override
  Future<Map<String, dynamic>> openapiSchema() async {
    final response = await _client().call('openapi_schema');
    return response as Map<String, dynamic>;
  }

  @override
  Future<String> resolveCommit(String bitname) async {
    final response = await _client().call('resolve_commit', bitname);
    return response as String;
  }

  @override
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey}) async {
    final response = await _client().call('sign_arbitrary_msg', {
      'msg': msg,
      'verifying_key': verifyingKey,
    });
    return response as String;
  }

  @override
  Future<Map<String, String>> signArbitraryMsgAsAddr({required String msg, required String address}) async {
    final response = await _client().call('sign_arbitrary_msg_as_addr', {
      'msg': msg,
      'address': address,
    });
    return {
      'verifying_key': response['verifying_key'] as String,
      'signature': response['signature'] as String,
    };
  }

  @override
  Future<void> stop() async {
    await _client().call('stop');
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<String> transfer({required String dest, required int value, required int fee, String? memo}) async {
    final response = await _client().call('transfer', {
      'dest': dest,
      'value': value,
      'fee': fee,
      'memo': memo,
    });
    return response as String;
  }

  @override
  Future<String> withdraw({
    required String mainchainAddress,
    required int amountSats,
    required int feeSats,
    required int mainchainFeeSats,
  }) async {
    final response = await _client().call('withdraw', {
      'mainchain_address': mainchainAddress,
      'amount_sats': amountSats,
      'fee_sats': feeSats,
      'mainchain_fee_sats': mainchainFeeSats,
    });
    return response as String;
  }
}

final bitnamesRPCMethods = [
  'balance',
  'bitname_data',
  'bitnames',
  'connect_peer',
  'create_deposit',
  'decrypt_msg',
  'encrypt_msg',
  'format_deposit_address',
  'generate_mnemonic',
  'get_best_mainchain_block_hash',
  'get_best_sidechain_block_hash',
  'get_block',
  'get_bmm_inclusions',
  'get_new_address',
  'get_new_encryption_key',
  'get_new_verifying_key',
  'get_blockcount',
  'get_paymail',
  'get_wallet_addresses',
  'get_wallet_utxos',
  'latest_failed_withdrawal_bundle_height',
  'list_peers',
  'list_utxos',
  'mine',
  'my_utxos',
  'openapi_schema',
  'pending_withdrawal_bundle',
  'register_bitname',
  'reserve_bitname',
  'resolve_commit',
  'set_seed_from_mnemonic',
  'sidechain_wealth',
  'sign_arbitrary_msg',
  'sign_arbitrary_msg_as_addr',
  'stop',
  'transfer',
  'verify_signature',
  'withdraw',
];

// Models for Bitnames RPC responses
class BitNameData {
  final String? commitment;
  final String? encryptionPubkey;
  final int? paymailFeeSats;
  final String? signingPubkey;
  final String? socketAddrV4;
  final String? socketAddrV6;

  BitNameData({
    this.commitment,
    this.encryptionPubkey,
    this.paymailFeeSats,
    this.signingPubkey,
    this.socketAddrV4,
    this.socketAddrV6,
  });

  Map<String, dynamic> toJson() => {
        if (commitment != null) 'commitment': commitment,
        if (encryptionPubkey != null) 'encryption_pubkey': encryptionPubkey,
        if (paymailFeeSats != null) 'paymail_fee_sats': paymailFeeSats,
        if (signingPubkey != null) 'signing_pubkey': signingPubkey,
        if (socketAddrV4 != null) 'socket_addr_v4': socketAddrV4,
        if (socketAddrV6 != null) 'socket_addr_v6': socketAddrV6,
      };

  factory BitNameData.fromJson(Map<String, dynamic> json) => BitNameData(
        commitment: json['commitment'] as String?,
        encryptionPubkey: json['encryption_pubkey'] as String?,
        paymailFeeSats: json['paymail_fee_sats'] as int?,
        signingPubkey: json['signing_pubkey'] as String?,
        socketAddrV4: json['socket_addr_v4'] as String?,
        socketAddrV6: json['socket_addr_v6'] as String?,
      );
}

class BalanceResponse {
  final int totalSats;
  final int availableSats;

  BalanceResponse({
    required this.totalSats,
    required this.availableSats,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) => BalanceResponse(
        totalSats: json['total_sats'] as int,
        availableSats: json['available_sats'] as int,
      );
}

class BitnamesPeerInfo {
  final String address;
  final String status;

  BitnamesPeerInfo({
    required this.address,
    required this.status,
  });

  factory BitnamesPeerInfo.fromJson(Map<String, dynamic> json) => BitnamesPeerInfo(
        address: json['address'] as String,
        status: json['status'] as String,
      );
}

class BitnameEntry {
  final String hash;
  final String? plaintextName;
  final BitnameDetails details;

  BitnameEntry({
    required this.hash,
    required this.details,
    this.plaintextName,
  });
}

class BitnameDetails {
  final String seqId;
  final String? commitment;
  final String? socketAddrV4;
  final String? socketAddrV6;
  final String? encryptionPubkey;
  final String? signingPubkey;
  final int? paymailFeeSats;

  BitnameDetails({
    required this.seqId,
    this.commitment,
    this.socketAddrV4,
    this.socketAddrV6,
    this.encryptionPubkey,
    this.signingPubkey,
    this.paymailFeeSats,
  });

  factory BitnameDetails.fromJson(Map<String, dynamic> json) => BitnameDetails(
        seqId: json['seq_id'] as String,
        commitment: json['commitment'] as String?,
        socketAddrV4: json['socket_addr_v4'] as String?,
        socketAddrV6: json['socket_addr_v6'] as String?,
        encryptionPubkey: json['encryption_pubkey'] as String?,
        signingPubkey: json['signing_pubkey'] as String?,
        paymailFeeSats: json['paymail_fee_sats'] as int?,
      );
}
