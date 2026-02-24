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

/// API to the truthcoin server.
abstract class TruthcoinRPC extends SidechainRPC {
  TruthcoinRPC({
    required super.binaryType,
    required super.restartOnFailure,
  });

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
  Future<Map<String, dynamic>> marketPositions({String? address, String? marketId});

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
  Future<String> voteSubmit({required List<Map<String, dynamic>> votes, required int feeSats});

  /// List votes with optional filters
  Future<List<Map<String, dynamic>>> voteList({String? voter, String? decisionId, int? periodId});

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
  Future<String> encryptMsg({required String msg, required String encryptionPubkey});

  /// Decrypt a message
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey});

  /// Sign an arbitrary message with verifying key
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey});

  /// Sign an arbitrary message as address
  Future<Map<String, dynamic>> signArbitraryMsgAsAddr({required String address, required String msg});

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

  TruthcoinLive()
    : super(
        binaryType: BinaryType.truthcoin,
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
    final response = await _client().call('bitcoin_balance') as Map<String, dynamic>;
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

    // There's no endpoint to get headers for truthcoin, so we get the height
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
    return truthcoinRPCMethods;
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
    // Truthcoin has fixed fees for now
    return 0.00001;
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final response = await _client().call('transfer', {
      'dest': address,
      'value': btcToSatoshi(amount).toInt(),
      'fee': btcToSatoshi(0.00001).toInt(),
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

  /// List connected peers
  @override
  Future<List<Map<String, dynamic>>> listPeers() async {
    final response = await _client().call('list_peers') as List<dynamic>;
    return response.cast<Map<String, dynamic>>();
  }

  /// Mine a block with optional coinbase value
  @override
  Future<BmmResult> mine(int feeSats) async {
    final response = await _client().call('mine', feeSats);
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

  /// Refresh wallet
  @override
  Future<void> refreshWallet() async {
    await _client().call('refresh_wallet');
  }

  /// Get transaction by txid
  @override
  Future<Map<String, dynamic>?> getTransaction(String txid) async {
    final response = await _client().call('get_transaction', txid);
    return response as Map<String, dynamic>?;
  }

  /// Get transaction info
  @override
  Future<Map<String, dynamic>?> getTransactionInfo(String txid) async {
    final response = await _client().call('get_transaction_info', txid);
    return response as Map<String, dynamic>?;
  }

  /// Get wallet addresses
  @override
  Future<List<String>> getWalletAddresses() async {
    final response = await _client().call('get_wallet_addresses') as List<dynamic>;
    return response.cast<String>();
  }

  /// Get owned UTXOs (confirmed)
  @override
  Future<List<SidechainUTXO>> myUtxos() async {
    final response = await _client().call('my_utxos') as List<dynamic>;
    return SidechainUTXO.fromJsonList(response);
  }

  /// Get owned UTXOs (unconfirmed)
  @override
  Future<List<SidechainUTXO>> myUnconfirmedUtxos() async {
    final response = await _client().call('my_unconfirmed_utxos') as List<dynamic>;
    return SidechainUTXO.fromJsonList(response);
  }

  // Prediction Markets
  @override
  Future<Map<String, dynamic>> calculateInitialLiquidity({
    required double beta,
    int? numOutcomes,
    String? dimensions,
  }) async {
    final params = <String, dynamic>{'beta': beta};
    if (numOutcomes != null) params['num_outcomes'] = numOutcomes;
    if (dimensions != null) params['dimensions'] = dimensions;
    final response = await _client().call('calculate_initial_liquidity', params);
    return response as Map<String, dynamic>;
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
    final params = <String, dynamic>{
      'title': title,
      'description': description,
      'dimensions': dimensions,
      'fee_sats': feeSats,
    };
    if (beta != null) params['beta'] = beta;
    if (initialLiquidity != null) params['initial_liquidity'] = initialLiquidity;
    if (tradingFee != null) params['trading_fee'] = tradingFee;
    if (tags != null) params['tags'] = tags;
    if (categoryTxids != null) params['category_txids'] = categoryTxids;
    if (residualNames != null) params['residual_names'] = residualNames;
    final response = await _client().call('market_create', params);
    return response as String;
  }

  @override
  Future<List<Map<String, dynamic>>> marketList() async {
    final response = await _client().call('market_list') as List<dynamic>;
    return response.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> marketGet(String marketId) async {
    final response = await _client().call('market_get', marketId);
    return response as Map<String, dynamic>?;
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
    final params = <String, dynamic>{
      'market_id': marketId,
      'outcome_index': outcomeIndex,
      'shares_amount': sharesAmount,
    };
    if (dryRun != null) params['dry_run'] = dryRun;
    if (feeSats != null) params['fee_sats'] = feeSats;
    if (maxCost != null) params['max_cost'] = maxCost;
    final response = await _client().call('market_buy', params);
    return response as Map<String, dynamic>;
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
    final params = <String, dynamic>{
      'market_id': marketId,
      'outcome_index': outcomeIndex,
      'shares_amount': sharesAmount,
      'seller_address': sellerAddress,
    };
    if (dryRun != null) params['dry_run'] = dryRun;
    if (feeSats != null) params['fee_sats'] = feeSats;
    if (minProceeds != null) params['min_proceeds'] = minProceeds;
    final response = await _client().call('market_sell', params);
    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> marketPositions({String? address, String? marketId}) async {
    final params = <String, dynamic>{};
    if (address != null) params['address'] = address;
    if (marketId != null) params['market_id'] = marketId;
    final response = await _client().call('market_positions', params);
    return response as Map<String, dynamic>;
  }

  // Slots
  @override
  Future<Map<String, dynamic>> slotStatus() async {
    final response = await _client().call('slot_status');
    return response as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> slotList({int? period, String? status}) async {
    Map<String, dynamic>? params;
    if (period != null || status != null) {
      params = <String, dynamic>{};
      if (period != null) params['period'] = period;
      if (status != null) params['status'] = status;
    }
    final response = await _client().call('slot_list', params) as List<dynamic>;
    return response.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> slotGet(String slotId) async {
    final response = await _client().call('slot_get', slotId);
    return response as Map<String, dynamic>?;
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
    final params = <String, dynamic>{
      'fee_sats': feeSats,
      'period_index': periodIndex,
      'slot_index': slotIndex,
      'question': question,
      'is_standard': isStandard,
    };
    if (isScaled != null) params['is_scaled'] = isScaled;
    if (min != null) params['min'] = min;
    if (max != null) params['max'] = max;
    final response = await _client().call('slot_claim', params);
    return response as String;
  }

  @override
  Future<String> slotClaimCategory({
    required List<Map<String, dynamic>> slots,
    required bool isStandard,
    required int feeSats,
  }) async {
    final response = await _client().call('slot_claim_category', {
      'slots': slots,
      'is_standard': isStandard,
      'fee_sats': feeSats,
    });
    return response as String;
  }

  // Voting
  @override
  Future<String> voteRegister({required int feeSats, int? reputationBondSats}) async {
    final params = <String, dynamic>{'fee_sats': feeSats};
    if (reputationBondSats != null) params['reputation_bond_sats'] = reputationBondSats;
    final response = await _client().call('vote_register', params);
    return response as String;
  }

  @override
  Future<Map<String, dynamic>?> voteVoter(String address) async {
    final response = await _client().call('vote_voter', address);
    return response as Map<String, dynamic>?;
  }

  @override
  Future<List<Map<String, dynamic>>> voteVoters() async {
    final response = await _client().call('vote_voters') as List<dynamic>;
    return response.cast<Map<String, dynamic>>();
  }

  @override
  Future<String> voteSubmit({required List<Map<String, dynamic>> votes, required int feeSats}) async {
    final response = await _client().call('vote_submit', {
      'votes': votes,
      'fee_sats': feeSats,
    });
    return response as String;
  }

  @override
  Future<List<Map<String, dynamic>>> voteList({String? voter, String? decisionId, int? periodId}) async {
    final params = <String, dynamic>{};
    if (voter != null) params['voter'] = voter;
    if (decisionId != null) params['decision_id'] = decisionId;
    if (periodId != null) params['period_id'] = periodId;
    final response = await _client().call('vote_list', params) as List<dynamic>;
    return response.cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>?> votePeriod({int? periodId}) async {
    final response = await _client().call('vote_period', periodId);
    return response as Map<String, dynamic>?;
  }

  // Votecoin
  @override
  Future<String> votecoinTransfer({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  }) async {
    final params = <String, dynamic>{
      'dest': dest,
      'amount': amount,
      'fee_sats': feeSats,
    };
    if (memo != null) params['memo'] = memo;
    final response = await _client().call('votecoin_transfer', params);
    return response as String;
  }

  @override
  Future<int> votecoinBalance(String address) async {
    final response = await _client().call('votecoin_balance', address);
    return response as int;
  }

  @override
  Future<String> transferVotecoin({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  }) async {
    final params = <String, dynamic>{
      'dest': dest,
      'amount': amount,
      'fee_sats': feeSats,
    };
    if (memo != null) params['memo'] = memo;
    final response = await _client().call('transfer_votecoin', params);
    return response as String;
  }

  // Crypto utilities
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
  Future<String> encryptMsg({required String msg, required String encryptionPubkey}) async {
    final response = await _client().call('encrypt_msg', {
      'msg': msg,
      'encryption_pubkey': encryptionPubkey,
    });
    return response as String;
  }

  @override
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey}) async {
    final response = await _client().call('decrypt_msg', {
      'ciphertext': ciphertext,
      'encryption_pubkey': encryptionPubkey,
    });
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
  Future<Map<String, dynamic>> signArbitraryMsgAsAddr({required String address, required String msg}) async {
    final response = await _client().call('sign_arbitrary_msg_as_addr', {
      'address': address,
      'msg': msg,
    });
    return response as Map<String, dynamic>;
  }

  @override
  Future<bool> verifySignature({
    required String msg,
    required String signature,
    required String verifyingKey,
    required String dst,
  }) async {
    final response = await _client().call('verify_signature', {
      'msg': msg,
      'signature': signature,
      'verifying_key': verifyingKey,
      'dst': dst,
    });
    return response as bool;
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
