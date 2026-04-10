import 'dart:convert';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:convert/convert.dart' show hex;
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/bitassets/v1/bitassets.connect.client.dart';
import 'package:sail_ui/gen/bitassets/v1/bitassets.pb.dart' as pb;
import 'package:sail_ui/sail_ui.dart';

abstract class BitAssetsRPC extends SidechainRPC {
  BitAssetsRPC({required super.binaryType, required super.restartOnFailure});

  /// Get balance in sats
  Future<BalanceResponse> getBalance();

  /// Get BitAsset data
  Future<BitAssetRequest?> getBitAssetData(String assetId);

  /// List all BitAssets
  Future<List<BitAssetEntry>> listBitAssets();

  /// Connect to a peer
  Future<void> connectPeer(String address);

  /// Forget/delete a peer from known_peers DB (connections are not terminated)
  Future<void> forgetPeer(String address);

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
  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  );

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

  /// List unconfirmed owned UTXOs
  Future<List<SidechainUTXO>> myUnconfirmedUtxos();

  /// Remove a transaction from the mempool
  Future<void> removeFromMempool(String txid);

  /// Get OpenAPI schema
  Future<Map<String, dynamic>> openapiSchema();

  /// Stop the node
  @override
  Future<void> stop();

  /// Transfer funds to the specified address
  Future<String> transfer({
    required String dest,
    required int value,
    required int fee,
    String? memo,
  });

  /// Transfer BitAsset tokens to the specified address
  Future<String> transferBitAsset({
    required String assetId,
    required String dest,
    required int amount,
    required int feeSats,
  });

  /// Get new verifying/signing key
  Future<String> getNewVerifyingKey();

  /// Sign an arbitrary message with the specified verifying key
  Future<String> signArbitraryMsg({
    required String msg,
    required String verifyingKey,
  });

  /// Sign an arbitrary message with the secret key for the specified address
  Future<Map<String, String>> signArbitraryMsgAsAddr({
    required String msg,
    required String address,
  });

  // AMM Methods
  /// Burn an AMM position
  Future<String> ammBurn({
    required String asset0,
    required String asset1,
    required int lpTokenAmount,
  });

  /// Mint an AMM position
  Future<String> ammMint({
    required String asset0,
    required String asset1,
    required int amount0,
    required int amount1,
  });

  /// AMM swap - returns the amount of asset_receive to receive
  Future<int> ammSwap({
    required String assetSpend,
    required String assetReceive,
    required int amountSpend,
  });

  /// Get the state of the specified AMM pool
  Future<AmmPoolState?> getAmmPoolState({
    required String asset0,
    required String asset1,
  });

  /// Get the current price for the specified pair
  Future<Map<String, dynamic>?> getAmmPrice({
    required String base,
    required String quote,
  });

  // Dutch Auction Methods
  /// Returns the amount of the base asset to receive
  Future<int> dutchAuctionBid({
    required String dutchAuctionId,
    required int bidSize,
  });

  /// Returns the amount of the base asset and quote asset to receive
  Future<List<int>> dutchAuctionCollect(String dutchAuctionId);

  /// Create a dutch auction
  Future<String> dutchAuctionCreate(DutchAuctionParams params);

  /// List all Dutch auctions
  Future<List<DutchAuctionEntry>> dutchAuctions();

  // Encryption/Decryption Methods
  /// Decrypt a message with the specified encryption key
  Future<String> decryptMsg({
    required String ciphertext,
    required String encryptionPubkey,
  });

  /// Encrypt a message to the specified encryption pubkey
  Future<String> encryptMsg({
    required String msg,
    required String encryptionPubkey,
  });

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

  /// Get new encryption key
  Future<String> getNewEncryptionKey();

  /// Create a deposit to an address
  Future<String> createDeposit({
    required String address,
    required int feeSats,
    required int valueSats,
  });

  /// Get total sidechain wealth in sats
  Future<int> getSidechainWealth();

  /// Set the wallet seed from a mnemonic seed phrase
  Future<void> setSeedFromMnemonic(String mnemonic);

  /// Verify a signature
  Future<bool> verifySignature({
    required String msg,
    required String signature,
    required String verifyingKey,
  });
}

class BitAssetsLive extends BitAssetsRPC {
  @override
  final log = GetIt.I.get<Logger>();

  late BitAssetsServiceClient _client;

  BitAssetsLive() : super(binaryType: BinaryType.bitassets, restartOnFailure: false) {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30400',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );
    _client = BitAssetsServiceClient(transport);
  }

  @override
  Future<List<String>> binaryArgs() async => [];

  @override
  Future<int> ping() async => await getBlockCount();

