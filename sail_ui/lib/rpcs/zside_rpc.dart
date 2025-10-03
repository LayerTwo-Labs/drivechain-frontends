import 'dart:convert';

import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/binaries/binary_provider.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

// List of all methods the zside-cli (thunder-orchard-cli) supports
final zsideRPCMethods = [
  'balance',
  'connect_peer',
  'create_deposit',
  'format_deposit_address',
  'generate_mnemonic',
  'get_best_mainchain_block_hash',
  'get_best_sidechain_block_hash',
  'get_block',
  'get_bmm_inclusions',
  'get_new_shielded_address',
  'get_new_transparent_address',
  'get_shielded_wallet_addresses',
  'get_transparent_wallet_addresses',
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
  'shield',
  'shielded_transfer',
  'sidechain_wealth',
  'stop',
  'transparent_transfer',
  'unshield',
  'withdraw',
  'help',
];

abstract class ZSideRPC extends SidechainRPC {
  ZSideRPC({
    required super.binaryType,
    required super.restartOnFailure,
  });

  Future<double> getSidechainWealth();
  Future<String> createDeposit(String address, double amount, double fee);
  Future<void> connectPeer(String peerAddress);
  Future<List<Map<String, dynamic>>> listPeers();
  Future<Map<String, dynamic>?> getBlock(String hash);
  Future<String?> getBestMainchainBlockHash();
  Future<String?> getBestSidechainBlockHash();
  Future<String> getBMMInclusions(String blockHash);
  Future<void> removeFromMempool(String txid);
  Future<int?> getLatestFailedWithdrawalBundleHeight();
  Future<String> generateMnemonic();
  Future<void> setSeedFromMnemonic(String mnemonic);
  Future<String> getNewShieldedAddress();
  Future<String> getNewTransparentAddress();
  Future<List<String>> getShieldedWalletAddresses();
  Future<List<String>> getTransparentWalletAddresses();
  Future<String> shield(UnshieldedUTXO utxo, double amount);
  Future<String> sendShielded(String dest, double valueSats, double feeSats);
  Future<String> sendTransparent(String dest, double valueSats, double feeSats);
  Future<String> deshield(ShieldedUTXO utxo, double amount);

  // Future rpcs needed to restore functionality 1-1
  Future<List<ShieldedUTXO>> listPrivateTransactions();
  Future<List<UnshieldedUTXO>> listTransparentTransactions();
  Future<List<ShieldedUTXO>> listShieldedUTXOs();
  Future<List<UnshieldedUTXO>> listUnshieldedUTXOs();

  // how many UTXOs each cast will be split into when deshielding them
  double numUTXOsPerCast = 4;
}

class ZSideLive extends ZSideRPC {
  @override
  final log = GetIt.I.get<Logger>();

  RPCClient _client() {
    final client = RPCClient(
      host: 'localhost',
      port: binary.port,
      username: 'N/A',
      password: 'N/A',
      useSSL: false,
    );

    client.dioClient = Dio();
    return client;
  }

  ZSideLive() : super(binaryType: BinaryType.zSide, restartOnFailure: false) {
    startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs() async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final thunderBinary = binaryProvider.binaries.where((b) => b.name == binary.name).first;

    return thunderBinary.extraBootArgs;
  }

  @override
  Future<int> ping() async {
    return await getBlockCount();
  }

  @override
  Future<int> getBlockCount() async {
    final response = await _client().call('getblockcount') as int;
    return response;
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<(double, double)> balance() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    log.w('balance: $response');

    // Extract shielded and transparent balances
    final totalShieldedSats = response['total_shielded_sats'] as int;
    final totalTransparentSats = response['total_transparent_sats'] as int;
    final availableShieldedSats = response['available_shielded_sats'] as int;
    final availableTransparentSats = response['available_transparent_sats'] as int;

    final totalSats = totalShieldedSats + totalTransparentSats;
    final availableSats = availableShieldedSats + availableTransparentSats;
    final unconfirmedSats = totalSats - availableSats;

    // Convert from sats to BTC
    final confirmed = satoshiToBTC(availableSats);
    final unconfirmed = satoshiToBTC(unconfirmedSats);

    return (confirmed, unconfirmed);
  }

  @override
  Future<void> stopRPC() async {
    await _client().call('stop');
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final blocks = await getBlockCount();

    // There's no endpoint to get headers for zside, so we get the height
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
    return zsideRPCMethods;
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
    final response = await _client().call('get_new_transparent_address') as String;
    return formatDepositAddress(response, chain.slot);
  }

  @override
  Future<String> getSideAddress() async {
    final response = await _client().call('get_new_transparent_address');
    return response as String;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return [];
  }

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async {
    final response = await _client().call('withdraw', [address, amountSats, sidechainFeeSats, mainchainFeeSats]);
    return response as String;
  }

