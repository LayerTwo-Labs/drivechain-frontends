import 'dart:convert';

import 'package:connectrpc/protobuf.dart';
import 'package:sail_ui/rpcs/keepalive_http_client.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/truthcoin/v1/truthcoin.connect.client.dart';
import 'package:sail_ui/gen/truthcoin/v1/truthcoin.pb.dart' as pb;
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// API to the truthcoin server.
abstract class TruthcoinRPC extends SidechainRPC {
  TruthcoinRPC({required super.binaryType});

  /// Get total sidechain wealth in BTC
  Future<double> getSidechainWealth();

  /// Create a deposit transaction
  Future<String> createDeposit(String address, double amount, double fee);

  /// Connect to a peer
  Future<void> connectPeer(String peerAddress);

  /// List connected peers
  Future<List<Map<String, dynamic>>> listPeers();

  /// Get block by hash
  Future<Map<String, dynamic>?> getBlock(String hash);

  /// Get best mainchain block hash
  Future<String?> getBestMainchainBlockHash();

  /// Get best sidechain block hash
  Future<String?> getBestSidechainBlockHash();

  /// Get BMM inclusions
  Future<String> getBMMInclusions(String blockHash);

  /// Remove transaction from mempool
  Future<void> removeFromMempool(String txid);

  /// Generate new mnemonic
  Future<String> generateMnemonic();

  /// Set seed from mnemonic
  Future<void> setSeedFromMnemonic(String mnemonic);

  /// Refresh wallet
  Future<void> refreshWallet();

  /// Get transaction by txid
  Future<Map<String, dynamic>?> getTransaction(String txid);

  /// Get transaction info
  Future<Map<String, dynamic>?> getTransactionInfo(String txid);

  /// Get wallet addresses
  Future<List<String>> getWalletAddresses();

  /// Get owned UTXOs (confirmed)
  Future<List<SidechainUTXO>> myUtxos();

  /// Get owned UTXOs (unconfirmed)
  Future<List<SidechainUTXO>> myUnconfirmedUtxos();

  // Prediction Markets
  /// Calculate initial liquidity required for market creation
  Future<Map<String, dynamic>> calculateInitialLiquidity({
    required double beta,
    int? numOutcomes,
    String? dimensions,
  });

  /// Create a new prediction market
  Future<String> marketCreate({
    required String title,
    required String description,
    required String dimensions,
    required int feeSats,
    double? beta,
    int? initialLiquidity,
    double? tradingFee,
    List<String>? tags,
    List<String>? categoryTxids,
    List<String>? residualNames,
  });

  /// List all markets
  Future<List<Map<String, dynamic>>> marketList();

  /// Get a specific market
  Future<Map<String, dynamic>?> marketGet(String marketId);

  /// Buy shares in a market (with dry_run support for cost calculation)
  Future<Map<String, dynamic>> marketBuy({
    required String marketId,
    required int outcomeIndex,
    required double sharesAmount,
    bool? dryRun,
    int? feeSats,
    int? maxCost,
  });

  /// Sell shares in a market (with dry_run support for proceeds calculation)
  Future<Map<String, dynamic>> marketSell({
    required String marketId,
    required int outcomeIndex,
    required int sharesAmount,
    required String sellerAddress,
    bool? dryRun,
    int? feeSats,
    int? minProceeds,
  });

  /// Get positions in a market
  Future<Map<String, dynamic>> marketPositions({
    String? address,
    String? marketId,
  });

  // Slots
  /// Get slot system status and configuration
  Future<Map<String, dynamic>> slotStatus();

  /// List slots with optional filtering
  Future<List<Map<String, dynamic>>> slotList({int? period, String? status});

  /// Get a specific slot by ID
  Future<Map<String, dynamic>?> slotGet(String slotId);

  /// Claim a decision slot
  Future<String> slotClaim({
    required int feeSats,
    required int periodIndex,
    required int slotIndex,
    required String question,
    required bool isStandard,
    bool? isScaled,
    int? min,
    int? max,
  });

  /// Claim multiple slots as a category
  Future<String> slotClaimCategory({
    required List<Map<String, dynamic>> slots,
    required bool isStandard,
    required int feeSats,
  });

  // Voting
  /// Register as a voter
  Future<String> voteRegister({required int feeSats, int? reputationBondSats});

  /// Get voter info
  Future<Map<String, dynamic>?> voteVoter(String address);

