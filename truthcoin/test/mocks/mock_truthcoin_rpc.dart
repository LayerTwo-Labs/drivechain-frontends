import 'package:sail_ui/sail_ui.dart';

/// A controllable mock for TruthcoinRPC that allows tests to configure
/// specific responses for market and voting operations.
class TestTruthcoinRPC extends TruthcoinRPC {
  TestTruthcoinRPC() : super(binaryType: BinaryType.truthcoin, restartOnFailure: false);

  // Connection state
  bool _connected = true;
  final bool _initializing = false;
  final bool _stopping = false;
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

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Configurable responses
  List<Map<String, dynamic>> marketListResponse = [];
  Map<String, dynamic>? marketGetResponse;
  Map<String, dynamic> marketBuyResponse = {'txid': 'test_buy_txid'};
  Map<String, dynamic> marketSellResponse = {'txid': 'test_sell_txid'};
  Map<String, dynamic> marketPositionsResponse = {};
  String marketCreateResponse = 'test_create_txid';

  Map<String, dynamic> slotStatusResponse = {};
  List<Map<String, dynamic>> slotListResponse = [];
  Map<String, dynamic>? slotGetResponse;

  Map<String, dynamic>? voteVoterResponse;
  List<Map<String, dynamic>> voteVotersResponse = [];
  Map<String, dynamic>? votePeriodResponse;
  String voteRegisterResponse = 'test_register_txid';
  String voteSubmitResponse = 'test_submit_txid';

  List<String> walletAddresses = ['tb1qtest1234567890'];
  int votecoinBalanceResponse = 1000;

  // Error simulation
  bool shouldThrowOnMarketList = false;
  bool shouldThrowOnMarketGet = false;
  bool shouldThrowOnMarketBuy = false;
  bool shouldThrowOnMarketSell = false;
  bool shouldThrowOnVotePeriod = false;
  String errorMessage = 'Test error';

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() async => (1.0, 0.5);

  @override
  Future<List<String>> binaryArgs() async => [];

  @override
  Future<int> ping() async => 100;

  @override
  Future<int> getBlockCount() async => 100;

