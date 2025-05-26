import 'dart:ui';

import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/cusf/mainchain/v1/validator.connect.client.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/sail_ui.dart';

class MockMainchainRPC extends MainchainRPC {
  MockMainchainRPC()
      : super(
          conf: NodeConnectionSettings.empty(),
          binary: ParentChain(),
          restartOnFailure: false,
        );

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;
  bool _inIBD = true;

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;
  @override
  bool get inIBD => _inIBD;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void setIBD(bool value) {
    _inIBD = value;
    notifyListeners();
  }

  @override
  Future<void> waitForIBD() async {}

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    return BlockchainInfo(
      chain: 'test',
      blocks: 100,
      headers: 200,
      bestBlockHash: 'mock_hash',
      difficulty: 1.0,
      time: 0,
      medianTime: 0,
      verificationProgress: 0.5,
      initialBlockDownload: _inIBD,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<void> waitForHeaderSync() async {
    return;
  }

  @override
  Future<dynamic> callRAW(String method, [List? params]) {
    return Future.value(null);
  }

  @override
  List<String> getMethods() {
    return [];
  }

  @override
  Future<List<PeerInfo>> getPeerInfo() {
    return Future.value([]);
  }

  @override
  Future<String> getDataDir() {
    throw UnimplementedError();
  }

  @override
  Future<MempoolInfo> getMempoolInfo() {
    throw UnimplementedError();
  }

  @override
  Future<MiningInfo> getMiningInfo() {
    throw UnimplementedError();
  }

  @override
  Future<NetworkInfo> getNetworkInfo() {
    throw UnimplementedError();
  }

  @override
  Future<TxOutsetInfo> getTxOutsetInfo() {
    throw UnimplementedError();
  }

  @override
  Future<void> waitForSync() async {
    return;
  }
}

class MockEnforcerRPC extends EnforcerRPC {
  MockEnforcerRPC()
      : super(
          conf: NodeConnectionSettings.empty(),
          binary: Enforcer(),
          restartOnFailure: true,
        );

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  ValidatorServiceClient get validator => throw UnimplementedError();

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> callRAW(String url, [String body = '{}']) {
    return Future.value(null);
  }

  @override
  List<String> getMethods() {
    return [];
  }
}

class MockBitwindowRPC extends BitwindowRPC {
  MockBitwindowRPC()
      : super(
          conf: NodeConnectionSettings.empty(),
          binary: BitWindow(),
          restartOnFailure: true,
        );

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;

  @override
  WalletAPI get wallet => throw UnimplementedError();
  @override
  BitwindowAPI get bitwindowd => throw UnimplementedError();
  @override
  BitcoindAPI get bitcoind => throw UnimplementedError();
  @override
  DrivechainAPI get drivechain => throw UnimplementedError();
  @override
  MiscAPI get misc => throw UnimplementedError();
  @override
  HealthAPI get health => throw UnimplementedError();

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> callRAW(String url, [String body = '{}']) {
    return Future.value(null);
  }

  @override
  List<String> getMethods() {
    return [];
  }
}

class MockThunderRPC extends ThunderRPC {
  MockThunderRPC()
      : super(
          conf: NodeConnectionSettings.empty(),
          binary: Thunder(),
          restartOnFailure: true,
          chain: Thunder(),
        );

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  List<String> getMethods() {
    return thunderRPCMethods;
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    return;
  }