  @override
  List<String> startupErrors() => [];

  @override
  Future<(double, double)> balance() async {
    final resp = await _client.getBalance(pb.GetBalanceRequest());
    final confirmed = satoshiToBTC(resp.availableSats.toInt());
    final unconfirmed = satoshiToBTC((resp.totalSats - resp.availableSats).toInt());
    return (confirmed, unconfirmed);
  }

  @override
  Future<int> getBlockCount() async {
    final resp = await _client.getBlockCount(pb.GetBlockCountRequest());
    return resp.count.toInt();
  }

  @override
  Future<void> stopRPC() async {
    await _client.stop(pb.StopRequest());
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final blocks = await getBlockCount();
    final explorerHeaders = await fetchExplorerHeaders();
    final headers = explorerHeaders ?? blocks;
    final bestBlockHash = await getBestSidechainBlockHash();

    return BlockchainInfo(
      chain: 'signet',
      blocks: blocks,
      headers: headers,
      bestBlockHash: bestBlockHash ?? '',
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
  List<String> getMethods() => bitAssetsRPCMethods;

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    final paramsJson = params != null ? jsonEncode(params) : '';
    final resp = await _client.callRaw(pb.CallRawRequest(method: method, paramsJson: paramsJson));
    if (resp.resultJson.isEmpty) return null;
    return jsonDecode(resp.resultJson);
  }

  @override
  Future<String> getDepositAddress() async {
    final resp = await _client.getNewAddress(pb.GetNewAddressRequest());
    return formatDepositAddress(resp.address, chain.slot);
  }

  @override
  Future<String> getSideAddress() async {
    final resp = await _client.getNewAddress(pb.GetNewAddressRequest());
    return resp.address;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    throw UnimplementedError();
  }

  @override
  Future<double> sideEstimateFee() async => 0.00001;

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final resp = await _client.transfer(
      pb.TransferRequest(
        address: address,
        amountSats: Int64(btcToSatoshi(amount).toInt()),
        feeSats: Int64(btcToSatoshi(0.00001).toInt()),
      ),
    );
    return resp.txid;
  }

  @override
  Future<BalanceResponse> getBalance() async {
    final resp = await _client.getBalance(pb.GetBalanceRequest());
    return BalanceResponse(
      totalSats: resp.totalSats.toInt(),
      availableSats: resp.availableSats.toInt(),
    );
  }

  @override
  Future<BitAssetRequest?> getBitAssetData(String assetId) async {
    final resp = await _client.getBitAssetData(pb.GetBitAssetDataRequest(assetId: assetId));
    if (resp.dataJson.isEmpty) return null;
    final decoded = jsonDecode(resp.dataJson) as Map<String, dynamic>;
    return BitAssetRequest.fromJson(decoded);
  }

  @override
  Future<List<BitAssetEntry>> listBitAssets() async {
    final clientSettings = GetIt.I.get<ClientSettings>();

    Map<String, String>? hashNameMapping;
    try {
      final settingValue = await clientSettings.getValue(
        HashNameMappingSetting(),
      );
      hashNameMapping = Map.fromEntries(
        settingValue.value.entries.map((e) => MapEntry(e.key, e.value.name)),
      );
    } catch (e) {
      // do nothing
    }

    final resp = await _client.listBitAssets(pb.ListBitAssetsRequest());
    if (resp.bitassetsJson.isEmpty) return [];
    final response = jsonDecode(resp.bitassetsJson) as List<dynamic>;
    return response.map<BitAssetEntry>((item) {
      if (item is! List || item.length != 3) {
        throw FormatException('Invalid bitasset entry format: $item');
      }

      final sequenceID = item[0] as int;
      final hash = item[1] as String;
      final detailsMap = item[2] as Map<String, dynamic>;

      final details = BitAssetDetails.fromJson(detailsMap);
      return BitAssetEntry(
        sequenceID: sequenceID,
        hash: hash,
        details: details,
        plaintextName: hashNameMapping?[hash],
      );
    }).toList();
  }

  @override
  Future<void> connectPeer(String address) async {
    await _client.connectPeer(pb.ConnectPeerRequest(address: address));
  }

  @override
  Future<void> forgetPeer(String address) async {
    await _client.forgetPeer(pb.ForgetPeerRequest(address: address));
  }

