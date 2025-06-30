import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/sidechains.dart';
import 'package:sail_ui/providers/binaries/binary_provider.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

final log = GetIt.I.get<Logger>();

/// API to the thunder server.
abstract class ThunderRPC extends SidechainRPC {
  ThunderRPC({
    required super.conf,
    required super.binary,
    required super.restartOnFailure,
    required super.chain,
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

  /// Get latest failed withdrawal bundle height
  Future<int?> getLatestFailedWithdrawalBundleHeight();

  /// Generate new mnemonic
  Future<String> generateMnemonic();

  /// Set seed from mnemonic
  Future<void> setSeedFromMnemonic(String mnemonic);
}

class ThunderLive extends ThunderRPC {
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
  ThunderLive._create({
    required super.conf,
    required super.binary,
    required super.restartOnFailure,
    required super.chain,
  });

  // Async factory
  static Future<ThunderLive> create({
    required Binary binary,
    required Sidechain chain,
  }) async {
    final conf = await readConf();

    final instance = ThunderLive._create(
      conf: conf,
      binary: binary,
      restartOnFailure: false,
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
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final thunderBinary = binaryProvider.binaries.where((b) => b.name == binary.name).first;

    return thunderBinary.extraBootArgs;
  }

  @override
  Future<int> ping() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    return response['total_sats'] as int;
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
  Future<void> stopRPC() async {
    await _client().call('stop');
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final blocks = await _client().call('getblockcount') as int;
    final bestBlockHash = await getBestSidechainBlockHash();
    return BlockchainInfo(
      chain: 'signet',
      blocks: blocks,
      headers: blocks,
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
    return thunderRPCMethods;
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
    final response = await _client().call('withdraw', [
      address,
      amountSats,
      sidechainFeeSats,
      mainchainFeeSats,
    ]);
    return response as String;
  }

  @override
  Future<double> sideEstimateFee() async {
    // Thunder has fixed fees for now
    return 0.00001;
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final response = await _client().call('transfer', {
      'dest': address,
      'value_sats': btcToSatoshi(amount),
      'fee_sats': btcToSatoshi(0.00001), // Fixed fee
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
    final response = await _client().call('mine', [feeSats]);
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

  /// List all UTXOs
  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    final response = await _client().call('get_wallet_utxos') as List<dynamic>;
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
}

final thunderRPCMethods = [
  'balance',
  'connect_peer',
  'create_deposit',
  'format_deposit_address',
  'generate_mnemonic',
  'get_best_mainchain_block_hash',
  'get_best_sidechain_block_hash',
  'get_block',
  'get_bmm_inclusions',
  'get_new_address',
  'get_wallet_addresses',
  'get_wallet_utxos',
  'getblockcount',
  'latest_failed_withdrawal_bundle_height',
  'list_peers',
  'list_utxos',
  'mine',
  'pending_withdrawal_bundle',
  'openapi_schema',
  'remove_from_mempool',
  'set_seed_from_mnemonic',
  'sidechain_wealth_sats',
  'stop',
  'transfer',
  'withdraw',
];
