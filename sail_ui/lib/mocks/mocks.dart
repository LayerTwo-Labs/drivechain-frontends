import 'dart:io';
import 'dart:ui';

import 'package:logger/logger.dart';
import 'package:sail_ui/gen/cusf/mainchain/v1/wallet.connect.client.dart';
import 'package:sail_ui/gen/notification/v1/notification.pb.dart';
import 'package:sail_ui/sail_ui.dart';

class MockBitcoindConnection extends BitcoindConnection {
  MockBitcoindConnection() : super();

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
}

class MockEnforcerRPC extends EnforcerRPC {
  MockEnforcerRPC() : super(binaryType: BinaryType.BINARY_TYPE_ENFORCER);

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
  ValidatorServiceClient get validator => throw UnimplementedError();

  @override
  WalletServiceClient get wallet => throw UnimplementedError();

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

  @override
  Future<List<String>> getAddresses() {
    return Future.value([]);
  }
}

class MockBitwindowRPC extends BitwindowRPC {
  MockBitwindowRPC() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;

  @override
  WalletAPI get wallet => throw UnimplementedError();
  @override
  BitwindowAPI get bitwindowd => throw UnimplementedError();
  @override
  DrivechainAPI get drivechain => throw UnimplementedError();
  @override
  MiscAPI get misc => throw UnimplementedError();
  @override
  M4API get m4 => throw UnimplementedError();
  @override
  NotificationAPI get notifications => throw UnimplementedError();
  @override
  BitDriveAPI get bitdrive => throw UnimplementedError();
  @override
  MultisigAPI get multisig => throw UnimplementedError();
  @override
  UtilsAPI get utils => throw UnimplementedError();
  @override
  Stream<WatchResponse> get notificationStream =>
      Stream.periodic(const Duration(seconds: 1)).map((_) => WatchResponse());

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
  MockThunderRPC() : super(binaryType: BinaryType.BINARY_TYPE_THUNDER);

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
  Future<int> getBlockCount() {
    return Future.value(0);
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
  Future<String> withdraw(
    String address,
    int amountSats,
    int sidechainFeeSats,
    int mainchainFeeSats,
  ) {
    return Future.value('txid_mainchain_send_1234');
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(0.00001);
  }

  @override
  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  ) {
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
  Future<List<SidechainUTXO>> listAllUTXOs() {
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

class MockTruthcoinRPC extends TruthcoinRPC {
  MockTruthcoinRPC() : super(binaryType: BinaryType.BINARY_TYPE_TRUTHCOIN);

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
  Future<int> getBlockCount() {
    return Future.value(0);
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  List<String> getMethods() {
    return truthcoinRPCMethods;
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
  Future<String> withdraw(
    String address,
    int amountSats,
    int sidechainFeeSats,
    int mainchainFeeSats,
  ) {
    return Future.value('txid_mainchain_send_1234');
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(0.00001);
  }

  @override
  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  ) {
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
  Future<List<SidechainUTXO>> listAllUTXOs() {
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

  // Prediction Markets
  @override
  Future<Map<String, dynamic>> calculateInitialLiquidity({
    required double beta,
    int? numOutcomes,
    String? dimensions,
  }) {
    return Future.value({'liquidity': 0});
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
  }) {
    return Future.value('market_create_1234');
  }

  @override
  Future<List<Map<String, dynamic>>> marketList() {
    return Future.value([]);
  }

  @override
  Future<Map<String, dynamic>?> marketGet(String marketId) {
    return Future.value(null);
  }

  @override
  Future<Map<String, dynamic>> marketBuy({
    required String marketId,
    required int outcomeIndex,
    required double sharesAmount,
    bool? dryRun,
    int? feeSats,
    int? maxCost,
  }) {
    return Future.value({'txid': 'market_buy_1234'});
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
  }) {
    return Future.value({'txid': 'market_sell_1234'});
  }

  @override
  Future<Map<String, dynamic>> marketPositions({
    String? address,
    String? marketId,
  }) {
    return Future.value({});
  }

  // Slots
  @override
  Future<Map<String, dynamic>> slotStatus() {
    return Future.value({});
  }

  @override
  Future<List<Map<String, dynamic>>> slotList({int? period, String? status}) {
    return Future.value([]);
  }

  @override
  Future<Map<String, dynamic>?> slotGet(String slotId) {
    return Future.value(null);
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
  }) {
    return Future.value('slot_claim_1234');
  }

  @override
  Future<String> slotClaimCategory({
    required List<Map<String, dynamic>> slots,
    required bool isStandard,
    required int feeSats,
  }) {
    return Future.value('slot_claim_category_1234');
  }

  // Voting
  @override
  Future<String> voteRegister({required int feeSats, int? reputationBondSats}) {
    return Future.value('vote_register_1234');
  }

  @override
  Future<Map<String, dynamic>?> voteVoter(String address) {
    return Future.value(null);
  }

  @override
  Future<List<Map<String, dynamic>>> voteVoters() {
    return Future.value([]);
  }

  @override
  Future<String> voteSubmit({
    required List<Map<String, dynamic>> votes,
    required int feeSats,
  }) {
    return Future.value('vote_submit_1234');
  }

  @override
  Future<List<Map<String, dynamic>>> voteList({
    String? voter,
    String? decisionId,
    int? periodId,
  }) {
    return Future.value([]);
  }

  @override
  Future<Map<String, dynamic>?> votePeriod({int? periodId}) {
    return Future.value(null);
  }

  // Votecoin
  @override
  Future<String> votecoinTransfer({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  }) {
    return Future.value('votecoin_transfer_1234');
  }

  @override
  Future<int> votecoinBalance(String address) {
    return Future.value(0);
  }

  @override
  Future<String> transferVotecoin({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  }) {
    return Future.value('transfer_votecoin_1234');
  }

  // Crypto utilities
  @override
  Future<String> getNewEncryptionKey() {
    return Future.value('encryption_key_1234');
  }

  @override
  Future<String> getNewVerifyingKey() {
    return Future.value('verifying_key_1234');
  }

  @override
  Future<String> encryptMsg({
    required String msg,
    required String encryptionPubkey,
  }) {
    return Future.value('encrypted_msg_1234');
  }

  @override
  Future<String> decryptMsg({
    required String ciphertext,
    required String encryptionPubkey,
  }) {
    return Future.value('decrypted_msg_1234');
  }

  @override
  Future<String> signArbitraryMsg({
    required String msg,
    required String verifyingKey,
  }) {
    return Future.value('signature_1234');
  }

  @override
  Future<Map<String, dynamic>> signArbitraryMsgAsAddr({
    required String address,
    required String msg,
  }) {
    return Future.value({'verifying_key': 'key', 'signature': 'sig'});
  }

  @override
  Future<bool> verifySignature({
    required String msg,
    required String signature,
    required String verifyingKey,
    required String dst,
  }) {
    return Future.value(true);
  }

  @override
  Future<Map<String, dynamic>?> getTransaction(String txid) {
    return Future.value(null);
  }

  @override
  Future<Map<String, dynamic>?> getTransactionInfo(String txid) {
    return Future.value(null);
  }

  @override
  Future<List<String>> getWalletAddresses() {
    return Future.value([]);
  }

  @override
  Future<List<SidechainUTXO>> myUnconfirmedUtxos() {
    return Future.value([]);
  }

  @override
  Future<List<SidechainUTXO>> myUtxos() {
    return Future.value([]);
  }

  @override
  Future<void> refreshWallet() async {
    return;
  }
}

class MockPhotonRPC extends PhotonRPC {
  MockPhotonRPC() : super(binaryType: BinaryType.BINARY_TYPE_PHOTON);

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
  Future<int> getBlockCount() {
    return Future.value(0);
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  List<String> getMethods() {
    return photonRPCMethods;
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
  Future<String> withdraw(
    String address,
    int amountSats,
    int sidechainFeeSats,
    int mainchainFeeSats,
  ) {
    return Future.value('txid_mainchain_send_1234');
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(0.00001);
  }

  @override
  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  ) {
    return Future.value('txid_sidechain_send_5678');
  }

  @override
  Future<void> connectPeer(String peerAddress) async {
    return;
  }

  @override
  Future<void> forgetPeer(String peerAddress) async {
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
  Future<List<SidechainUTXO>> listAllUTXOs() {
    return Future.value([]);
  }

  @override
  Future<List<String>> getWalletAddresses() {
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
  MockBitnamesRPC() : super(binaryType: BinaryType.BINARY_TYPE_BITNAMES);

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
  Future<String> withdraw(
    String address,
    int amountSats,
    int sidechainFeeSats,
    int mainchainFeeSats,
  ) {
    return Future.value('txid_mainchain_send_1234');
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(0.00001);
  }

  @override
  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  ) {
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
  Future<List<SidechainUTXO>> listAllUTXOs() async {
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
  Future<String> createDeposit({
    required String address,
    required int feeSats,
    required int valueSats,
  }) async {
    return Future.value('mock_txid_create_deposit_1234');
  }

  @override
  Future<String> decryptMsg({
    required String ciphertext,
    required String encryptionPubkey,
  }) async {
    return Future.value('mock_decrypted_msg_1234');
  }

  @override
  Future<String> encryptMsg({
    required String msg,
    required String encryptionPubkey,
  }) async {
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
  Future<String> signArbitraryMsg({
    required String msg,
    required String verifyingKey,
  }) async {
    return Future.value('mock_signed_msg_1234');
  }

  @override
  Future<Map<String, String>> signArbitraryMsgAsAddr({
    required String msg,
    required String address,
  }) async {
    return Future.value({'signed_msg': 'mock_signed_msg_1234'});
  }

  @override
  Future<String> transfer({
    required String dest,
    required int value,
    required int fee,
    String? memo,
  }) async {
    return Future.value('mock_txid_transfer_1234');
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    return BmmResult.empty();
  }
}

class MockCoinShiftRPC extends CoinShiftRPC {
  MockCoinShiftRPC() : super(binaryType: BinaryType.BINARY_TYPE_COINSHIFT);

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
  Future<int> getBlockCount() {
    return Future.value(0);
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  List<String> getMethods() {
    return coinShiftRPCMethods;
  }

  @override
  Future<dynamic> callRAW(String method, [List<dynamic>? params]) async {
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
  Future<String> withdraw(
    String address,
    int amountSats,
    int sidechainFeeSats,
    int mainchainFeeSats,
  ) {
    return Future.value('txid_mainchain_send_1234');
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(0.00001);
  }

  @override
  Future<String> sideSend(
    String address,
    double amount,
    bool subtractFeeFromAmount,
  ) {
    return Future.value('txid_sidechain_send_5678');
  }

  @override
  Future<void> connectPeer(String peerAddress) async {
    return;
  }

  @override
  Future<void> forgetPeer(String peerAddress) async {
    return;
  }

  @override
  Future<List<String>> getWalletAddresses() {
    return Future.value(['mock_wallet_address_1234']);
  }

  @override
  Future<String> formatDepositAddress(String address) {
    return Future.value(address);
  }

  @override
  Future<Map<String, dynamic>> getOpenAPISchema() {
    return Future.value({'openapi': '3.0.0'});
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
  Future<List<SidechainUTXO>> listAllUTXOs() {
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

  // CoinShift-specific methods
  @override
  Future<List<CoinShiftSwap>> listSwaps() {
    return Future.value([]);
  }

  @override
  Future<List<CoinShiftSwap>> listSwapsByRecipient(String recipient) {
    return Future.value([]);
  }

  @override
  Future<int> reconstructSwaps() {
    return Future.value(0);
  }

  @override
  Future<CoinShiftSwapCreateResult> createSwap({
    required int l2AmountSats,
    required int l1AmountSats,
    required String l1RecipientAddress,
    required String parentChain,
    String? l2Recipient,
    int? requiredConfirmations,
    required int feeSats,
  }) {
    return Future.value(
      CoinShiftSwapCreateResult(swapId: 'mock_swap_id', txid: 'mock_txid'),
    );
  }

  @override
  Future<String> claimSwap(String swapId, {String? l2ClaimerAddress}) {
    return Future.value('mock_claim_txid');
  }

  @override
  Future<CoinShiftSwap?> getSwapStatus(String swapId) {
    return Future.value(null);
  }

  @override
  Future<void> updateSwapL1Txid({
    required String swapId,
    required String l1TxidHex,
    required int confirmations,
  }) async {
    return;
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
  String? enforcerError;

  @override
  SyncInfo? enforcerSyncInfo;

  @override
  String? mainchainError;

  @override
  SyncInfo? mainchainSyncInfo;

  @override
  Map<SidechainType, SyncInfo> sidechains = const {};

  @override
  Map<SidechainType, String?> sidechainErrors = const {};

  @override
  SyncInfo? bitwindowdSyncInfo;

  @override
  String? bitwindowdError;

  @override
  SyncConnection? get additionalConnection => throw UnimplementedError();

  @override
  SyncConnection get enforcer => throw UnimplementedError();

  @override
  EnforcerRPC get enforcerRPC => throw UnimplementedError();

  @override
  SyncConnection get mainchain => throw UnimplementedError();

  @override
  BitcoindConnection get mainchainRPC => throw UnimplementedError();

  @override
  void clearState() {}

  @override
  bool get isSynced => true;

  @override
  bool get inHeaderSync => false;
}

class MockBinary extends Binary {
  final BinaryType _type;

  MockBinary({BinaryType type = BinaryType.BINARY_TYPE_BITWINDOWD})
    : _type = type,
      super(
        name: _binaryTypeName(type),
        version: '0.0.0',
        description: 'Mock Binary',
        repoUrl: 'https://mock.test',
        directories: DirectoryConfig(
          binary: allNetworks({
            OS.linux: '.mock',
            OS.macos: 'Mock',
            OS.windows: 'Mock',
          }),
          flutterFrontend: {OS.linux: '', OS.macos: '', OS.windows: ''},
        ),
        metadata: MetadataConfig(
          downloadConfig: DownloadConfig(
            binary: 'mock',
            baseUrls: allNetworksUrl('https://mock.test'),

            files: {
              ...allNetworks({
                OS.linux: 'mock',
                OS.macos: 'mock',
                OS.windows: 'mock',
              }),
            },
          ),
          remoteTimestamp: null,
          downloadedTimestamp: null,
          binaryPath: null,
          updateable: false,
        ),
        port: 8272,
        chainLayer: 0,
      );

  @override
  BinaryType get type => _type;

  @override
  Color get color => SailColorScheme.orange;

  @override
  Binary copyWith({
    String? version,
    String? description,
    String? repoUrl,
    DirectoryConfig? directories,
    MetadataConfig? metadata,
    String? binary,
    int? port,
    int? chainLayer,
    String? walletFile,
    DownloadInfo? downloadInfo,
  }) {
    return MockBinary(type: _type);
  }
}

String _binaryTypeName(BinaryType type) {
  switch (type) {
    case BinaryType.BINARY_TYPE_BITCOIND:
      return 'Bitcoin Core';
    case BinaryType.BINARY_TYPE_ENFORCER:
      return 'Enforcer';
    case BinaryType.BINARY_TYPE_BITWINDOWD:
      return 'BitWindow';
    case BinaryType.BINARY_TYPE_THUNDER:
      return 'Thunder';
    case BinaryType.BINARY_TYPE_BITNAMES:
      return 'Bitnames';
    case BinaryType.BINARY_TYPE_BITASSETS:
      return 'BitAssets';
    case BinaryType.BINARY_TYPE_ZSIDE:
      return 'zSide';
    case BinaryType.BINARY_TYPE_GRPCURL:
      return 'grpcurl';
    case BinaryType.BINARY_TYPE_PHOTON:
      return 'Photon';
    case BinaryType.BINARY_TYPE_TRUTHCOIN:
      return 'Truthcoin';
    case BinaryType.BINARY_TYPE_COINSHIFT:
      return 'CoinShift';
    case BinaryType.BINARY_TYPE_ORCHESTRATORD:
      return 'Orchestratord';
    case BinaryType.BINARY_TYPE_ZSIDED:
      return 'ZSided';
    case BinaryType.BINARY_TYPE_UNSPECIFIED:
    default:
      throw StateError('unsupported BinaryType: $type');
  }
}

class MockBinaryProvider extends BinaryProvider {
  MockBinaryProvider()
    // ignore: invalid_use_of_visible_for_testing_member
    : super.test(
        appDir: Directory('/tmp'),
        binaries: [
          MockBinary(type: BinaryType.BINARY_TYPE_BITWINDOWD),
          MockBinary(type: BinaryType.BINARY_TYPE_ZSIDE),
          MockBinary(type: BinaryType.BINARY_TYPE_THUNDER),
          MockBinary(type: BinaryType.BINARY_TYPE_TRUTHCOIN),
          MockBinary(type: BinaryType.BINARY_TYPE_PHOTON),
          MockBinary(type: BinaryType.BINARY_TYPE_BITNAMES),
          MockBinary(type: BinaryType.BINARY_TYPE_BITASSETS),
          MockBinary(type: BinaryType.BINARY_TYPE_COINSHIFT),
        ],
      );

  @override
  void addListener(listener) {}

  @override
  void removeListener(listener) {}

  @override
  void notifyListeners() {}

  @override
  bool get hasListeners => false;
}
