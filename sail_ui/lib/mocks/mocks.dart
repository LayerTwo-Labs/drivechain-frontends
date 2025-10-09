import 'dart:ui';

import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';

class MockMainchainRPC extends MainchainRPC {
  MockMainchainRPC()
    : super(
        conf: CoreConnectionSettings.empty(Network.NETWORK_SIGNET),
        binaryType: BinaryType.bitcoinCore,
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
  Future<List<String>> binaryArgs() {
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

  @override
  Future<void> submitBlock(String blockData) async {
    return;
  }
}

class MockEnforcerRPC extends EnforcerRPC {
  MockEnforcerRPC()
    : super(
        binaryType: BinaryType.enforcer,
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
  Future<List<String>> binaryArgs() {
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

  @override
  Future<Map<String, dynamic>> getBlockTemplate() {
    return Future.value({
      'version': 4,
      'height': 100,
      'transactions': [],
      'coinbasevalue': 5000000000,
    });
  }
}

class MockBitwindowRPC extends BitwindowRPC {
  MockBitwindowRPC()
    : super(
        binaryType: BinaryType.bitWindow,
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
  Future<List<String>> binaryArgs() {
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
  MockThunderRPC() : super(binaryType: BinaryType.thunder, restartOnFailure: true);

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
  Future<List<String>> binaryArgs() {
    return Future.value([]);
  }

  @override
  Future<int> ping() async {
    return await getBlockCount();
  }

  @override
  Future<int> getBlockCount() {
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
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) {
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
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() {
    return Future.value(PendingWithdrawalBundle.empty());
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
  Future<List<SidechainUTXO>> listUTXOs() {
    return Future.value([]);
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    return BmmResult.empty();
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
        binaryType: BinaryType.bitnames,
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
  Future<List<String>> binaryArgs() {
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
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) {
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
  Future<List<BitnameEntry>> listBitNames() {
    return Future.value([]);
  }

  @override
  Future<List<BitnamesPeerInfo>> listPeers() {
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

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    return [];
  }

  @override
  Future<String> generateMnemonic() {
    return Future.value('mock_mnemonic_generate_1234');
  }

  @override
  Future<String> getBMMInclusions(String blockHash) {
    return Future.value('mock_bmm_inclusions_1234');
  }

  @override
  Future<String?> getBestMainchainBlockHash() {
    return Future.value('mock_best_mainchain_block_hash_1234');
  }

  @override
  Future<String?> getBestSidechainBlockHash() {
    return Future.value('mock_best_sidechain_block_hash_1234');
  }

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) {
    return Future.value({'block': 'mock_block_1234'});
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() {
    return Future.value(1234);
  }

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() {
    return Future.value(PendingWithdrawalBundle.empty());
  }

  @override
  Future<int> getSidechainWealth() {
    return Future.value(1234);
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) {
    return Future.value();
  }

  @override
  Future<String> createDeposit({required String address, required int feeSats, required int valueSats}) async {
    return Future.value('mock_txid_create_deposit_1234');
  }

  @override
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey}) async {
    return Future.value('mock_decrypted_msg_1234');
  }

  @override
  Future<String> encryptMsg({required String msg, required String encryptionPubkey}) async {
    return Future.value('mock_encrypted_msg_1234');
  }

  @override
  Future<int> getBlockCount() async {
    return Future.value(1234);
  }

  @override
  Future<String> getNewAddress() async {
    return Future.value('mock_new_address_1234');
  }

  @override
  Future<String> getNewEncryptionKey() async {
    return Future.value('mock_new_encryption_key_1234');
  }

  @override
  Future<String> getNewVerifyingKey() async {
    return Future.value('mock_new_verifying_key_1234');
  }

  @override
  Future<Map<String, dynamic>> getPaymail() async {
    return Future.value({'paymail': 'mock_paymail_1234'});
  }

  @override
  Future<List<String>> getWalletAddresses() async {
    return Future.value(['mock_wallet_address_1234']);
  }

  @override
  Future<List> getWalletUTXOs() async {
    return Future.value([
      SidechainUTXO(
        valueSats: 1000,
        address: 'mock_address_1234',
        outpoint: 'mock_outpoint_1234',
        type: OutpointType.regular,
      ),
    ]);
  }

  @override
  Future<List> myUTXOs() async {
    return Future.value([
      SidechainUTXO(
        valueSats: 1000,
        address: 'mock_address_1234',
        outpoint: 'mock_outpoint_1234',
        type: OutpointType.regular,
      ),
    ]);
  }

  @override
  Future<Map<String, dynamic>> openapiSchema() async {
    return Future.value({'openapi_schema': 'mock_openapi_schema_1234'});
  }

  @override
  Future<String> resolveCommit(String bitname) async {
    return Future.value('mock_resolve_commit_1234');
  }

  @override
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey}) async {
    return Future.value('mock_signed_msg_1234');
  }

  @override
  Future<Map<String, String>> signArbitraryMsgAsAddr({required String msg, required String address}) async {
    return Future.value({'signed_msg': 'mock_signed_msg_1234'});
  }

  @override
  Future<String> transfer({required String dest, required int value, required int fee, String? memo}) async {
    return Future.value('mock_txid_transfer_1234');
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    return BmmResult.empty();
  }
}

class MockSyncProvider implements SyncProvider {
  MockSyncProvider() : super();

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
  SyncConnection? get additionalConnection => throw UnimplementedError();

  @override
  SyncConnection get enforcer => throw UnimplementedError();

  @override
  EnforcerRPC get enforcerRPC => throw UnimplementedError();

  @override
  SyncConnection get mainchain => throw UnimplementedError();

  @override
  MainchainRPC get mainchainRPC => throw UnimplementedError();

  @override
  BinaryProvider get binaryProvider => throw UnimplementedError();

  @override
  void listenDownloads() {
    return;
  }

  @override
  void clearState() {}
}

class MockBitcoindAPI implements BitcoindAPI {
  @override
  Future<List<Peer>> listPeers() {
    return Future.value([]);
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
  Future<GetBlockResponse> getBlock({String? hash, int? height}) async {
    return GetBlockResponse();
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