  @override
  Future<String> getDepositAddress() {
    return Future.value('tb1qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
  }

  @override
  Future<String> getSideAddress() {
    return Future.value('tb1qyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy');
  }

  @override
  Future<List<CoreTransaction>> listTransactions() {
    return Future.value([]);
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) {
    return Future.value('txid_mainchain_send_1234');
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(0.00001);
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) {
    return Future.value('txid_sidechain_send_5678');
  }

  @override
  Future<void> connectPeer(String peerAddress) async {
    return;
  }

  @override
  Future<String> createDeposit(String address, double amount, double fee) {
    return Future.value('txid_create_deposit_1234');
  }

  @override
  Future<String> generateMnemonic() {
    return Future.value('mnemonic_generate_1234');
  }

  @override
  Future<String> getBMMInclusions(String blockHash) {
    return Future.value('txid_get_bmm_inclusions_1234');
  }

  @override
  Future<String?> getBestMainchainBlockHash() {
    return Future.value('blockhash_get_best_mainchain_1234');
  }

  @override
  Future<String?> getBestSidechainBlockHash() {
    return Future.value('blockhash_get_best_sidechain_1234');
  }

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) {
    return Future.value({'block': 'block_get_1234'});
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() {
    return Future.value(1234);
  }

  @override
  Future<Map<String, dynamic>?> getPendingWithdrawalBundle() {
    return Future.value({'pending_withdrawal_bundle': 'pending_withdrawal_bundle_1234'});
  }

  @override
  Future<double> getSidechainWealth() {
    return Future.value(1234.56);
  }

  @override
  Future<List<Map<String, dynamic>>> listPeers() {
    return Future.value([]);
  }

  @override
  Future<List<ThunderUTXO>> listUTXOs() {
    return Future.value([]);
  }

  @override
  Future<void> mine([int? coinbaseValueSats]) async {
    return;
  }

  @override
  Future<void> removeFromMempool(String txid) async {
    return;
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    return;
  }
}

class MockBitnamesRPC extends BitnamesRPC {
  MockBitnamesRPC()
      : super(
          conf: NodeConnectionSettings.empty(),
          binary: Bitnames(),
          restartOnFailure: true,
          chain: Bitnames(),
        );

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  List<String> getMethods() {
    return [];
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    return;
  }

  @override
  Future<String> getDepositAddress() {
    return Future.value('tb1qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
  }

  @override
  Future<String> getSideAddress() {
    return Future.value('tb1qyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy');
  }

  @override
  Future<List<CoreTransaction>> listTransactions() {
    return Future.value([]);
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) {
    return Future.value('txid_mainchain_send_1234');
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(0.00001);
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) {
    return Future.value('txid_sidechain_send_5678');
  }

  @override
  Future<void> connectPeer(String address) async {
    return Future.value();
  }

  @override
  Future<BalanceResponse> getBalance() {
    return Future.value(BalanceResponse(totalSats: 0, availableSats: 0));
  }

  @override
  Future<BitNameData?> getBitNameData(String name) {
    return Future.value(null);
  }

  @override
  Future<List<String>> listBitNames() {
    return Future.value([]);
  }

  @override
  Future<List<BitnamesPeerInfo>> listPeers() {
    return Future.value([]);
  }

  @override
  Future<List<BitnamesUTXO>> listUtxos() {
    return Future.value([]);
  }

  @override
  Future<String> registerBitName(String plainName, BitNameData? data) {
    return Future.value('mock_txid_register_bitname');
  }

  @override
  Future<String> reserveBitName(String name) {
    return Future.value('mock_txid_reserve_bitname');
  }
}

class MockBlockInfoProvider implements BlockInfoProvider {
  MockBlockInfoProvider() : super();

  @override
  void addListener(VoidCallback listener) {
    return;
  }

  @override
  void dispose() {
    return;
  }

  @override
  Future<void> fetch() async {
    return;
  }

  @override
  bool get hasListeners => false;

  @override
  Logger get log => Logger();

  @override
  void notifyListeners() {
    return;
  }

  @override
  void removeListener(VoidCallback listener) {
    return;
  }

  @override
  String? additionalError;

  @override
  SyncInfo? additionalSyncInfo;

  @override
  String? enforcerError;

  @override
  SyncInfo? enforcerSyncInfo;

  @override
  String? mainchainError;

  @override
  SyncInfo? mainchainSyncInfo;

  @override
  BlockSyncConnection? get additionalConnection => throw UnimplementedError();

  @override
  BlockSyncConnection get enforcer => throw UnimplementedError();

  @override
  EnforcerRPC get enforcerRPC => throw UnimplementedError();

  @override
  BlockSyncConnection get mainchain => throw UnimplementedError();

  @override
  MainchainRPC get mainchainRPC => throw UnimplementedError();
}

class MockBitcoindAPI implements BitcoindAPI {
  @override
  Future<List<Peer>> listPeers() {
    return Future.value([]);
  }

  @override
  Future<List<RecentTransaction>> listRecentTransactions() {
    return Future.value([]);
  }

  @override
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50}) {
    return Future.value((<Block>[], false));
  }

