import 'dart:convert';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart' as bitcoin;
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/coinshift/v1/coinshift.connect.client.dart';
import 'package:sail_ui/gen/coinshift/v1/coinshift.pb.dart' as pb;
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// API to the CoinShift server.
abstract class CoinShiftRPC extends SidechainRPC {
  CoinShiftRPC({required super.binaryType});

  /// Get total sidechain wealth in BTC
  Future<double> getSidechainWealth();

  /// Create a deposit transaction
  Future<String> createDeposit(String address, double amount, double fee);

  /// Connect to a peer
  Future<void> connectPeer(String peerAddress);

  /// Forget a peer (remove from known_peers DB)
  Future<void> forgetPeer(String peerAddress);

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

  /// Get wallet addresses
  Future<List<String>> getWalletAddresses();

  /// Format deposit address
  Future<String> formatDepositAddress(String address);

  /// Get OpenAPI schema
  Future<Map<String, dynamic>> getOpenAPISchema();

  // Swap methods

  /// Create a swap (L2 → L1)
  Future<CoinShiftSwapCreateResult> createSwap({
    required int l2AmountSats,
    required int l1AmountSats,
    required String l1RecipientAddress,
    required String parentChain,
    String? l2Recipient,
    int? requiredConfirmations,
    required int feeSats,
  });

  /// Claim a swap (after L1 transaction has required confirmations)
  Future<String> claimSwap(String swapId, {String? l2ClaimerAddress});

  /// Get swap status
  Future<CoinShiftSwap?> getSwapStatus(String swapId);

  /// List all swaps
  Future<List<CoinShiftSwap>> listSwaps();

  /// List swaps for a specific recipient
  Future<List<CoinShiftSwap>> listSwapsByRecipient(String recipient);

  /// Update swap L1 transaction ID
  Future<void> updateSwapL1Txid({
    required String swapId,
    required String l1TxidHex,
    required int confirmations,
  });

  /// Reconstruct all swaps from blockchain
  Future<int> reconstructSwaps();
}

class CoinShiftLive extends CoinShiftRPC {
  @override
  final log = GetIt.I.get<Logger>();

  late CoinShiftServiceClient _client;

  CoinShiftLive() : super(binaryType: BinaryType.coinShift) {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30400',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );
    _client = CoinShiftServiceClient(transport);
  }

  @override
  Future<List<String>> binaryArgs() async => [];

