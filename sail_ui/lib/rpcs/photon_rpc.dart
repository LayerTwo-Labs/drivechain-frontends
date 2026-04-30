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
import 'package:sail_ui/gen/photon/v1/photon.connect.client.dart';
import 'package:sail_ui/gen/photon/v1/photon.pb.dart' as pb;
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// API to the photon server.
abstract class PhotonRPC extends SidechainRPC {
  PhotonRPC({required super.binaryType});

  /// Get total sidechain wealth in BTC
  Future<double> getSidechainWealth();

  /// Create a deposit transaction
  Future<String> createDeposit(String address, double amount, double fee);

  /// Connect to a peer
  Future<void> connectPeer(String peerAddress);

  /// Forget a peer
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
}

class PhotonLive extends PhotonRPC {
  @override
  final log = GetIt.I.get<Logger>();

  late PhotonServiceClient _client;

  PhotonLive() : super(binaryType: BinaryType.photon) {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30400',
      codec: const ProtoCodec(),
      httpClient: unaryHttpClient(),
    );
    _client = PhotonServiceClient(transport);
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
  List<String> getMethods() => photonRPCMethods;

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
}

final photonRPCMethods = [
  'balance',
  'connect_peer',
  'create_deposit',
  'forget_peer',
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