  /// List all voters
  Future<List<Map<String, dynamic>>> voteVoters();

  /// Submit votes (batch)
  Future<String> voteSubmit({
    required List<Map<String, dynamic>> votes,
    required int feeSats,
  });

  /// List votes with optional filters
  Future<List<Map<String, dynamic>>> voteList({
    String? voter,
    String? decisionId,
    int? periodId,
  });

  /// Get voting period information
  Future<Map<String, dynamic>?> votePeriod({int? periodId});

  // Votecoin
  /// Transfer votecoins
  Future<String> votecoinTransfer({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  });

  /// Get votecoin balance for an address
  Future<int> votecoinBalance(String address);

  /// Transfer votecoin (alternative method)
  Future<String> transferVotecoin({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  });

  // Crypto utilities
  /// Get new encryption key
  Future<String> getNewEncryptionKey();

  /// Get new verifying key
  Future<String> getNewVerifyingKey();

  /// Encrypt a message
  Future<String> encryptMsg({
    required String msg,
    required String encryptionPubkey,
  });

  /// Decrypt a message
  Future<String> decryptMsg({
    required String ciphertext,
    required String encryptionPubkey,
  });

  /// Sign an arbitrary message with verifying key
  Future<String> signArbitraryMsg({
    required String msg,
    required String verifyingKey,
  });

  /// Sign an arbitrary message as address
  Future<Map<String, dynamic>> signArbitraryMsgAsAddr({
    required String address,
    required String msg,
  });

  /// Verify a signature
  Future<bool> verifySignature({
    required String msg,
    required String signature,
    required String verifyingKey,
    required String dst,
  });
}

class TruthcoinLive extends TruthcoinRPC {
  @override
  final log = GetIt.I.get<Logger>();

  late TruthcoinServiceClient _client;

