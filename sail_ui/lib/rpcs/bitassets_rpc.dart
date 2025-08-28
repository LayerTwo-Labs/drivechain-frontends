import 'dart:convert';

import 'package:convert/convert.dart' show hex;
import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

abstract class BitAssetsRPC extends SidechainRPC {
  BitAssetsRPC({required super.conf, required super.binaryType, required super.restartOnFailure});

  /// Get balance in sats
  Future<BalanceResponse> getBalance();

  /// Get BitAsset data
  Future<BitAssetRequest?> getBitAssetData(String assetId);

  /// List all BitAssets
  Future<List<BitAssetEntry>> listBitAssets();

  /// Connect to a peer
  Future<void> connectPeer(String address);

  /// List peers
  Future<List<BitAssetsPeerInfo>> listPeers();

  /// Register a BitAsset
  Future<String> registerBitAsset(String plaintextName, BitAssetRequest data);

  /// Reserve a BitAsset
  Future<String> reserveBitAsset(String name);

  /// Get deposit address
  @override
  Future<String> getDepositAddress();

  /// Get sidechain address
  @override
  Future<String> getSideAddress();

  /// List transactions
  @override
  Future<List<CoreTransaction>> listTransactions();

  /// Estimate sidechain fee
  @override
  Future<double> sideEstimateFee();

  /// Send on sidechain
  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount);

  /// Get new address
  Future<String> getNewAddress();

  /// Get the current block count
  @override
  Future<int> getBlockCount();

  /// Get wallet addresses, sorted by base58 encoding
  Future<List<String>> getWalletAddresses();

  /// Get wallet UTXOs
  Future<List<dynamic>> getWalletUTXOs();

  /// List all UTXOs
  @override
  Future<List<SidechainUTXO>> listUTXOs();

  /// Get OpenAPI schema
  Future<Map<String, dynamic>> openapiSchema();

  /// Stop the node
  @override
  Future<void> stop();

  /// Transfer funds to the specified address
  Future<String> transfer({required String dest, required int value, required int fee, String? memo});

  /// Get new verifying/signing key
  Future<String> getNewVerifyingKey();

  /// Sign an arbitrary message with the specified verifying key
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey});

  /// Sign an arbitrary message with the secret key for the specified address
  Future<Map<String, String>> signArbitraryMsgAsAddr({required String msg, required String address});

  // AMM Methods
  /// Burn an AMM position
  Future<String> ammBurn({required String asset0, required String asset1, required int lpTokenAmount});

  /// Mint an AMM position
  Future<String> ammMint({required String asset0, required String asset1, required int amount0, required int amount1});

  /// AMM swap - returns the amount of asset_receive to receive
  Future<int> ammSwap({required String assetSpend, required String assetReceive, required int amountSpend});

  /// Get the state of the specified AMM pool
  Future<AmmPoolState?> getAmmPoolState({required String asset0, required String asset1});

  /// Get the current price for the specified pair
  Future<Map<String, dynamic>?> getAmmPrice({required String base, required String quote});

  // Dutch Auction Methods
  /// Returns the amount of the base asset to receive
  Future<int> dutchAuctionBid({required String dutchAuctionId, required int bidSize});

  /// Returns the amount of the base asset and quote asset to receive
  Future<List<int>> dutchAuctionCollect(String dutchAuctionId);

  /// Create a dutch auction
  Future<String> dutchAuctionCreate(DutchAuctionParams params);

  /// List all Dutch auctions
  Future<List<DutchAuctionEntry>> dutchAuctions();

  // Encryption/Decryption Methods
  /// Decrypt a message with the specified encryption key
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey});

  /// Encrypt a message to the specified encryption pubkey
  Future<String> encryptMsg({required String msg, required String encryptionPubkey});

  /// Generate a mnemonic seed phrase
  Future<String> generateMnemonic();

  /// Get block data
  Future<Map<String, dynamic>?> getBlock(String hash);

  /// Get mainchain blocks that commit to a specified block hash
  Future<String> getBMMInclusions(String blockHash);

  /// Get the best known mainchain block hash
  Future<String?> getBestMainchainBlockHash();

  /// Get the best sidechain block hash known by BitAssets
  Future<String?> getBestSidechainBlockHash();

  /// Get the height of the latest failed withdrawal bundle
  Future<int?> getLatestFailedWithdrawalBundleHeight();

  /// Get new encryption key
  Future<String> getNewEncryptionKey();

  /// Create a deposit to an address
  Future<String> createDeposit({required String address, required int feeSats, required int valueSats});

  /// Get total sidechain wealth in sats
  Future<int> getSidechainWealth();

  /// Set the wallet seed from a mnemonic seed phrase
  Future<void> setSeedFromMnemonic(String mnemonic);

  /// Verify a signature
  Future<bool> verifySignature({required String msg, required String signature, required String verifyingKey});
}

