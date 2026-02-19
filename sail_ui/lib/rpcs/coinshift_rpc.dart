import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// API to the CoinShift server.
abstract class CoinShiftRPC extends SidechainRPC {
  CoinShiftRPC({
    required super.binaryType,
    required super.restartOnFailure,
  });

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
  Future<String> claimSwap(List<int> swapId, {String? l2ClaimerAddress});

  /// Get swap status
  Future<CoinShiftSwap?> getSwapStatus(List<int> swapId);

  /// List all swaps
  Future<List<CoinShiftSwap>> listSwaps();

  /// List swaps for a specific recipient
  Future<List<CoinShiftSwap>> listSwapsByRecipient(String recipient);

  /// Update swap L1 transaction ID
  Future<void> updateSwapL1Txid({
    required List<int> swapId,
    required String l1TxidHex,
    required int confirmations,
  });

  /// Reconstruct all swaps from blockchain
  Future<int> reconstructSwaps();
}

class CoinShiftLive extends CoinShiftRPC {
  @override
  final log = GetIt.I.get<Logger>();

  RPCClient _client() {
    final client = RPCClient(
      host: '127.0.0.1',
      port: binary.port,
      username: 'N/A',
      password: 'N/A',
      useSSL: false,
    );

    client.dioClient = Dio();
    return client;
  }

  CoinShiftLive()
    : super(
        binaryType: BinaryType.coinShift,
        restartOnFailure: false,
      ) {
    startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs() async {
    return binary.extraBootArgs;
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
  Future<(double, double)> balance() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    final totalSats = response['total_sats'] as int;
    final availableSats = response['available_sats'] as int;

    // Convert from sats to BTC
    final confirmed = satoshiToBTC(availableSats);
    final unconfirmed = satoshiToBTC(totalSats - availableSats);

    return (confirmed, unconfirmed);
  }

  @override
  Future<int> getBlockCount() async {
    return await _client().call('getblockcount') as int;
  }

  @override
  Future<void> stopRPC() async {
    await _client().call('stop');
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final blocks = await _client().call('getblockcount') as int;

    // There's no endpoint to get headers for coinshift, so we get the height
    // from the public explorer service, assuming it is fully synced
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
  List<String> getMethods() {
    return coinShiftRPCMethods;
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
    return await formatDepositAddress(response);
  }

  @override
  Future<String> getSideAddress() async {
    final response = await _client().call('get_new_address');
    return response as String;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return [];
  }

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async {
    final response = await _client().call('withdraw', {
      'mainchain_address': address,
      'amount_sats': amountSats,
      'fee_sats': sidechainFeeSats,
      'mainchain_fee_sats': mainchainFeeSats,
    });
    return response as String;
  }

  @override
  Future<double> sideEstimateFee() async {
    // CoinShift has fixed fees for now
    return 0.00001;
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final response = await _client().call('transfer', {
      'dest': address,
      'value_sats': btcToSatoshi(amount).toInt(),
      'fee_sats': btcToSatoshi(0.00001).toInt(),
    });
    return response as String;
  }

  /// Get total sidechain wealth in BTC
  @override
  Future<double> getSidechainWealth() async {
    final wealthSats = await _client().call('sidechain_wealth_sats') as int;
    return satoshiToBTC(wealthSats);
  }

  /// Create a deposit transaction
  @override
  Future<String> createDeposit(String address, double amount, double fee) async {
    final response = await _client().call('create_deposit', {
      'address': address,
      'value_sats': btcToSatoshi(amount),
      'fee_sats': btcToSatoshi(fee),
    });
    return response as String;
  }

  /// Get pending withdrawal bundle
  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async {
    final response = await _client().call('pending_withdrawal_bundle');
    return PendingWithdrawalBundle.fromMap(response);
  }

  /// Connect to a peer
  @override
  Future<void> connectPeer(String peerAddress) async {
    await _client().call('connect_peer', peerAddress);
  }

  /// Forget a peer (remove from known_peers DB)
  @override
  Future<void> forgetPeer(String peerAddress) async {
    await _client().call('forget_peer', peerAddress);
  }

  /// List connected peers
  @override
  Future<List<Map<String, dynamic>>> listPeers() async {
    final response = await _client().call('list_peers') as List<dynamic>;
    return response.cast<Map<String, dynamic>>();
  }

  /// Mine a block with optional coinbase value
  @override
  Future<BmmResult> mine(int feeSats) async {
    final response = await _client().call('mine', feeSats > 0 ? feeSats : null);
    return BmmResult.fromMap(response);
  }

  /// Get block by hash
  @override
  Future<Map<String, dynamic>?> getBlock(String hash) async {
    final response = await _client().call('get_block', hash);
    return response as Map<String, dynamic>?;
  }

  /// Get best mainchain block hash
  @override
  Future<String?> getBestMainchainBlockHash() async {
    final response = await _client().call('get_best_mainchain_block_hash');
    return response as String?;
  }

  /// Get best sidechain block hash
  @override
  Future<String?> getBestSidechainBlockHash() async {
    final response = await _client().call('get_best_sidechain_block_hash');
    return response as String?;
  }

  /// Get BMM inclusions
  @override
  Future<String> getBMMInclusions(String blockHash) async {
    final response = await _client().call('get_bmm_inclusions', blockHash);
    return response as String;
  }

  /// List wallet UTXOs
  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    final response = await _client().call('get_wallet_utxos') as List<dynamic>;
    return SidechainUTXO.fromJsonList(response);
  }

  /// List all UTXOs (not just wallet UTXOs)
  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async {
    final response = await _client().call('list_utxos') as List<dynamic>;
    return SidechainUTXO.fromJsonList(response);
  }

  /// Remove transaction from mempool
  @override
  Future<void> removeFromMempool(String txid) async {
    await _client().call('remove_from_mempool', txid);
  }

  /// Get latest failed withdrawal bundle height
  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async {
    final response = await _client().call('latest_failed_withdrawal_bundle_height');
    return response as int?;
  }

  /// Generate new mnemonic
  @override
  Future<String> generateMnemonic() async {
    final response = await _client().call('generate_mnemonic');
    return response as String;
  }

  /// Set seed from mnemonic
  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    await _client().call('set_seed_from_mnemonic', mnemonic);
  }