  @override
  Future<double> sideEstimateFee() async {
    // ZSide has fixed fees for now
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

  @override
  Future<String?> getBestSidechainBlockHash() async {
    final response = await _client().call('get_best_sidechain_block_hash');
    return response as String?;
  }

  @override
  Future<String> getBMMInclusions(String blockHash) async {
    final response = await _client().call('get_bmm_inclusions', blockHash);
    return response as String;
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    final response = await _client().call('get_wallet_utxos') as List<dynamic>;
    return SidechainUTXO.fromJsonList(response);
  }

  @override
  Future<void> removeFromMempool(String txid) async {
    await _client().call('remove_from_mempool', txid);
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async {
    final response = await _client().call('latest_failed_withdrawal_bundle_height');
    return response as int?;
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
  Future<String> getNewShieldedAddress() async {
    final response = await _client().call('get_new_shielded_address');
    return response as String;
  }

  @override
  Future<String> getNewTransparentAddress() async {
    final response = await _client().call('get_new_transparent_address');
    return response as String;
  }

  @override
  Future<List<String>> getShieldedWalletAddresses() async {
    final response = await _client().call('get_shielded_wallet_addresses');
    return response as List<String>;
  }

  @override
  Future<List<String>> getTransparentWalletAddresses() async {
    final response = await _client().call('get_transparent_wallet_addresses');
    return response as List<String>;
  }

  @override
  Future<String> shield(UnshieldedUTXO utxo, double amount) async {
    final response = await _client().call('shield', {'value_sats': utxo.amount.toInt(), 'fee_sats': zsideFee.toInt()});
    return response as String;
  }

  @override
  Future<String> sendShielded(String dest, double valueSats, double feeSats) async {
    final response = await _client().call('shielded_transfer', {
      'dest': dest,
      'value_sats': valueSats.toInt(),
      'fee_sats': feeSats.toInt(),
    });
    return response as String;
  }

  @override
  Future<String> sendTransparent(String dest, double valueSats, double feeSats) async {
    final response = await _client().call('transparent_transfer', {
      'dest': dest,
      'value_sats': valueSats.toInt(),
      'fee_sats': feeSats.toInt(),
    });
    return response as String;
  }

  @override
  Future<String> deshield(ShieldedUTXO utxo, double amount) async {
    final response = await _client().call('unshield', {
      'value_sats': utxo.amount.toInt(),
      'fee_sats': zsideFee.toInt(),
    });
    return response as String;
  }

  @override
  Future<List<ShieldedUTXO>> listPrivateTransactions() async {
    // TODO: Implement when the binary supports it
    return [];
  }

  @override
  Future<List<UnshieldedUTXO>> listTransparentTransactions() async {
    // TODO: Implement when the binary supports it
    return [];
  }

  @override
  Future<List<ShieldedUTXO>> listShieldedUTXOs() async {
    // TODO: Implement when the binary supports it
    return [];
  }

  @override
  Future<List<UnshieldedUTXO>> listUnshieldedUTXOs() async {
    // TODO: Implement when the binary supports it
    return [];
  }
}

const zsideFee = 0.0001;

class ShieldedUTXO {
  final String txid;
  final String pool;
  final String type;
  final int outindex;
  final int confirmations;
  final bool spendable;
  final String address;
  final double amount;
  final double amountZat;
  final String memo;
  final bool change;
  final String raw;

  ShieldedUTXO({
    required this.txid,
    required this.pool,
    required this.type,
    required this.outindex,
    required this.confirmations,
    required this.spendable,
    required this.address,
    required this.amount,
    required this.amountZat,
    required this.memo,
    required this.change,
    required this.raw,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ShieldedUTXO && other.raw == raw;
  }

  @override
  int get hashCode => Object.hash(txid, raw);

  factory ShieldedUTXO.fromMap(Map<String, dynamic> map) {
    return ShieldedUTXO(
      txid: map['txid'] ?? '',
      pool: map['pool'] ?? '',
      type: map['type'] ?? '',
      outindex: map['outindex'] ?? 0,
      confirmations: map['confirmations'] ?? 0,
      spendable: map['spendable'] ?? false,
      address: map['address'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      amountZat: map['amountZat']?.toDouble() ?? 0.0,
      memo: map['memo'] ?? '',
      change: map['change'] ?? false,
      raw: map['raw'] ?? jsonEncode(map),
    );
  }

  static ShieldedUTXO fromJson(String json) => ShieldedUTXO.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'txid': txid,
      'pool': pool,
      'type': type,
      'outindex': outindex,
      'confirmations': confirmations,
      'spendable': spendable,
      'address': address,
      'amount': amount,
      'amountZat': amountZat,
      'memo': memo,
      'change': change,
      'raw': raw,
    };
  }
}

class UnshieldedUTXO {
  final String txid;
  final String address;
  final double amount;
  final int confirmations;
  final bool generated;
  final String raw;

  UnshieldedUTXO({
    required this.txid,
    required this.address,
    required this.amount,
    required this.confirmations,
    required this.generated,
    required this.raw,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UnshieldedUTXO && other.raw == raw;
  }

  @override
  int get hashCode => Object.hash(txid, raw);

  factory UnshieldedUTXO.fromMap(Map<String, dynamic> map) {
    return UnshieldedUTXO(
      txid: map['txid'] ?? '',
      address: map['address'] ?? '',
      amount: map['amount'] ?? 0.0,
      confirmations: map['confirmations'] ?? 0.0,
      generated: map['generated'] ?? 0.0,
      raw: jsonEncode(map),
    );
  }

  static UnshieldedUTXO fromJson(String json) => UnshieldedUTXO.fromMap(jsonDecode(json));
  String toJson() => jsonEncode(toMap());

  Map<String, dynamic> toMap() => {
    'txid': txid,
    'address': address,
    'amount': amount,
    'confirmations': confirmations,
    'generated': generated,
  };
}