  TruthcoinLive() : super(binaryType: BinaryType.BINARY_TYPE_TRUTHCOIN) {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30400',
      codec: const ProtoCodec(),
      httpClient: unaryHttpClient(),
    );
    _client = TruthcoinServiceClient(transport);
  }

  @override
  Future<List<String>> binaryArgs() async => [];

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
      initialBlockDownload: true,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  List<String> getMethods() => truthcoinRPCMethods;

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
  Future<List<CoreTransaction>> listTransactions() async => [];

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async {
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
  Future<double> getSidechainWealth() async {
    final resp = await _client.getSidechainWealth(pb.GetSidechainWealthRequest());
    return satoshiToBTC(resp.sats.toInt());
  }

  @override
  Future<String> createDeposit(String address, double amount, double fee) async {
    final resp = await _client.createDeposit(
      pb.CreateDepositRequest(
        address: address,
        valueSats: Int64(btcToSatoshi(amount).toInt()),
        feeSats: Int64(btcToSatoshi(fee).toInt()),
      ),
    );
    return resp.txid;
  }

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async {
    final resp = await _client.getPendingWithdrawalBundle(pb.GetPendingWithdrawalBundleRequest());
    if (resp.bundleJson.isEmpty) return null;
    return PendingWithdrawalBundle.fromMap(jsonDecode(resp.bundleJson));
  }

  @override
  Future<void> connectPeer(String peerAddress) async {
    await _client.connectPeer(pb.ConnectPeerRequest(address: peerAddress));
  }

  @override
  Future<List<Map<String, dynamic>>> listPeers() async {
    final resp = await _client.listPeers(pb.ListPeersRequest());
    if (resp.peersJson.isEmpty) return [];
    return (jsonDecode(resp.peersJson) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    final resp = await _client.mine(pb.MineRequest(feeSats: Int64(feeSats)));
    return BmmResult.fromMap(jsonDecode(resp.bmmResultJson));
  }

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) async {
    final resp = await _client.getBlock(pb.GetBlockRequest(hash: hash));
    if (resp.blockJson.isEmpty) return null;
    return jsonDecode(resp.blockJson) as Map<String, dynamic>;
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
  Future<String> getBMMInclusions(String blockHash) async {
    final resp = await _client.getBmmInclusions(pb.GetBmmInclusionsRequest(blockHash: blockHash));
    return resp.inclusions;
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    final resp = await _client.getWalletUtxos(pb.GetWalletUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    return SidechainUTXO.fromJsonList(jsonDecode(resp.utxosJson) as List<dynamic>);
  }

  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async {
    final resp = await _client.listUtxos(pb.ListUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    return SidechainUTXO.fromJsonList(jsonDecode(resp.utxosJson) as List<dynamic>);
  }

  @override
  Future<void> removeFromMempool(String txid) async {
    await _client.removeFromMempool(pb.RemoveFromMempoolRequest(txid: txid));
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async {
    final resp = await _client.getLatestFailedWithdrawalBundleHeight(pb.GetLatestFailedWithdrawalBundleHeightRequest());
    return resp.height == 0 ? null : resp.height.toInt();
  }

  @override
  Future<String> generateMnemonic() async {
    final resp = await _client.generateMnemonic(pb.GenerateMnemonicRequest());
    return resp.mnemonic;
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    await _client.setSeedFromMnemonic(pb.SetSeedFromMnemonicRequest(mnemonic: mnemonic));
  }

  @override
  Future<void> refreshWallet() async {
    await _client.refreshWallet(pb.RefreshWalletRequest());
  }

  @override
  Future<Map<String, dynamic>?> getTransaction(String txid) async {
    final resp = await _client.getTransaction(pb.GetTransactionRequest(txid: txid));
    if (resp.transactionJson.isEmpty) return null;
    return jsonDecode(resp.transactionJson) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>?> getTransactionInfo(String txid) async {
    final resp = await _client.getTransactionInfo(pb.GetTransactionInfoRequest(txid: txid));
    if (resp.transactionInfoJson.isEmpty) return null;
    return jsonDecode(resp.transactionInfoJson) as Map<String, dynamic>;
  }

  @override
  Future<List<String>> getWalletAddresses() async {
    final resp = await _client.getWalletAddresses(pb.GetWalletAddressesRequest());
    return resp.addresses.toList();
  }

  @override
  Future<List<SidechainUTXO>> myUtxos() async {
    final resp = await _client.myUtxos(pb.MyUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    return SidechainUTXO.fromJsonList(jsonDecode(resp.utxosJson) as List<dynamic>);
  }

  @override
  Future<List<SidechainUTXO>> myUnconfirmedUtxos() async {
    final resp = await _client.myUnconfirmedUtxos(pb.MyUnconfirmedUtxosRequest());
    if (resp.utxosJson.isEmpty) return [];
    return SidechainUTXO.fromJsonList(jsonDecode(resp.utxosJson) as List<dynamic>);
  }

  // Prediction Markets
  @override
  Future<Map<String, dynamic>> calculateInitialLiquidity({
    required double beta,
    int? numOutcomes,
    String? dimensions,
  }) async {
    final resp = await _client.calculateInitialLiquidity(
      pb.CalculateInitialLiquidityRequest(
        beta: beta,
        numOutcomes: numOutcomes,
        dimensions: dimensions,
      ),
    );
    return jsonDecode(resp.resultJson) as Map<String, dynamic>;
  }

  @override
  Future<String> marketCreate({
    required String title,
    required String description,
    required String dimensions,
    required int feeSats,
    double? beta,
    int? initialLiquidity,
    double? tradingFee,
    List<String>? tags,
    List<String>? categoryTxids,
    List<String>? residualNames,
  }) async {
    final resp = await _client.marketCreate(
      pb.MarketCreateRequest(
        title: title,
        description: description,
        dimensions: dimensions,
        feeSats: Int64(feeSats),
        beta: beta,
        initialLiquidity: initialLiquidity != null ? Int64(initialLiquidity) : null,
        tradingFee: tradingFee,
        tags: tags ?? [],
        categoryTxids: categoryTxids ?? [],
        residualNames: residualNames ?? [],
      ),
    );
    return resp.txid;
  }

  @override
  Future<List<Map<String, dynamic>>> marketList() async {
    final resp = await _client.marketList(pb.MarketListRequest());
    if (resp.marketsJson.isEmpty) return [];
    return (jsonDecode(resp.marketsJson) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> marketGet(String marketId) async {
    final resp = await _client.marketGet(pb.MarketGetRequest(marketId: marketId));
    if (resp.marketJson.isEmpty) return null;
    return jsonDecode(resp.marketJson) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> marketBuy({
    required String marketId,
    required int outcomeIndex,
    required double sharesAmount,
    bool? dryRun,
    int? feeSats,
    int? maxCost,
  }) async {
    final resp = await _client.marketBuy(
      pb.MarketBuyRequest(
        marketId: marketId,
        outcomeIndex: outcomeIndex,
        sharesAmount: sharesAmount,
        dryRun: dryRun,
        feeSats: feeSats != null ? Int64(feeSats) : null,
        maxCost: maxCost != null ? Int64(maxCost) : null,
      ),
    );
    return jsonDecode(resp.resultJson) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> marketSell({
    required String marketId,
    required int outcomeIndex,
    required int sharesAmount,
    required String sellerAddress,
    bool? dryRun,
    int? feeSats,
    int? minProceeds,
  }) async {
    final resp = await _client.marketSell(
      pb.MarketSellRequest(
        marketId: marketId,
        outcomeIndex: outcomeIndex,
        sharesAmount: Int64(sharesAmount),
        sellerAddress: sellerAddress,
        dryRun: dryRun,
        feeSats: feeSats != null ? Int64(feeSats) : null,
        minProceeds: minProceeds != null ? Int64(minProceeds) : null,
      ),
    );
    return jsonDecode(resp.resultJson) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> marketPositions({
    String? address,
    String? marketId,
  }) async {
    final resp = await _client.marketPositions(
      pb.MarketPositionsRequest(
        address: address,
        marketId: marketId,
      ),
    );
    return jsonDecode(resp.positionsJson) as Map<String, dynamic>;
  }

  // Slots
  @override
  Future<Map<String, dynamic>> slotStatus() async {
    final resp = await _client.slotStatus(pb.SlotStatusRequest());
    return jsonDecode(resp.statusJson) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> slotList({int? period, String? status}) async {
    final resp = await _client.slotList(
      pb.SlotListRequest(
        period: period,
        status: status,
      ),
    );
    if (resp.slotsJson.isEmpty) return [];
    return (jsonDecode(resp.slotsJson) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> slotGet(String slotId) async {
    final resp = await _client.slotGet(pb.SlotGetRequest(slotId: slotId));
    if (resp.slotJson.isEmpty) return null;
    return jsonDecode(resp.slotJson) as Map<String, dynamic>;
  }

  @override
  Future<String> slotClaim({
    required int feeSats,
    required int periodIndex,
    required int slotIndex,
    required String question,
    required bool isStandard,
    bool? isScaled,
    int? min,
    int? max,
  }) async {
    final resp = await _client.slotClaim(
      pb.SlotClaimRequest(
        feeSats: Int64(feeSats),
        periodIndex: periodIndex,
        slotIndex: slotIndex,
        question: question,
        isStandard: isStandard,
        isScaled: isScaled,
        min: min,
        max: max,
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> slotClaimCategory({
    required List<Map<String, dynamic>> slots,
    required bool isStandard,
    required int feeSats,
  }) async {
    final resp = await _client.slotClaimCategory(
      pb.SlotClaimCategoryRequest(
        slotsJson: jsonEncode(slots),
        isStandard: isStandard,
        feeSats: Int64(feeSats),
      ),
    );
    return resp.txid;
  }

  // Voting
  @override
  Future<String> voteRegister({required int feeSats, int? reputationBondSats}) async {
    final resp = await _client.voteRegister(
      pb.VoteRegisterRequest(
        feeSats: Int64(feeSats),
        reputationBondSats: reputationBondSats != null ? Int64(reputationBondSats) : null,
      ),
    );
    return resp.txid;
  }

  @override
  Future<Map<String, dynamic>?> voteVoter(String address) async {
    final resp = await _client.voteVoter(pb.VoteVoterRequest(address: address));
    if (resp.voterJson.isEmpty) return null;
    return jsonDecode(resp.voterJson) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> voteVoters() async {
    final resp = await _client.voteVoters(pb.VoteVotersRequest());
    if (resp.votersJson.isEmpty) return [];
    return (jsonDecode(resp.votersJson) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<String> voteSubmit({
    required List<Map<String, dynamic>> votes,
    required int feeSats,
  }) async {
    final resp = await _client.voteSubmit(
      pb.VoteSubmitRequest(
        votesJson: jsonEncode(votes),
        feeSats: Int64(feeSats),
      ),
    );
    return resp.txid;
  }

  @override
  Future<List<Map<String, dynamic>>> voteList({
    String? voter,
    String? decisionId,
    int? periodId,
  }) async {
    final resp = await _client.voteList(
      pb.VoteListRequest(
        voter: voter,
        decisionId: decisionId,
        periodId: periodId,
      ),
    );
    if (resp.votesJson.isEmpty) return [];
    return (jsonDecode(resp.votesJson) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> votePeriod({int? periodId}) async {
    final resp = await _client.votePeriod(pb.VotePeriodRequest(periodId: periodId));
    if (resp.periodJson.isEmpty) return null;
    return jsonDecode(resp.periodJson) as Map<String, dynamic>;
  }

  // Votecoin
  @override
  Future<String> votecoinTransfer({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  }) async {
    final resp = await _client.votecoinTransfer(
      pb.VotecoinTransferRequest(
        dest: dest,
        amount: Int64(amount),
        feeSats: Int64(feeSats),
        memo: memo,
      ),
    );
    return resp.txid;
  }

  @override
  Future<int> votecoinBalance(String address) async {
    final resp = await _client.votecoinBalance(pb.VotecoinBalanceRequest(address: address));
    return resp.balance.toInt();
  }

  @override
  Future<String> transferVotecoin({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  }) async {
    final resp = await _client.transferVotecoin(
      pb.TransferVotecoinRequest(
        dest: dest,
        amount: Int64(amount),
        feeSats: Int64(feeSats),
        memo: memo,
      ),
    );
    return resp.txid;
  }

  // Crypto utilities
  @override
  Future<String> getNewEncryptionKey() async {
    final resp = await _client.getNewEncryptionKey(pb.GetNewEncryptionKeyRequest());
    return resp.key;
  }

  @override
  Future<String> getNewVerifyingKey() async {
    final resp = await _client.getNewVerifyingKey(pb.GetNewVerifyingKeyRequest());
    return resp.key;
  }

  @override
  Future<String> encryptMsg({required String msg, required String encryptionPubkey}) async {
    final resp = await _client.encryptMsg(
      pb.EncryptMsgRequest(
        msg: msg,
        encryptionPubkey: encryptionPubkey,
      ),
    );
    return resp.ciphertext;
  }

  @override
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey}) async {
    final resp = await _client.decryptMsg(
      pb.DecryptMsgRequest(
        ciphertext: ciphertext,
        encryptionPubkey: encryptionPubkey,
      ),
    );
    return resp.plaintext;
  }

  @override
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey}) async {
    final resp = await _client.signArbitraryMsg(
      pb.SignArbitraryMsgRequest(
        msg: msg,
        verifyingKey: verifyingKey,
      ),
    );
    return resp.signature;
  }

  @override
  Future<Map<String, dynamic>> signArbitraryMsgAsAddr({required String address, required String msg}) async {
    final resp = await _client.signArbitraryMsgAsAddr(
      pb.SignArbitraryMsgAsAddrRequest(
        msg: msg,
        address: address,
      ),
    );
    return {'verifying_key': resp.verifyingKey, 'signature': resp.signature};
  }

  @override
  Future<bool> verifySignature({
    required String msg,
    required String signature,
    required String verifyingKey,
    required String dst,
  }) async {
    final resp = await _client.verifySignature(
      pb.VerifySignatureRequest(
        msg: msg,
        signature: signature,
        verifyingKey: verifyingKey,
        dst: dst,
      ),
    );
    return resp.valid;
  }
}

final truthcoinRPCMethods = [
  'bitcoin_balance',
  'calculate_initial_liquidity',
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
  'get_transaction',
  'get_transaction_info',
  'get_wallet_addresses',
  'get_wallet_utxos',
  'getblockcount',
  'latest_failed_withdrawal_bundle_height',
  'list_peers',
  'list_utxos',
  'market_buy',
  'market_create',
  'market_get',
  'market_list',
  'market_positions',
  'market_sell',
  'mine',
  'my_unconfirmed_utxos',
  'my_utxos',
  'openapi_schema',
  'pending_withdrawal_bundle',
  'refresh_wallet',
  'remove_from_mempool',
  'set_seed_from_mnemonic',
  'sidechain_wealth_sats',
  'sign_arbitrary_msg',
  'sign_arbitrary_msg_as_addr',
  'slot_claim',
  'slot_claim_category',
  'slot_get',
  'slot_list',
  'slot_status',
  'stop',
  'transfer',
  'transfer_votecoin',
  'verify_signature',
  'vote_list',
  'vote_period',
  'vote_register',
  'vote_submit',
  'vote_voter',
  'vote_voters',
  'votecoin_balance',
  'votecoin_transfer',
  'withdraw',
];