  @override
  List<String> startupErrors() => [];

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    return BlockchainInfo(
      chain: 'testnet',
      blocks: 100,
      headers: 100,
      bestBlockHash: 'testhash',
      difficulty: 1.0,
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      medianTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      verificationProgress: 1.0,
      initialBlockDownload: false,
      chainWork: '',
      sizeOnDisk: 1000000,
      pruned: false,
      warnings: [],
    );
  }

  @override
  List<String> getMethods() => truthcoinRPCMethods;

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async => null;

  @override
  Future<String> getDepositAddress() async => 'tb1qdeposit';

  @override
  Future<String> getSideAddress() async => 'tb1qside';

  @override
  Future<List<CoreTransaction>> listTransactions() async => [];

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async {
    return 'withdraw_txid';
  }

  @override
  Future<double> sideEstimateFee() async => 0.00001;

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    return 'send_txid';
  }

  @override
  Future<void> connectPeer(String peerAddress) async {}

  @override
  Future<String> createDeposit(String address, double amount, double fee) async => 'deposit_txid';

  @override
  Future<String> generateMnemonic() async => 'test mnemonic words here';

  @override
  Future<String> getBMMInclusions(String blockHash) async => '';

  @override
  Future<String?> getBestMainchainBlockHash() async => 'mainchain_hash';

  @override
  Future<String?> getBestSidechainBlockHash() async => 'sidechain_hash';

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) async => {'hash': hash};

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async => null;

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async => null;

  @override
  Future<double> getSidechainWealth() async => 100.0;

  @override
  Future<List<Map<String, dynamic>>> listPeers() async => [];

  @override
  Future<List<SidechainUTXO>> listUTXOs() async => [];

  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async => [];

  @override
  Future<BmmResult> mine(int feeSats) async => BmmResult.empty();

  @override
  Future<void> removeFromMempool(String txid) async {}

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {}

  // Wallet addresses
  @override
  Future<List<String>> getWalletAddresses() async => walletAddresses;

  // Prediction Markets
  @override
  Future<Map<String, dynamic>> calculateInitialLiquidity({
    required double beta,
    int? numOutcomes,
    String? dimensions,
  }) async {
    return {'liquidity': 10000};
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
    return marketCreateResponse;
  }

  @override
  Future<List<Map<String, dynamic>>> marketList() async {
    if (shouldThrowOnMarketList) {
      throw Exception(errorMessage);
    }
    return marketListResponse;
  }

  @override
  Future<Map<String, dynamic>?> marketGet(String marketId) async {
    if (shouldThrowOnMarketGet) {
      throw Exception(errorMessage);
    }
    return marketGetResponse;
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
    if (shouldThrowOnMarketBuy) {
      throw Exception(errorMessage);
    }
    return marketBuyResponse;
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
    if (shouldThrowOnMarketSell) {
      throw Exception(errorMessage);
    }
    return marketSellResponse;
  }

  @override
  Future<Map<String, dynamic>> marketPositions({String? address, String? marketId}) async {
    return marketPositionsResponse;
  }

  // Slots
  @override
  Future<Map<String, dynamic>> slotStatus() async => slotStatusResponse;

  @override
  Future<List<Map<String, dynamic>>> slotList({int? period, String? status}) async => slotListResponse;

  @override
  Future<Map<String, dynamic>?> slotGet(String slotId) async => slotGetResponse;

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
    return 'slot_claim_txid';
  }

  @override
  Future<String> slotClaimCategory({
    required List<Map<String, dynamic>> slots,
    required bool isStandard,
    required int feeSats,
  }) async {
    return 'slot_claim_category_txid';
  }

  // Voting
  @override
  Future<String> voteRegister({required int feeSats, int? reputationBondSats}) async {
    return voteRegisterResponse;
  }

  @override
  Future<Map<String, dynamic>?> voteVoter(String address) async => voteVoterResponse;

  @override
  Future<List<Map<String, dynamic>>> voteVoters() async => voteVotersResponse;

  @override
  Future<String> voteSubmit({required List<Map<String, dynamic>> votes, required int feeSats}) async {
    return voteSubmitResponse;
  }

  @override
  Future<List<Map<String, dynamic>>> voteList({String? voter, String? decisionId, int? periodId}) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>?> votePeriod({int? periodId}) async {
    if (shouldThrowOnVotePeriod) {
      throw Exception(errorMessage);
    }
    return votePeriodResponse;
  }

  // Votecoin
  @override
  Future<String> votecoinTransfer({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  }) async {
    return 'votecoin_transfer_txid';
  }

  @override
  Future<int> votecoinBalance(String address) async => votecoinBalanceResponse;

  @override
  Future<String> transferVotecoin({
    required String dest,
    required int amount,
    required int feeSats,
    String? memo,
  }) async {
    return 'transfer_votecoin_txid';
  }

  // Additional required methods
  @override
  Future<void> refreshWallet() async {}

  @override
  Future<Map<String, dynamic>?> getTransaction(String txid) async {
    return {'txid': txid};
  }

  @override
  Future<Map<String, dynamic>?> getTransactionInfo(String txid) async {
    return {'txid': txid, 'confirmations': 10};
  }

  @override
  Future<List<SidechainUTXO>> myUtxos() async => [];

  @override
  Future<List<SidechainUTXO>> myUnconfirmedUtxos() async => [];

  @override
  Future<String> getNewEncryptionKey() async => 'test_encryption_key';

  @override
  Future<String> getNewVerifyingKey() async => 'test_verifying_key';

  @override
  Future<String> encryptMsg({required String msg, required String encryptionPubkey}) async {
    return 'encrypted_message';
  }

  @override
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey}) async {
    return 'decrypted_message';
  }

  @override
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey}) async {
    return 'signed_message';
  }

  @override
  Future<Map<String, dynamic>> signArbitraryMsgAsAddr({required String address, required String msg}) async {
    return {'signature': 'test_signature', 'address': address};
  }

  @override
  Future<bool> verifySignature({
    required String msg,
    required String signature,
    required String verifyingKey,
    required String dst,
  }) async {
    return true;
  }
}
