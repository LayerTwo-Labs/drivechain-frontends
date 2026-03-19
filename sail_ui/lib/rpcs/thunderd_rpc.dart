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
import 'package:sail_ui/gen/thunder/v1/thunder.connect.client.dart';
import 'package:sail_ui/gen/thunder/v1/thunder.pb.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.connect.client.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

/// API to the thunder server.
abstract class ThunderdRPC extends SidechainRPC {
  ThunderdRPC({
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

  // Wallet Manager RPCs

  Future<wmpb.GetWalletStatusResponse> getWalletStatus();
  Future<wmpb.GenerateWalletResponse> walletGenerateWallet(String name, {String? customMnemonic, String? passphrase});
  Future<void> walletUnlock(String password);
  Future<void> walletLock();
  Future<void> walletEncrypt(String password);
  Future<void> walletChangePassword(String oldPassword, String newPassword);
  Future<void> walletRemoveEncryption(String password);
  Future<wmpb.ListWalletsResponse> walletList();
  Future<void> walletSwitch(String walletId);
  Future<void> walletUpdateMetadata(String walletId, String name, String gradientJson);
  Future<void> walletDelete(String walletId);
  Future<void> walletDeleteAll();
}

class ThunderdLive extends ThunderdRPC {
  @override
  final log = GetIt.I.get<Logger>();

  late ThunderServiceClient _client;
  late WalletManagerServiceClient _walletClient;

  ThunderdLive()
    : super(
        binaryType: BinaryType.thunderd,
        restartOnFailure: false,
      ) {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:${binary.port}',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );
    _client = ThunderServiceClient(transport);
    _walletClient = WalletManagerServiceClient(transport);
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
    final response = await _client.getBalance(GetBalanceRequest());
    final confirmed = satoshiToBTC(response.availableSats.toInt());
    final unconfirmed = satoshiToBTC((response.totalSats - response.availableSats).toInt());
    return (confirmed, unconfirmed);
  }

  @override
  Future<int> getBlockCount() async {
    final response = await _client.getBlockCount(GetBlockCountRequest());
    return response.count.toInt();
  }

  @override
  Future<void> stopRPC() async {
    await _client.stop(StopRequest());
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final response = await _client.getBlockCount(GetBlockCountRequest());
    final blocks = response.count.toInt();

    // There's no endpoint to get headers for thunder, so we get the height
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
    return thunderRPCMethods;
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    try {
      final paramsJson = params != null ? jsonEncode(params) : '';
      final response = await _client.callRaw(CallRawRequest(method: method, paramsJson: paramsJson));
      if (response.resultJson.isEmpty) return null;
      return jsonDecode(response.resultJson);
    } catch (err) {
      log.t('rpc: $method threw exception: $err');
      rethrow;
    }
  }

  @override
  Future<String> getDepositAddress() async {
    final response = await _client.getNewAddress(GetNewAddressRequest());
    return formatDepositAddress(response.address, chain.slot);
  }

  @override
  Future<String> getSideAddress() async {
    final response = await _client.getNewAddress(GetNewAddressRequest());
    return response.address;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return [];
  }

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async {
    final response = await _client.withdraw(
      WithdrawRequest(
        address: address,
        amountSats: Int64(amountSats),
        sideFeeSats: Int64(sidechainFeeSats),
        mainFeeSats: Int64(mainchainFeeSats),
      ),
    );
    return response.txid;
  }

  @override
  Future<double> sideEstimateFee() async {
    return 0.00001;
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final response = await _client.transfer(
      TransferRequest(
        address: address,
        amountSats: Int64(btcToSatoshi(amount).toInt()),
        feeSats: Int64(btcToSatoshi(0.00001).toInt()),
      ),
    );
    return response.txid;
  }

  @override
  Future<double> getSidechainWealth() async {
    final response = await _client.getSidechainWealth(GetSidechainWealthRequest());
    return satoshiToBTC(response.sats.toInt());
  }

  @override
  Future<String> createDeposit(String address, double amount, double fee) async {
    final response = await _client.createDeposit(
      CreateDepositRequest(
        address: address,
        valueSats: Int64(btcToSatoshi(amount).toInt()),
        feeSats: Int64(btcToSatoshi(fee).toInt()),
      ),
    );
    return response.txid;
  }

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async {
    final response = await _client.getPendingWithdrawalBundle(GetPendingWithdrawalBundleRequest());
    if (response.bundleJson.isEmpty) return null;
    final json = jsonDecode(response.bundleJson) as Map<String, dynamic>;
    return PendingWithdrawalBundle.fromJson(json);
  }

  @override
  Future<void> connectPeer(String peerAddress) async {
    await _client.connectPeer(ConnectPeerRequest(address: peerAddress));
  }

  @override
  Future<List<Map<String, dynamic>>> listPeers() async {
    final response = await _client.listPeers(ListPeersRequest());
    if (response.peersJson.isEmpty) return [];
    final decoded = jsonDecode(response.peersJson) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    final response = await _client.mine(MineRequest(feeSats: Int64(feeSats)));
    final json = jsonDecode(response.bmmResultJson) as Map<String, dynamic>;
    return BmmResult.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) async {
    final response = await _client.getBlock(GetBlockRequest(hash: hash));
    if (response.blockJson.isEmpty) return null;
    return jsonDecode(response.blockJson) as Map<String, dynamic>?;
  }

  @override
  Future<String?> getBestMainchainBlockHash() async {
    final response = await _client.getBestMainchainBlockHash(GetBestMainchainBlockHashRequest());
    if (response.hash.isEmpty) return null;
    return response.hash;
  }

  @override
  Future<String?> getBestSidechainBlockHash() async {
    final response = await _client.getBestSidechainBlockHash(GetBestSidechainBlockHashRequest());
    if (response.hash.isEmpty) return null;
    return response.hash;
  }

  @override
  Future<String> getBMMInclusions(String blockHash) async {
    final response = await _client.getBmmInclusions(GetBmmInclusionsRequest(blockHash: blockHash));
    return response.inclusions;
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    final response = await _client.getWalletUtxos(GetWalletUtxosRequest());
    if (response.utxosJson.isEmpty) return [];
    final decoded = jsonDecode(response.utxosJson) as List<dynamic>;
    return SidechainUTXO.fromJsonList(decoded);
  }

  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async {
    final response = await _client.listUtxos(ListUtxosRequest());
    if (response.utxosJson.isEmpty) return [];
    final decoded = jsonDecode(response.utxosJson) as List<dynamic>;
    return SidechainUTXO.fromJsonList(decoded);
  }

  @override
  Future<void> removeFromMempool(String txid) async {
    await _client.removeFromMempool(RemoveFromMempoolRequest(txid: txid));
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async {
    final response = await _client.getLatestFailedWithdrawalBundleHeight(
      GetLatestFailedWithdrawalBundleHeightRequest(),
    );
    if (response.height == 0) return null;
    return response.height.toInt();
  }

  @override
  Future<String> generateMnemonic() async {
    final response = await _client.generateMnemonic(GenerateMnemonicRequest());
    return response.mnemonic;
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    await _client.setSeedFromMnemonic(SetSeedFromMnemonicRequest(mnemonic: mnemonic));
  }

  // Wallet Manager RPCs

  @override
  Future<wmpb.GetWalletStatusResponse> getWalletStatus() async {
    return await _walletClient.getWalletStatus(wmpb.GetWalletStatusRequest());
  }

  @override
  Future<wmpb.GenerateWalletResponse> walletGenerateWallet(
    String name, {
    String? customMnemonic,
    String? passphrase,
  }) async {
    return await _walletClient.generateWallet(
      wmpb.GenerateWalletRequest(
        name: name,
        customMnemonic: customMnemonic ?? '',
        passphrase: passphrase ?? '',
      ),
    );
  }

  @override
  Future<void> walletUnlock(String password) async {
    await _walletClient.unlockWallet(wmpb.UnlockWalletRequest(password: password));
  }

  @override
  Future<void> walletLock() async {
    await _walletClient.lockWallet(wmpb.LockWalletRequest());
  }

  @override
  Future<void> walletEncrypt(String password) async {
    await _walletClient.encryptWallet(wmpb.EncryptWalletRequest(password: password));
  }

  @override
  Future<void> walletChangePassword(String oldPassword, String newPassword) async {
    await _walletClient.changePassword(
      wmpb.ChangePasswordRequest(oldPassword: oldPassword, newPassword: newPassword),
    );
  }

  @override
  Future<void> walletRemoveEncryption(String password) async {
    await _walletClient.removeEncryption(wmpb.RemoveEncryptionRequest(password: password));
  }

  @override
  Future<wmpb.ListWalletsResponse> walletList() async {
    return await _walletClient.listWallets(wmpb.ListWalletsRequest());
  }

  @override
  Future<void> walletSwitch(String walletId) async {
    await _walletClient.switchWallet(wmpb.SwitchWalletRequest(walletId: walletId));
  }

  @override
  Future<void> walletUpdateMetadata(String walletId, String name, String gradientJson) async {
    await _walletClient.updateWalletMetadata(
      wmpb.UpdateWalletMetadataRequest(walletId: walletId, name: name, gradientJson: gradientJson),
    );
  }

  @override
  Future<void> walletDelete(String walletId) async {
    await _walletClient.deleteWallet(wmpb.DeleteWalletRequest(walletId: walletId));
  }

  @override
  Future<void> walletDeleteAll() async {
    await _walletClient.deleteAllWallets(wmpb.DeleteAllWalletsRequest());
  }
}