class BitAssetsLive extends BitAssetsRPC {
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

  BitAssetsLive() : super(conf: readConf(), binaryType: BinaryType.bitassets, restartOnFailure: true) {
    _init();
  }

  void _init() async {
    await startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    return binaryProvider.binaries.where((b) => b.name == binary.name).first.extraBootArgs;
  }

  @override
  Future<int> ping() async {
    return await getBlockCount();
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
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final blocks = await _client().call('get_blockcount') as int;
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
    return bitAssetsRPCMethods;
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
  Future<double> sideEstimateFee() async {
    // BitAssets has fixed fees for now
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
    final response = await _client().call('bitcoin_balance') as Map<String, dynamic>;
    return BalanceResponse.fromJson(response);
  }

  @override
  Future<BitAssetRequest?> getBitAssetData(String assetId) async {
    final response = await _client().call('bitasset_data', assetId) as Map<String, dynamic>?;
    return response != null ? BitAssetRequest.fromJson(response) : null;
  }

  @override
  Future<List<BitAssetEntry>> listBitAssets() async {
    final clientSettings = GetIt.I.get<ClientSettings>();

    Map<String, String>? hashNameMapping;
    try {
      final settingValue = await clientSettings.getValue(HashNameMappingSetting());
      hashNameMapping = Map.fromEntries(settingValue.value.entries.map((e) => MapEntry(e.key, e.value.name)));
    } catch (e) {
      // do nothing
    }

    final response = await _client().call('bitassets') as List<dynamic>;
    return response.map<BitAssetEntry>((item) {
      if (item is! List || item.length != 3) {
        throw FormatException('Invalid bitasset entry format: $item');
      }

      final sequenceID = item[0] as int;
      final hash = item[1] as String;
      final detailsMap = item[2] as Map<String, dynamic>;

      final details = BitAssetDetails.fromJson(detailsMap);
      return BitAssetEntry(sequenceID: sequenceID, hash: hash, details: details, plaintextName: hashNameMapping?[hash]);
    }).toList();
  }

  @override
  Future<void> connectPeer(String address) async {
    await _client().call('connect_peer', address);
  }

  @override
  Future<List<BitAssetsPeerInfo>> listPeers() async {
    final response = await _client().call('list_peers') as List<dynamic>;
    return response.map((item) => BitAssetsPeerInfo.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<String> registerBitAsset(String plaintextName, BitAssetRequest data) async {
    final params = {'plaintext_name': plaintextName, ...data.toJson()};

    final response = await _client().call('register_bitasset', params);
    return response as String;
  }

  @override
  Future<String> reserveBitAsset(String name) async {
    final response = await _client().call('reserve_bitasset', [name]);
    return response as String;
  }

  @override
  Future<String> getNewAddress() async {
    final response = await _client().call('get_new_address');
    return response as String;
  }

  @override
  Future<int> getBlockCount() async {
    final response = await _client().call('getblockcount');
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
  Future<List<SidechainUTXO>> listUTXOs() async {
    final response = await _client().call('get_wallet_utxos') as List<dynamic>;
    return response.map((e) => BitAssetsUTXO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> openapiSchema() async {
    final response = await _client().call('openapi_schema');
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> stop() async {
    await _client().call('stop');
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<String> transfer({required String dest, required int value, required int fee, String? memo}) async {
    final response = await _client().call('transfer', {'dest': dest, 'value': value, 'fee': fee, 'memo': memo});
    return response as String;
  }

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async {
    final response = await _client().call('withdraw', [address, amountSats, sidechainFeeSats, mainchainFeeSats]);
    return response as String;
  }

  @override
  Future<String> getNewVerifyingKey() async {
    final response = await _client().call('get_new_verifying_key');
    return response as String;
  }

  @override
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey}) async {
    final response = await _client().call('sign_arbitrary_msg', {'msg': msg, 'verifying_key': verifyingKey});
    return response as String;
  }

  @override
  Future<Map<String, String>> signArbitraryMsgAsAddr({required String msg, required String address}) async {
    final response = await _client().call('sign_arbitrary_msg_as_addr', {'msg': msg, 'address': address});
    return {'verifying_key': response['verifying_key'] as String, 'signature': response['signature'] as String};
  }

  // AMM Methods
  @override
  Future<String> ammBurn({required String asset0, required String asset1, required int lpTokenAmount}) async {
    final response = await _client().call('amm_burn', {
      'asset0': asset0,
      'asset1': asset1,
      'lp_token_amount': lpTokenAmount,
    });
    return response as String;
  }

  @override
  Future<String> ammMint({
    required String asset0,
    required String asset1,
    required int amount0,
    required int amount1,
  }) async {
    final response = await _client().call('amm_mint', {
      'asset0': asset0,
      'asset1': asset1,
      'amount0': amount0,
      'amount1': amount1,
    });
    return response as String;
  }

  @override
  Future<int> ammSwap({required String assetSpend, required String assetReceive, required int amountSpend}) async {
    final response = await _client().call('amm_swap', {
      'asset_spend': assetSpend,
      'asset_receive': assetReceive,
      'amount_spend': amountSpend,
    });
    return response as int;
  }

  @override
  Future<AmmPoolState?> getAmmPoolState({required String asset0, required String asset1}) async {
    final response =
        await _client().call('get_amm_pool_state', {'asset0': asset0, 'asset1': asset1}) as Map<String, dynamic>?;
    return response != null ? AmmPoolState.fromJson(response) : null;
  }

  @override
  Future<Map<String, dynamic>?> getAmmPrice({required String base, required String quote}) async {
    final response = await _client().call('get_amm_price', {'base': base, 'quote': quote});
    return response as Map<String, dynamic>?;
  }

  // Dutch Auction Methods
  @override
  Future<int> dutchAuctionBid({required String dutchAuctionId, required int bidSize}) async {
    final response = await _client().call('dutch_auction_bid', {
      'dutch_auction_id': dutchAuctionId,
      'bid_size': bidSize,
    });
    return response as int;
  }

  @override
  Future<List<int>> dutchAuctionCollect(String dutchAuctionId) async {
    final response = await _client().call('dutch_auction_collect', dutchAuctionId) as List<dynamic>;
    return response.cast<int>();
  }

  @override
  Future<String> dutchAuctionCreate(DutchAuctionParams params) async {
    final response = await _client().call('dutch_auction_create', params.toJson());
    return response as String;
  }

  @override
  Future<List<DutchAuctionEntry>> dutchAuctions() async {
    final response = await _client().call('dutch_auctions') as List<dynamic>;
    return response.map<DutchAuctionEntry>((item) {
      if (item is! List || item.length != 2) {
        throw FormatException('Invalid dutch auction entry format: $item');
      }
      return DutchAuctionEntry.fromJson(item);
    }).toList();
  }

  // Encryption/Decryption Methods
  @override
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey}) async {
    final response = await _client().call('decrypt_msg', {
      'ciphertext': ciphertext,
      'encryption_pubkey': encryptionPubkey,
    });
    // Convert hex to string
    final bytes = hex.decode(response as String);
    final decoded = utf8.decode(bytes);
    return decoded;
  }

  @override
  Future<String> encryptMsg({required String msg, required String encryptionPubkey}) async {
    final response = await _client().call('encrypt_msg', {'msg': msg, 'encryption_pubkey': encryptionPubkey});
    return response as String;
  }

  @override
  Future<String> generateMnemonic() async {
    final response = await _client().call('generate_mnemonic');
    return response as String;
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
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async {
    final response = await _client().call('pending_withdrawal_bundle');
    return PendingWithdrawalBundle.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<String> getNewEncryptionKey() async {
    final response = await _client().call('get_new_encryption_key');
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
  Future<int> getSidechainWealth() async {
    final response = await _client().call('sidechain_wealth_sats');
    return response as int;
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    await _client().call('set_seed_from_mnemonic', mnemonic);
  }

  @override
  Future<bool> verifySignature({required String msg, required String signature, required String verifyingKey}) async {
    final response = await _client().call('verify_signature', {
      'msg': msg,
      'signature': signature,
      'verifying_key': verifyingKey,
    });
    return response as bool;
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    final response = await _client().call('mine', feeSats);
    return BmmResult.fromMap(response);
  }
}

final bitAssetsRPCMethods = [
  'amm_burn',
  'amm_mint',
  'amm_swap',
  'balance',
  'bitasset_data',
  'bitassets',
  'connect_peer',
  'create_deposit',
  'decrypt_msg',
  'dutch_auction_bid',
  'dutch_auction_collect',
  'dutch_auction_create',
  'dutch_auctions',
  'encrypt_msg',
  'format_deposit_address',
  'generate_mnemonic',
  'get_amm_pool_state',
  'get_amm_price',
  'get_best_mainchain_block_hash',
  'get_best_sidechain_block_hash',
  'get_block',
  'get_bmm_inclusions',
  'get_new_address',
  'get_new_encryption_key',
  'get_new_verifying_key',
  'get_blockcount',
  'get_transaction',
  'get_transaction_info',
  'get_wallet_addresses',
  'get_wallet_utxos',
  'latest_failed_withdrawal_bundle_height',
  'list_peers',
  'list_utxos',
  'mine',
  'my_utxos',
  'openapi_schema',
  'pending_withdrawal_bundle',
  'register_bitasset',
  'reserve_bitasset',
  'set_seed_from_mnemonic',
  'sidechain_wealth_sats',
  'sign_arbitrary_msg',
  'sign_arbitrary_msg_as_addr',
  'stop',
  'transfer',
  'verify_signature',
  'withdraw',
];

// Models for BitAssets RPC responses
class BitAssetRequest {
  final String? commitment;
  final String? encryptionPubkey;
  final String? signingPubkey;
  final String? socketAddrV4;
  final String? socketAddrV6;
  final int initialSupply;

  BitAssetRequest({
    required this.initialSupply,
    this.commitment,
    this.encryptionPubkey,
    this.signingPubkey,
    this.socketAddrV4,
    this.socketAddrV6,
  });

  Map<String, dynamic> toJson() => {
    'initial_supply': initialSupply,
    if (commitment != null) 'commitment': commitment,
    if (encryptionPubkey != null) 'encryption_pubkey': encryptionPubkey,
    if (signingPubkey != null) 'signing_pubkey': signingPubkey,
    if (socketAddrV4 != null) 'socket_addr_v4': socketAddrV4,
    if (socketAddrV6 != null) 'socket_addr_v6': socketAddrV6,
  };

  factory BitAssetRequest.fromJson(Map<String, dynamic> json) => BitAssetRequest(
    initialSupply: json['initial_supply'] as int,
    commitment: json['commitment'] as String?,
    encryptionPubkey: json['encryption_pubkey'] as String?,
    signingPubkey: json['signing_pubkey'] as String?,
    socketAddrV4: json['socket_addr_v4'] as String?,
    socketAddrV6: json['socket_addr_v6'] as String?,
  );
}

class BitAssetsPeerInfo {
  final String address;
  final String status;

  BitAssetsPeerInfo({required this.address, required this.status});

  factory BitAssetsPeerInfo.fromJson(Map<String, dynamic> json) =>
      BitAssetsPeerInfo(address: json['address'] as String, status: json['status'] as String);
}

class BitAssetEntry {
  final int sequenceID;
  final String hash;
  final String? plaintextName;
  final BitAssetDetails details;

  BitAssetEntry({required this.sequenceID, required this.hash, required this.details, this.plaintextName});
}

class BitAssetDetails {
  final String? commitment;
  final String? encryptionPubkey;
  final String? signingPubkey;
  final String? socketAddrV4;
  final String? socketAddrV6;

  BitAssetDetails({this.commitment, this.encryptionPubkey, this.signingPubkey, this.socketAddrV4, this.socketAddrV6});

  factory BitAssetDetails.fromJson(Map<String, dynamic> json) => BitAssetDetails(
    commitment: json['commitment'] as String?,
    encryptionPubkey: json['encryption_pubkey'] as String?,
    signingPubkey: json['signing_pubkey'] as String?,
    socketAddrV4: json['socket_addr_v4'] as String?,
    socketAddrV6: json['socket_addr_v6'] as String?,
  );
}

class AmmPoolState {
  final int reserve0;
  final int reserve1;
  final int outstandingLpTokens;
  final String creationTxid;

  AmmPoolState({
    required this.reserve0,
    required this.reserve1,
    required this.outstandingLpTokens,
    required this.creationTxid,
  });

  factory AmmPoolState.fromJson(Map<String, dynamic> json) => AmmPoolState(
    reserve0: json['reserve0'] as int,
    reserve1: json['reserve1'] as int,
    outstandingLpTokens: json['outstanding_lp_tokens'] as int,
    creationTxid: json['creation_txid'] as String,
  );
}

class DutchAuctionParams {
  final int startBlock;
  final int duration;
  final String baseAsset;
  final int baseAmount;
  final String quoteAsset;
  final int initialPrice;
  final int finalPrice;

  DutchAuctionParams({
    required this.startBlock,
    required this.duration,
    required this.baseAsset,
    required this.baseAmount,
    required this.quoteAsset,
    required this.initialPrice,
    required this.finalPrice,
  });

  Map<String, dynamic> toJson() => {
    'start_block': startBlock,
    'duration': duration,
    'base_asset': baseAsset,
    'base_amount': baseAmount,
    'quote_asset': quoteAsset,
    'initial_price': initialPrice,
    'final_price': finalPrice,
  };

  factory DutchAuctionParams.fromJson(Map<String, dynamic> json) => DutchAuctionParams(
    startBlock: json['start_block'] as int,
    duration: json['duration'] as int,
    baseAsset: json['base_asset'] as String,
    baseAmount: json['base_amount'] as int,
    quoteAsset: json['quote_asset'] as String,
    initialPrice: json['initial_price'] as int,
    finalPrice: json['final_price'] as int,
  );
}

class DutchAuctionEntry {
  final String id;
  final String baseAsset;
  final String quoteAsset;
  final int baseAmount;
  final int initialPrice;
  final int finalPrice;
  final int startBlock;
  final int duration;
  final String status;
  final int? currentPrice;

  DutchAuctionEntry({
    required this.id,
    required this.baseAsset,
    required this.quoteAsset,
    required this.baseAmount,
    required this.initialPrice,
    required this.finalPrice,
    required this.startBlock,
    required this.duration,
    required this.status,
    this.currentPrice,
  });

  factory DutchAuctionEntry.fromJson(List<dynamic> json) {
    final id = json[0] as String;
    final data = json[1] as Map<String, dynamic>;

    return DutchAuctionEntry(
      id: id,
      baseAsset: data['base_asset'] as String? ?? '',
      quoteAsset: data['quote_asset'] as String? ?? '',
      baseAmount: data['base_amount'] as int? ?? 0,
      initialPrice: data['initial_price'] as int? ?? 0,
      finalPrice: data['final_price'] as int? ?? 0,
      startBlock: data['start_block'] as int? ?? 0,
      duration: data['duration'] as int? ?? 0,
      status: data['status'] as String? ?? 'Unknown',
      currentPrice: data['current_price'] as int?,
    );
  }
}

class BitAssetsUTXO extends SidechainUTXO {
  final Map<String, dynamic> output;

  BitAssetsUTXO({required super.outpoint, required this.output})
    : super(
        address: output['address'] as String,
        valueSats: _extractValueSats(output['content']),
        type: OutpointType.deposit, // TODO: determine actual type from data
      );

  static int _extractValueSats(Map<String, dynamic> content) {
    // Extract value based on content type
    if (content.containsKey('BitcoinSats')) {
      return content['BitcoinSats'] as int;
    } else if (content.containsKey('BitAsset')) {
      return content['BitAsset']['amount'] as int;
    }
    return 0;
  }

  factory BitAssetsUTXO.fromJson(Map<String, dynamic> json) =>
      BitAssetsUTXO(outpoint: json['outpoint'] as String, output: json['output'] as Map<String, dynamic>);
}