  @override
  Future<List<BitAssetsPeerInfo>> listPeers() async {
    final resp = await _client.listPeers(pb.ListPeersRequest());
    if (resp.peersJson.isEmpty) return [];
    final decoded = jsonDecode(resp.peersJson) as List<dynamic>;
    return decoded.map((item) => BitAssetsPeerInfo.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<String> registerBitAsset(String plaintextName, BitAssetRequest data) async {
    final dataJson = jsonEncode(data.toJson());
    final resp = await _client.registerBitAsset(
      pb.RegisterBitAssetRequest(
        plaintextName: plaintextName,
        initialSupply: Int64(data.initialSupply),
        dataJson: dataJson,
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> reserveBitAsset(String name) async {
    final resp = await _client.reserveBitAsset(pb.ReserveBitAssetRequest(name: name));
    return resp.txid;
  }

  @override
  Future<String> transferBitAsset({
    required String assetId,
    required String dest,
    required int amount,
    required int feeSats,
  }) async {
    final resp = await _client.transferBitAsset(
      pb.TransferBitAssetRequest(
        assetId: assetId,
        dest: dest,
        amount: Int64(amount),
        feeSats: Int64(feeSats),
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> getNewAddress() async {
    final resp = await _client.getNewAddress(pb.GetNewAddressRequest());
    return resp.address;
  }

  @override
  Future<List<String>> getWalletAddresses() async {
    final resp = await _client.getWalletAddresses(pb.GetWalletAddressesRequest());
    return resp.addresses.toList();
  }

  @override
  Future<List<dynamic>> getWalletUTXOs() async {
    final resp = await _client.getWalletUtxos(pb.GetWalletUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    return jsonDecode(resp.utxosJson) as List<dynamic>;
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    final resp = await _client.getWalletUtxos(pb.GetWalletUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    final decoded = jsonDecode(resp.utxosJson) as List<dynamic>;
    return decoded.map((e) => BitAssetsUTXO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async {
    final resp = await _client.listUtxos(pb.ListUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    final decoded = jsonDecode(resp.utxosJson) as List<dynamic>;
    return decoded.map((e) => BitAssetsUTXO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SidechainUTXO>> myUnconfirmedUtxos() async {
    final resp = await _client.myUnconfirmedUtxos(pb.MyUnconfirmedUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    final decoded = jsonDecode(resp.utxosJson) as List<dynamic>;
    return decoded.map((e) => BitAssetsUTXO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> removeFromMempool(String txid) async {
    await _client.removeFromMempool(pb.RemoveFromMempoolRequest(txid: txid));
  }

  @override
  Future<Map<String, dynamic>> openapiSchema() async {
    final resp = await _client.openapiSchema(pb.OpenapiSchemaRequest());
    if (resp.schemaJson.isEmpty) return {};
    return jsonDecode(resp.schemaJson) as Map<String, dynamic>;
  }

  @override
  Future<void> stop() async {
    await _client.stop(pb.StopRequest());
  }

  @override
  Future<String> transfer({
    required String dest,
    required int value,
    required int fee,
    String? memo,
  }) async {
    final resp = await _client.transfer(
      pb.TransferRequest(
        address: dest,
        amountSats: Int64(value),
        feeSats: Int64(fee),
        memo: memo,
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> withdraw(
    String address,
    int amountSats,
    int sidechainFeeSats,
    int mainchainFeeSats,
  ) async {
    final resp = await _client.withdraw(
      pb.WithdrawRequest(
        address: address,
        amountSats: Int64(amountSats),
        sideFeeSats: Int64(sidechainFeeSats),
        mainFeeSats: Int64(mainchainFeeSats),
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> getNewVerifyingKey() async {
    final resp = await _client.getNewVerifyingKey(pb.GetNewVerifyingKeyRequest());
    return resp.key;
  }

  @override
  Future<String> signArbitraryMsg({
    required String msg,
    required String verifyingKey,
  }) async {
    final resp = await _client.signArbitraryMsg(
      pb.SignArbitraryMsgRequest(
        msg: msg,
        verifyingKey: verifyingKey,
      ),
    );
    return resp.signature;
  }

  @override
  Future<Map<String, String>> signArbitraryMsgAsAddr({
    required String msg,
    required String address,
  }) async {
    final resp = await _client.signArbitraryMsgAsAddr(
      pb.SignArbitraryMsgAsAddrRequest(
        msg: msg,
        address: address,
      ),
    );
    return {
      'verifying_key': resp.verifyingKey,
      'signature': resp.signature,
    };
  }

  @override
  Future<bool> verifySignature({
    required String msg,
    required String signature,
    required String verifyingKey,
  }) async {
    final resp = await _client.verifySignature(
      pb.VerifySignatureRequest(
        msg: msg,
        signature: signature,
        verifyingKey: verifyingKey,
      ),
    );
    return resp.valid;
  }

  // AMM Methods

  @override
  Future<String> ammBurn({
    required String asset0,
    required String asset1,
    required int lpTokenAmount,
  }) async {
    final resp = await _client.ammBurn(
      pb.AmmBurnRequest(
        asset0: asset0,
        asset1: asset1,
        lpTokenAmount: Int64(lpTokenAmount),
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> ammMint({
    required String asset0,
    required String asset1,
    required int amount0,
    required int amount1,
  }) async {
    final resp = await _client.ammMint(
      pb.AmmMintRequest(
        asset0: asset0,
        asset1: asset1,
        amount0: Int64(amount0),
        amount1: Int64(amount1),
      ),
    );
    return resp.txid;
  }

  @override
  Future<int> ammSwap({
    required String assetSpend,
    required String assetReceive,
    required int amountSpend,
  }) async {
    final resp = await _client.ammSwap(
      pb.AmmSwapRequest(
        assetSpend: assetSpend,
        assetReceive: assetReceive,
        amountSpend: Int64(amountSpend),
      ),
    );
    return resp.amountReceive.toInt();
  }

  @override
  Future<AmmPoolState?> getAmmPoolState({
    required String asset0,
    required String asset1,
  }) async {
    final resp = await _client.getAmmPoolState(
      pb.GetAmmPoolStateRequest(
        asset0: asset0,
        asset1: asset1,
      ),
    );
    if (resp.poolStateJson.isEmpty) return null;
    final decoded = jsonDecode(resp.poolStateJson) as Map<String, dynamic>;
    return AmmPoolState.fromJson(decoded);
  }

  @override
  Future<Map<String, dynamic>?> getAmmPrice({
    required String base,
    required String quote,
  }) async {
    final resp = await _client.getAmmPrice(
      pb.GetAmmPriceRequest(
        base: base,
        quote: quote,
      ),
    );
    if (resp.priceJson.isEmpty) return null;
    return jsonDecode(resp.priceJson) as Map<String, dynamic>;
  }

  // Dutch Auction Methods

  @override
  Future<int> dutchAuctionBid({
    required String dutchAuctionId,
    required int bidSize,
  }) async {
    final resp = await _client.dutchAuctionBid(
      pb.DutchAuctionBidRequest(
        dutchAuctionId: dutchAuctionId,
        bidSize: Int64(bidSize),
      ),
    );
    return resp.baseAmount.toInt();
  }

  @override
  Future<List<int>> dutchAuctionCollect(String dutchAuctionId) async {
    final resp = await _client.dutchAuctionCollect(
      pb.DutchAuctionCollectRequest(
        dutchAuctionId: dutchAuctionId,
      ),
    );
    return [resp.baseAmount.toInt(), resp.quoteAmount.toInt()];
  }

  @override
  Future<String> dutchAuctionCreate(DutchAuctionParams params) async {
    final resp = await _client.dutchAuctionCreate(
      pb.DutchAuctionCreateRequest(
        startBlock: Int64(params.startBlock),
        duration: Int64(params.duration),
        baseAsset: params.baseAsset,
        baseAmount: Int64(params.baseAmount),
        quoteAsset: params.quoteAsset,
        initialPrice: Int64(params.initialPrice),
        finalPrice: Int64(params.finalPrice),
      ),
    );
    return resp.txid;
  }

  @override
  Future<List<DutchAuctionEntry>> dutchAuctions() async {
    final resp = await _client.dutchAuctions(pb.DutchAuctionsRequest());
    if (resp.auctionsJson.isEmpty) return [];
    final response = jsonDecode(resp.auctionsJson) as List<dynamic>;
    return response.map<DutchAuctionEntry>((item) {
      if (item is! List || item.length != 2) {
        throw FormatException('Invalid dutch auction entry format: $item');
      }
      return DutchAuctionEntry.fromJson(item);
    }).toList();
  }

  // Encryption/Decryption Methods

  @override
  Future<String> decryptMsg({
    required String ciphertext,
    required String encryptionPubkey,
  }) async {
    final resp = await _client.decryptMsg(
      pb.DecryptMsgRequest(
        ciphertext: ciphertext,
        encryptionPubkey: encryptionPubkey,
      ),
    );
    // Convert hex to string
    final bytes = hex.decode(resp.plaintext);
    final decoded = utf8.decode(bytes);
    return decoded;
  }

  @override
  Future<String> encryptMsg({
    required String msg,
    required String encryptionPubkey,
  }) async {
    final resp = await _client.encryptMsg(
      pb.EncryptMsgRequest(
        msg: msg,
        encryptionPubkey: encryptionPubkey,
      ),
    );
    return resp.ciphertext;
  }

  @override
  Future<String> generateMnemonic() async {
    final resp = await _client.generateMnemonic(pb.GenerateMnemonicRequest());
    return resp.mnemonic;
  }

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) async {
    final resp = await _client.getBlock(pb.GetBlockRequest(hash: hash));
    if (resp.blockJson.isEmpty) return null;
    return jsonDecode(resp.blockJson) as Map<String, dynamic>;
  }

  @override
  Future<String> getBMMInclusions(String blockHash) async {
    final resp = await _client.getBmmInclusions(pb.GetBmmInclusionsRequest(blockHash: blockHash));
    return resp.inclusions;
  }

  @override
  Future<String?> getBestMainchainBlockHash() async {
    final resp = await _client.getBestMainchainBlockHash(pb.GetBestMainchainBlockHashRequest());
    return resp.hash.isEmpty ? null : resp.hash;
  }

  @override
  Future<String?> getBestSidechainBlockHash() async {
    final resp = await _client.getBestSidechainBlockHash(pb.GetBestSidechainBlockHashRequest());
    return resp.hash.isEmpty ? null : resp.hash;
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async {
    final resp = await _client.getLatestFailedWithdrawalBundleHeight(
      pb.GetLatestFailedWithdrawalBundleHeightRequest(),
    );
    return resp.height == 0 ? null : resp.height.toInt();
  }

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async {
    final resp = await _client.getPendingWithdrawalBundle(pb.GetPendingWithdrawalBundleRequest());
    if (resp.bundleJson.isEmpty) return null;
    final decoded = jsonDecode(resp.bundleJson);
    return PendingWithdrawalBundle.fromJson(decoded as Map<String, dynamic>);
  }

  @override
  Future<String> getNewEncryptionKey() async {
    final resp = await _client.getNewEncryptionKey(pb.GetNewEncryptionKeyRequest());
    return resp.key;
  }

  @override
  Future<String> createDeposit({
    required String address,
    required int feeSats,
    required int valueSats,
  }) async {
    final resp = await _client.createDeposit(
      pb.CreateDepositRequest(
        address: address,
        valueSats: Int64(valueSats),
        feeSats: Int64(feeSats),
      ),
    );
    return resp.txid;
  }

  @override
  Future<int> getSidechainWealth() async {
    final resp = await _client.getSidechainWealth(pb.GetSidechainWealthRequest());
    return resp.sats.toInt();
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    await _client.setSeedFromMnemonic(pb.SetSeedFromMnemonicRequest(mnemonic: mnemonic));
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    final resp = await _client.mine(pb.MineRequest(feeSats: Int64(feeSats)));
    final decoded = jsonDecode(resp.bmmResultJson);
    return BmmResult.fromMap(decoded);
  }
}

final bitAssetsRPCMethods = [
  'amm_burn',
  'amm_mint',
  'amm_swap',
  'bitcoin_balance',
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
  'forget_peer',
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
  'getblockcount',
  'get_transaction',
  'get_transaction_info',
  'get_wallet_addresses',
  'get_wallet_utxos',
  'latest_failed_withdrawal_bundle_height',
  'list_peers',
  'list_utxos',
  'mine',
  'my_unconfirmed_utxos',
  'my_utxos',
  'openapi_schema',
  'pending_withdrawal_bundle',
  'register_bitasset',
  'remove_from_mempool',
  'reserve_bitasset',
  'set_seed_from_mnemonic',
  'sidechain_wealth_sats',
  'sign_arbitrary_msg',
  'sign_arbitrary_msg_as_addr',
  'stop',
  'transfer',
  'transfer_bitasset',
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

  factory BitAssetsPeerInfo.fromJson(Map<String, dynamic> json) => BitAssetsPeerInfo(
    address: json['address'] as String,
    status: json['status'] as String,
  );
}

class BitAssetEntry {
  final int sequenceID;
  final String hash;
  final String? plaintextName;
  final BitAssetDetails details;

  BitAssetEntry({
    required this.sequenceID,
    required this.hash,
    required this.details,
    this.plaintextName,
  });
}

class BitAssetDetails {
  final String? commitment;
  final String? encryptionPubkey;
  final String? signingPubkey;
  final String? socketAddrV4;
  final String? socketAddrV6;

  BitAssetDetails({
    this.commitment,
    this.encryptionPubkey,
    this.signingPubkey,
    this.socketAddrV4,
    this.socketAddrV6,
  });

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
        type: OutpointType.deposit,
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

  factory BitAssetsUTXO.fromJson(Map<String, dynamic> json) => BitAssetsUTXO(
    outpoint: json['outpoint'] as String,
    output: json['output'] as Map<String, dynamic>,
  );
}
