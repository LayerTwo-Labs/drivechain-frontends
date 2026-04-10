import 'dart:convert';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/zside/v1/zside.connect.client.dart';
import 'package:sail_ui/gen/zside/v1/zside.pb.dart' as pb;
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
  ZSideRPC({required super.binaryType, required super.restartOnFailure});

  Future<double> getSidechainWealth();
  Future<String> createDeposit(String address, double amount, double fee);
  Future<void> connectPeer(String peerAddress);
  Future<List<Map<String, dynamic>>> listPeers();
  Future<Map<String, dynamic>?> getBlock(String hash);
  Future<String?> getBestMainchainBlockHash();
  Future<String?> getBestSidechainBlockHash();
  Future<String> getBMMInclusions(String blockHash);
  Future<void> removeFromMempool(String txid);
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

  /// Get detailed balance breakdown by pool type (transparent vs shielded)
  Future<ZSideBalanceBreakdown> getBalanceBreakdown();

  // how many UTXOs each cast will be split into when deshielding them
  double numUTXOsPerCast = 4;
}

class ZSideLive extends ZSideRPC {
  @override
  final log = GetIt.I.get<Logger>();

  late ZSideServiceClient _client;

  ZSideLive() : super(binaryType: BinaryType.zSide, restartOnFailure: false) {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30400',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );
    _client = ZSideServiceClient(transport);
  }

  @override
  Future<List<String>> binaryArgs() async => [];

  @override
  Future<int> ping() async => await getBlockCount();

  @override
  Future<int> getBlockCount() async {
    final resp = await _client.getBlockCount(pb.GetBlockCountRequest());
    return resp.count.toInt();
  }

  @override
  List<String> startupErrors() => [];

  @override
  Future<(double, double)> balance() async {
    final resp = await _client.getBalance(pb.GetBalanceRequest());
    final totalSats = resp.totalShieldedSats.toInt() + resp.totalTransparentSats.toInt();
    final availableSats = resp.availableShieldedSats.toInt() + resp.availableTransparentSats.toInt();
    final unconfirmedSats = totalSats - availableSats;

    final confirmed = satoshiToBTC(availableSats);
    final unconfirmed = satoshiToBTC(unconfirmedSats);
    return (confirmed, unconfirmed);
  }

  @override
  Future<ZSideBalanceBreakdown> getBalanceBreakdown() async {
    final resp = await _client.getBalance(pb.GetBalanceRequest());
    return ZSideBalanceBreakdown(
      availableShieldedSats: resp.availableShieldedSats.toInt(),
      availableTransparentSats: resp.availableTransparentSats.toInt(),
      totalShieldedSats: resp.totalShieldedSats.toInt(),
      totalTransparentSats: resp.totalTransparentSats.toInt(),
    );
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
  List<String> getMethods() => zsideRPCMethods;

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    final paramsJson = params != null ? jsonEncode(params) : '';
    final resp = await _client.callRaw(pb.CallRawRequest(method: method, paramsJson: paramsJson));
    if (resp.resultJson.isEmpty) return null;
    return jsonDecode(resp.resultJson);
  }

  @override
  Future<String> getDepositAddress() async {
    final resp = await _client.getNewTransparentAddress(pb.GetNewTransparentAddressRequest());
    return formatDepositAddress(resp.address, chain.slot);
  }

  @override
  Future<String> getSideAddress() async {
    final resp = await _client.getNewTransparentAddress(pb.GetNewTransparentAddressRequest());
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
  Future<String> getNewShieldedAddress() async {
    final resp = await _client.getNewShieldedAddress(pb.GetNewShieldedAddressRequest());
    return resp.address;
  }

  @override
  Future<String> getNewTransparentAddress() async {
    final resp = await _client.getNewTransparentAddress(pb.GetNewTransparentAddressRequest());
    return resp.address;
  }

  @override
  Future<List<String>> getShieldedWalletAddresses() async {
    final resp = await _client.getShieldedWalletAddresses(pb.GetShieldedWalletAddressesRequest());
    return resp.addresses.toList();
  }

  @override
  Future<List<String>> getTransparentWalletAddresses() async {
    final resp = await _client.getTransparentWalletAddresses(pb.GetTransparentWalletAddressesRequest());
    return resp.addresses.toList();
  }

  @override
  Future<String> shield(UnshieldedUTXO utxo, double amount) async {
    final resp = await _client.shield(
      pb.ShieldRequest(
        amountSats: Int64(utxo.amount.toInt()),
        feeSats: Int64(zsideFee.toInt()),
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> sendShielded(String dest, double valueSats, double feeSats) async {
    final resp = await _client.shieldedTransfer(
      pb.ShieldedTransferRequest(
        address: dest,
        amountSats: Int64(valueSats.toInt()),
        feeSats: Int64(feeSats.toInt()),
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> sendTransparent(String dest, double valueSats, double feeSats) async {
    final resp = await _client.transparentTransfer(
      pb.TransparentTransferRequest(
        address: dest,
        amountSats: Int64(valueSats.toInt()),
        feeSats: Int64(feeSats.toInt()),
      ),
    );
    return resp.txid;
  }

  @override
  Future<String> deshield(ShieldedUTXO utxo, double amount) async {
    final resp = await _client.unshield(
      pb.UnshieldRequest(
        amountSats: Int64(utxo.amount.toInt()),
        feeSats: Int64(zsideFee.toInt()),
      ),
    );
    return resp.txid;
  }

  @override
  Future<List<ShieldedUTXO>> listPrivateTransactions() async => [];

  @override
  Future<List<UnshieldedUTXO>> listTransparentTransactions() async => [];

  @override
  Future<List<ShieldedUTXO>> listShieldedUTXOs() async => [];

  @override
  Future<List<UnshieldedUTXO>> listUnshieldedUTXOs() async => [];
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

/// Balance breakdown by pool type (transparent vs shielded)
class ZSideBalanceBreakdown {
  final int availableShieldedSats;
  final int availableTransparentSats;
  final int totalShieldedSats;
  final int totalTransparentSats;

  ZSideBalanceBreakdown({
    required this.availableShieldedSats,
    required this.availableTransparentSats,
    required this.totalShieldedSats,
    required this.totalTransparentSats,
  });

  /// Total available balance (both pools) in satoshis
  int get totalAvailableSats => availableShieldedSats + availableTransparentSats;

  /// Total balance (both pools) in satoshis
  int get totalSats => totalShieldedSats + totalTransparentSats;

  /// Pending shielded balance in satoshis
  int get pendingShieldedSats => totalShieldedSats - availableShieldedSats;

  /// Pending transparent balance in satoshis
  int get pendingTransparentSats => totalTransparentSats - availableTransparentSats;

  /// Total pending balance in satoshis
  int get totalPendingSats => pendingShieldedSats + pendingTransparentSats;

  /// Available shielded balance in BTC
  double get availableShielded => satoshiToBTC(availableShieldedSats);

  /// Available transparent balance in BTC
  double get availableTransparent => satoshiToBTC(availableTransparentSats);

  /// Total shielded balance in BTC
  double get totalShielded => satoshiToBTC(totalShieldedSats);

  /// Total transparent balance in BTC
  double get totalTransparent => satoshiToBTC(totalTransparentSats);

  /// Pending shielded balance in BTC
  double get pendingShielded => satoshiToBTC(pendingShieldedSats);

  /// Pending transparent balance in BTC
  double get pendingTransparent => satoshiToBTC(pendingTransparentSats);
}