  @override
  Future<(double, double)> balance() async {
    final resp = await _client.getBalance(pb.GetBalanceRequest());
    final confirmed = bitcoin.satoshiToBTC(resp.availableSats.toInt());
    final unconfirmed = bitcoin.satoshiToBTC((resp.totalSats - resp.availableSats).toInt());
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
  List<String> getMethods() => coinShiftRPCMethods;

  @override
  Future<dynamic> callRAW(String method, [List<dynamic>? params]) async {
    final paramsJson = params != null ? jsonEncode(params) : '';
    final resp = await _client.callRaw(pb.CallRawRequest(method: method, paramsJson: paramsJson));
    if (resp.resultJson.isEmpty) return null;
    return jsonDecode(resp.resultJson);
  }

  @override
  Future<String> getDepositAddress() async {
    final resp = await _client.getNewAddress(pb.GetNewAddressRequest());
    return bitcoin.formatDepositAddress(resp.address, chain.slot);
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
        amountSats: Int64(bitcoin.btcToSatoshi(amount).toInt()),
        feeSats: Int64(bitcoin.btcToSatoshi(0.00001).toInt()),
      ),
    );
    return resp.txid;
  }

  @override
  Future<double> getSidechainWealth() async {
    final resp = await _client.getSidechainWealth(pb.GetSidechainWealthRequest());
    return bitcoin.satoshiToBTC(resp.sats.toInt());
  }

  @override
  Future<String> createDeposit(String address, double amount, double fee) async {
    final resp = await _client.createDeposit(
      pb.CreateDepositRequest(
        address: address,
        valueSats: Int64(bitcoin.btcToSatoshi(amount).toInt()),
        feeSats: Int64(bitcoin.btcToSatoshi(fee).toInt()),
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
  Future<void> forgetPeer(String peerAddress) async {
    await _client.forgetPeer(pb.ForgetPeerRequest(address: peerAddress));
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
  Future<List<String>> getWalletAddresses() async {
    final resp = await _client.getWalletAddresses(pb.GetWalletAddressesRequest());
    return resp.addresses.toList();
  }

  @override
  Future<String> formatDepositAddress(String address) async {
    // Use callRAW for methods not in the proto service
    final resp = await _client.callRaw(
      pb.CallRawRequest(
        method: 'format_deposit_address',
        paramsJson: jsonEncode(address),
      ),
    );
    return jsonDecode(resp.resultJson) as String;
  }

  @override
  Future<Map<String, dynamic>> getOpenAPISchema() async {
    final resp = await _client.openapiSchema(pb.OpenapiSchemaRequest());
    return jsonDecode(resp.schemaJson) as Map<String, dynamic>;
  }

  // Swap methods

  @override
  Future<CoinShiftSwapCreateResult> createSwap({
    required int l2AmountSats,
    required int l1AmountSats,
    required String l1RecipientAddress,
    required String parentChain,
    String? l2Recipient,
    int? requiredConfirmations,
    required int feeSats,
  }) async {
    final resp = await _client.createSwap(
      pb.CreateSwapRequest(
        l2AmountSats: Int64(l2AmountSats),
        l1AmountSats: Int64(l1AmountSats),
        l1RecipientAddress: l1RecipientAddress,
        parentChain: parentChain,
        l2Recipient: l2Recipient,
        requiredConfirmations: requiredConfirmations,
        feeSats: Int64(feeSats),
      ),
    );
    return CoinShiftSwapCreateResult(swapId: resp.swapId, txid: resp.txid);
  }

  @override
  Future<String> claimSwap(String swapId, {String? l2ClaimerAddress}) async {
    final resp = await _client.claimSwap(
      pb.ClaimSwapRequest(
        swapId: swapId,
        l2ClaimerAddress: l2ClaimerAddress,
      ),
    );
    return resp.txid;
  }

  @override
  Future<CoinShiftSwap?> getSwapStatus(String swapId) async {
    final resp = await _client.getSwapStatus(pb.GetSwapStatusRequest(swapId: swapId));
    if (resp.swapJson.isEmpty) return null;
    return CoinShiftSwap.fromMap(jsonDecode(resp.swapJson) as Map<String, dynamic>);
  }

  @override
  Future<List<CoinShiftSwap>> listSwaps() async {
    final resp = await _client.listSwaps(pb.ListSwapsRequest());
    if (resp.swapsJson.isEmpty) return [];
    return (jsonDecode(resp.swapsJson) as List<dynamic>)
        .map((e) => CoinShiftSwap.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CoinShiftSwap>> listSwapsByRecipient(String recipient) async {
    final resp = await _client.listSwapsByRecipient(pb.ListSwapsByRecipientRequest(recipient: recipient));
    if (resp.swapsJson.isEmpty) return [];
    return (jsonDecode(resp.swapsJson) as List<dynamic>)
        .map((e) => CoinShiftSwap.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateSwapL1Txid({
    required String swapId,
    required String l1TxidHex,
    required int confirmations,
  }) async {
    await _client.updateSwapL1Txid(
      pb.UpdateSwapL1TxidRequest(
        swapId: swapId,
        l1TxidHex: l1TxidHex,
        confirmations: confirmations,
      ),
    );
  }

  @override
  Future<int> reconstructSwaps() async {
    final resp = await _client.reconstructSwaps(pb.ReconstructSwapsRequest());
    return resp.count.toInt();
  }
}

/// Result from creating a swap
class CoinShiftSwapCreateResult {
  final String swapId;
  final String txid;

  CoinShiftSwapCreateResult({required this.swapId, required this.txid});

  factory CoinShiftSwapCreateResult.fromMap(Map<String, dynamic> map) {
    return CoinShiftSwapCreateResult(
      swapId: _parseSwapId(map['swap_id'] ?? map['0']),
      txid: (map['txid'] ?? map['1']) as String,
    );
  }

  static String _parseSwapId(dynamic value) {
    if (value is String) return value;
    if (value is List) {
      return (value).map((b) => (b as int).toRadixString(16).padLeft(2, '0')).join();
    }
    return value.toString();
  }
}

/// Parent chain type for swaps
enum ParentChainType {
  btc,
  bch,
  ltc,
  signet,
  regtest
  ;

  String get value => switch (this) {
    ParentChainType.btc => 'BTC',
    ParentChainType.bch => 'BCH',
    ParentChainType.ltc => 'LTC',
    ParentChainType.signet => 'Signet',
    ParentChainType.regtest => 'Regtest',
  };

  static ParentChainType fromString(String value) {
    return ParentChainType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ParentChainType.signet,
    );
  }
}

/// Swap direction
enum SwapDirection {
  l2ToL1,
  l1ToL2
  ;

  static SwapDirection fromString(String value) {
    return switch (value) {
      'L2ToL1' => SwapDirection.l2ToL1,
      'L1ToL2' => SwapDirection.l1ToL2,
      _ => SwapDirection.l2ToL1,
    };
  }
}

/// Swap state
class SwapState {
  final String state;
  final int? currentConfirmations;
  final int? requiredConfirmations;

  bool get isPending => state == 'Pending';
  bool get isWaitingConfirmations => state == 'WaitingConfirmations';
  bool get isReadyToClaim => state == 'ReadyToClaim';
  bool get isCompleted => state == 'Completed';
  bool get isCancelled => state == 'Cancelled';

  SwapState({
    required this.state,
    this.currentConfirmations,
    this.requiredConfirmations,
  });

  factory SwapState.fromDynamic(dynamic value) {
    if (value is String) {
      return SwapState(state: value);
    }
    if (value is Map<String, dynamic>) {
      if (value.containsKey('WaitingConfirmations')) {
        final confs = value['WaitingConfirmations'] as List<dynamic>;
        return SwapState(
          state: 'WaitingConfirmations',
          currentConfirmations: confs[0] as int,
          requiredConfirmations: confs[1] as int,
        );
      }
    }
    return SwapState(state: 'Unknown');
  }

  @override
  String toString() {
    if (isWaitingConfirmations) {
      return 'Waiting ($currentConfirmations/$requiredConfirmations)';
    }
    return state;
  }
}

/// CoinShift swap data structure
class CoinShiftSwap {
  final String id;
  final SwapDirection direction;
  final ParentChainType parentChain;
  final String? l1Txid;
  final int requiredConfirmations;
  final SwapState state;
  final int l2Amount;
  final int createdAtHeight;
  final int? expiresAtHeight;
  final int? l1Amount;
  final String? l1ClaimerAddress;
  final String? l1RecipientAddress;
  final String? l1TxidValidatedAtBlockHash;
  final int? l1TxidValidatedAtHeight;
  final String? l2Recipient;

  CoinShiftSwap({
    required this.id,
    required this.direction,
    required this.parentChain,
    this.l1Txid,
    required this.requiredConfirmations,
    required this.state,
    required this.l2Amount,
    required this.createdAtHeight,
    this.expiresAtHeight,
    this.l1Amount,
    this.l1ClaimerAddress,
    this.l1RecipientAddress,
    this.l1TxidValidatedAtBlockHash,
    this.l1TxidValidatedAtHeight,
    this.l2Recipient,
  });

  factory CoinShiftSwap.fromMap(Map<String, dynamic> map) {
    return CoinShiftSwap(
      id: _parseSwapId(map['id']),
      direction: SwapDirection.fromString(map['direction'] as String),
      parentChain: ParentChainType.fromString(map['parent_chain'] as String),
      l1Txid: _extractTxid(map['l1_txid']),
      requiredConfirmations: map['required_confirmations'] as int,
      state: SwapState.fromDynamic(map['state']),
      l2Amount: map['l2_amount'] as int,
      createdAtHeight: map['created_at_height'] as int,
      expiresAtHeight: map['expires_at_height'] as int?,
      l1Amount: map['l1_amount'] as int?,
      l1ClaimerAddress: map['l1_claimer_address'] as String?,
      l1RecipientAddress: map['l1_recipient_address'] as String?,
      l1TxidValidatedAtBlockHash: map['l1_txid_validated_at_block_hash'] as String?,
      l1TxidValidatedAtHeight: map['l1_txid_validated_at_height'] as int?,
      l2Recipient: map['l2_recipient'] as String?,
    );
  }

  static String _parseSwapId(dynamic value) {
    if (value is String) return value;
    if (value is List) {
      return (value).map((b) => (b as int).toRadixString(16).padLeft(2, '0')).join();
    }
    return value.toString();
  }

  static String? _extractTxid(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      // Handle {Some: "txid"} or similar wrapper
      if (value.containsKey('Some')) return value['Some'] as String?;
    }
    return null;
  }

  /// Get swap ID as hex string (for display)
  String get idHex => id;
}

final coinShiftRPCMethods = [
  'balance',
  'claim_swap',
  'connect_peer',
  'create_deposit',
  'create_swap',
  'forget_peer',
  'format_deposit_address',
  'generate_mnemonic',
  'get_best_mainchain_block_hash',
  'get_best_sidechain_block_hash',
  'get_block',
  'get_bmm_inclusions',
  'get_new_address',
  'get_swap_status',
  'get_wallet_addresses',
  'get_wallet_utxos',
  'getblockcount',
  'latest_failed_withdrawal_bundle_height',
  'list_peers',
  'list_swaps',
  'list_swaps_by_recipient',
  'list_utxos',
  'mine',
  'openapi_schema',
  'pending_withdrawal_bundle',
  'reconstruct_swaps',
  'remove_from_mempool',
  'set_seed_from_mnemonic',
  'sidechain_wealth_sats',
  'stop',
  'transfer',
  'update_swap_l1_txid',
  'withdraw',
];
