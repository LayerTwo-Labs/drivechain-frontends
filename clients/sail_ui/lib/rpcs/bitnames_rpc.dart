import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/chains.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// API to the bitnames server.
abstract class BitnamesRPC extends SidechainRPC {
  BitnamesRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
    required super.chain,
  });

  /// Get balance in sats
  Future<BalanceResponse> getBalance();

  /// Get BitName data
  Future<BitNameData?> getBitNameData(String name);

  /// List all BitNames
  Future<List<String>> listBitNames();

  /// Connect to a peer
  Future<void> connectPeer(String address);

  /// List peers
  Future<List<BitnamesPeerInfo>> listPeers();

  /// List all UTXOs
  Future<List<BitnamesUTXO>> listUtxos();

  /// Register a BitName
  Future<String> registerBitName(String plainName, BitNameData? data);

  /// Reserve a BitName
  Future<String> reserveBitName(String name);
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
    required super.logPath,
    required super.restartOnFailure,
    required super.chain,
  });

  // Async factory
  static Future<BitnamesLive> create({
    required Binary binary,
    required String logPath,
    required Sidechain chain,
  }) async {
    final conf = await getMainchainConf();

    final instance = BitnamesLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
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
    final args = <String>[];

    if (binary.mnemonicSeedPhrasePath != null) {
      args.addAll(['--mnemonic-seed-phrase-path', binary.mnemonicSeedPhrasePath!]);
    }

    return args;
  }

  @override
  Future<int> ping() async {
    final response = await getBalance();
    return response.totalSats;
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
    final response = await _client().call('get-new-address') as String;
    return formatDepositAddress(response, chain.slot);
  }

  @override
  Future<String> getSideAddress() async {
    final response = await _client().call('get-new-address');
    return response as String;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    // TODO: Implement once we know the transaction format
    throw UnimplementedError();
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) async {
    final response = await _client().call('withdraw', [
      address,
      btcToSatoshi(amount),
      btcToSatoshi(sidechainFee),
      btcToSatoshi(mainchainFee),
    ]);
    return response as String;
  }

  @override
  Future<double> sideEstimateFee() async {
    // Bitnames has fixed fees for now, matching Thunder's implementation
    return 0.00001;
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final response = await _client().call('transfer', [
      address,
      btcToSatoshi(amount),
      subtractFeeFromAmount,
    ]);
    return response as String;
  }

  @override
  Future<BalanceResponse> getBalance() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    return BalanceResponse.fromJson(response);
  }

  @override
  Future<BitNameData?> getBitNameData(String name) async {
    final response = await _client().call('bitname-data', [name]) as Map<String, dynamic>?;
    return response != null ? BitNameData.fromJson(response) : null;
  }

  @override
  Future<List<String>> listBitNames() async {
    final response = await _client().call('bitnames') as List<dynamic>;
    return response.cast<String>();
  }

  @override
  Future<void> connectPeer(String address) async {
    await _client().call('connect-peer', [address]);
  }

  @override
  Future<List<BitnamesPeerInfo>> listPeers() async {
    final response = await _client().call('list-peers') as List<dynamic>;
    return response.map((e) => BitnamesPeerInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<BitnamesUTXO>> listUtxos() async {
    final response = await _client().call('list-utxos') as List<dynamic>;
    return response.map((e) => BitnamesUTXO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<String> registerBitName(String plainName, BitNameData? data) async {
    final response = await _client().call('register-bitname', [
      {
        'plain_name': plainName,
        'bitname_data': data?.toJson(),
      },
    ]);
    return response as String;
  }

  @override
  Future<String> reserveBitName(String name) async {
    final response = await _client().call('reserve-bitname', [name]);
    return response as String;
  }

  /// Additional methods from OpenAPI schema

  /// Get a new encryption key
  Future<String> getNewEncryptionKey() async {
    final response = await _client().call('get-new-encryption-key');
    return response as String;
  }

  /// Get a new verifying/signing key
  Future<String> getNewVerifyingKey() async {
    final response = await _client().call('get-new-verifying-key');
    return response as String;
  }

  /// Sign an arbitrary message with the specified verifying key
  Future<String> signArbitraryMessage(String message, String verifyingKey) async {
    final response = await _client().call('sign-arbitrary-msg', [
      {
        'msg': message,
        'verifying_key': verifyingKey,
      },
    ]);
    return response as String;
  }

  /// Verify a signature on a message against the specified verifying key
  Future<bool> verifySignature(String message, String signature, String verifyingKey) async {
    final response = await _client().call('verify-signature', [
      {
        'msg': message,
        'signature': signature,
        'verifying_key': verifyingKey,
        'dst': 'arbitrary',
      },
    ]);
    return response as bool;
  }

  /// Get the best known mainchain block hash
  Future<String?> getBestMainchainBlockHash() async {
    final response = await _client().call('get-best-mainchain-block-hash');
    return response as String?;
  }

  /// Get the best sidechain block hash known by Bitnames
  Future<String?> getBestSidechainBlockHash() async {
    final response = await _client().call('get-best-sidechain-block-hash');
    return response as String?;
  }

  /// Get total sidechain wealth in sats
  Future<int> getSidechainWealthSats() async {
    final response = await _client().call('sidechain-wealth-sats');
    return response as int;
  }
}

final bitnamesRPCMethods = [
  'balance',
  'bitname-data',
  'bitnames',
  'connect-peer',
  'create-deposit',
  'decrypt-msg',
  'encrypt-msg',
  'format-deposit-address',
  'generate-mnemonic',
  'get-best-mainchain-block-hash',
  'get-best-sidechain-block-hash',
  'get-block',
  'get-bmm-inclusions',
  'get-new-address',
  'get-new-encryption-key',
  'get-new-verifying-key',
  'get-blockcount',
  'get-paymail',
  'get-wallet-addresses',
  'get-wallet-utxos',
  'latest-failed-withdrawal-bundle-height',
  'list-peers',
  'list-utxos',
  'mine',
  'my-utxos',
  'openapi-schema',
  'pending-withdrawal-bundle',
  'register-bitname',
  'reserve-bitname',
  'resolve-commit',
  'set-seed-from-mnemonic',
  'sidechain-wealth',
  'sign-arbitrary-msg',
  'sign-arbitrary-msg-as-addr',
  'stop',
  'transfer',
  'verify-signature',
  'withdraw',
  'help',
];

/// Models for Bitnames RPC responses
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

class BitnamesUTXO {
  final String outpoint;
  final Map<String, dynamic> output;

  BitnamesUTXO({
    required this.outpoint,
    required this.output,
  });

  factory BitnamesUTXO.fromJson(Map<String, dynamic> json) => BitnamesUTXO(
        outpoint: json['outpoint'] as String,
        output: json['output'] as Map<String, dynamic>,
      );
}