  @override
  Future<GetBlockchainInfoResponse> getBlockchainInfo() {
    return Future.value(GetBlockchainInfoResponse());
  }

  @override
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget) {
    return Future.value(EstimateSmartFeeResponse());
  }

  @override
  Future<GetRawTransactionResponse> getRawTransaction(String txid) {
    return Future.value(GetRawTransactionResponse());
  }

  @override
  Future<Block> getBlock({String? hash, int? height}) async {
    return Block();
  }

  @override
  Future<AddMultisigAddressResponse> addMultisigAddress(int nRequired, List<String> keys, String label, String wallet) {
    return Future.value(AddMultisigAddressResponse());
  }

  @override
  Future<BackupWalletResponse> backupWallet(String destination, String wallet) {
    return Future.value(BackupWalletResponse());
  }

  @override
  Future<CreateMultisigResponse> createMultisig(int nRequired, List<String> keys) {
    return Future.value(CreateMultisigResponse());
  }

  @override
  Future<CreateWalletResponse> createWallet(
    String name,
    String passphrase,
    bool avoidReuse,
    bool disablePrivateKeys,
    bool blank,
  ) {
    return Future.value(CreateWalletResponse());
  }

  @override
  Future<DumpPrivKeyResponse> dumpPrivKey(String address, String wallet) {
    return Future.value(DumpPrivKeyResponse());
  }

  @override
  Future<DumpWalletResponse> dumpWallet(String filename, String wallet) {
    return Future.value(DumpWalletResponse());
  }

  @override
  Future<GetAccountResponse> getAccount(String address, String wallet) {
    return Future.value(GetAccountResponse());
  }

  @override
  Future<GetAddressesByAccountResponse> getAddressesByAccount(String account, String wallet) {
    return Future.value(GetAddressesByAccountResponse());
  }

  @override
  Future<ImportAddressResponse> importAddress(String address, String label, bool rescan, String wallet) {
    return Future.value(ImportAddressResponse());
  }

  @override
  Future<ImportPrivKeyResponse> importPrivKey(String privateKey, String label, bool rescan, String wallet) {
    return Future.value(ImportPrivKeyResponse());
  }

  @override
  Future<ImportPubKeyResponse> importPubKey(String pubkey, bool rescan, String wallet) {
    return Future.value(ImportPubKeyResponse());
  }

  @override
  Future<ImportWalletResponse> importWallet(String filename, String wallet) {
    return Future.value(ImportWalletResponse());
  }

  @override
  Future<KeyPoolRefillResponse> keyPoolRefill(int newSize, String wallet) {
    return Future.value(KeyPoolRefillResponse());
  }

  @override
  Future<ListAccountsResponse> listAccounts(int minConf, String wallet) {
    return Future.value(ListAccountsResponse());
  }

  @override
  Future<SetAccountResponse> setAccount(String address, String account, String wallet) {
    return Future.value(SetAccountResponse());
  }

  @override
  Future<UnloadWalletResponse> unloadWallet(String walletName, String wallet) {
    return Future.value(UnloadWalletResponse());
  }

  @override
  Future<AnalyzePsbtResponse> analyzePsbt(AnalyzePsbtRequest request) {
    return Future.value(AnalyzePsbtResponse());
  }

  @override
  Future<CombinePsbtResponse> combinePsbt(CombinePsbtRequest request) {
    return Future.value(CombinePsbtResponse());
  }

  @override
  Future<CreatePsbtResponse> createPsbt(CreatePsbtRequest request) {
    return Future.value(CreatePsbtResponse());
  }

  @override
  Future<DecodePsbtResponse> decodePsbt(DecodePsbtRequest request) {
    return Future.value(DecodePsbtResponse());
  }

  @override
  Future<JoinPsbtsResponse> joinPsbts(JoinPsbtsRequest request) {
    return Future.value(JoinPsbtsResponse());
  }

  @override
  Future<TestMempoolAcceptResponse> testMempoolAccept(TestMempoolAcceptRequest request) {
    return Future.value(TestMempoolAcceptResponse());
  }

  @override
  Future<UtxoUpdatePsbtResponse> utxoUpdatePsbt(UtxoUpdatePsbtRequest request) {
    return Future.value(UtxoUpdatePsbtResponse());
  }
}