  /// Get wallet addresses
  @override
  Future<List<String>> getWalletAddresses() async {
    final response = await _client().call('get_wallet_addresses') as List<dynamic>;
    return response.cast<String>();
  }

  /// Format deposit address
  @override
  Future<String> formatDepositAddress(String address) async {
    final response = await _client().call('format_deposit_address', address);
    return response as String;
  }

  /// Get OpenAPI schema
  @override
  Future<Map<String, dynamic>> getOpenAPISchema() async {
    final response = await _client().call('openapi_schema');
    return response as Map<String, dynamic>;
  }

  // Swap methods

  /// Create a swap (L2 → L1)
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
    final response = await _client().call('create_swap', {
      'l2_amount_sats': l2AmountSats,
      'l1_amount_sats': l1AmountSats,
      'l1_recipient_address': l1RecipientAddress,
      'parent_chain': parentChain,
      'l2_recipient': l2Recipient,
      'required_confirmations': requiredConfirmations,
      'fee_sats': feeSats,
    });
    return CoinShiftSwapCreateResult.fromMap(response as Map<String, dynamic>);
  }

  /// Claim a swap (after L1 transaction has required confirmations)
  @override
  Future<String> claimSwap(List<int> swapId, {String? l2ClaimerAddress}) async {
    final response = await _client().call('claim_swap', {
      'swap_id': swapId,
      'l2_claimer_address': l2ClaimerAddress,
    });
    return response as String;
  }

  /// Get swap status
  @override
  Future<CoinShiftSwap?> getSwapStatus(List<int> swapId) async {
    final response = await _client().call('get_swap_status', swapId);
    if (response == null) return null;
    return CoinShiftSwap.fromMap(response as Map<String, dynamic>);
  }

  /// List all swaps
  @override
  Future<List<CoinShiftSwap>> listSwaps() async {
    final response = await _client().call('list_swaps') as List<dynamic>;
    return response.map((e) => CoinShiftSwap.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// List swaps for a specific recipient
  @override
  Future<List<CoinShiftSwap>> listSwapsByRecipient(String recipient) async {
    final response = await _client().call('list_swaps_by_recipient', recipient) as List<dynamic>;
    return response.map((e) => CoinShiftSwap.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// Update swap L1 transaction ID
  @override
  Future<void> updateSwapL1Txid({
    required List<int> swapId,
    required String l1TxidHex,
    required int confirmations,
  }) async {
    await _client().call('update_swap_l1_txid', {
      'swap_id': swapId,
      'l1_txid_hex': l1TxidHex,
      'confirmations': confirmations,
    });
  }

  /// Reconstruct all swaps from blockchain
  @override
  Future<int> reconstructSwaps() async {
    final response = await _client().call('reconstruct_swaps');
    return response as int;
  }
}

/// Result from creating a swap
class CoinShiftSwapCreateResult {
  final List<int> swapId;
  final String txid;

  CoinShiftSwapCreateResult({required this.swapId, required this.txid});

  factory CoinShiftSwapCreateResult.fromMap(Map<String, dynamic> map) {
    return CoinShiftSwapCreateResult(
      swapId: (map['0'] as List<dynamic>).cast<int>(),
      txid: map['1'] as String,
    );
  }
}

/// Parent chain type for swaps
enum ParentChainType {
  btc,
  bch,
  ltc,
  signet,
  regtest;

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
  l1ToL2;

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
  final List<int> id;
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
      id: (map['id'] as List<dynamic>).cast<int>(),
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

  static String? _extractTxid(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      // Handle {Some: "txid"} or similar wrapper
      if (value.containsKey('Some')) return value['Some'] as String?;
    }
    return null;
  }

  /// Get swap ID as hex string
  String get idHex => id.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
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
