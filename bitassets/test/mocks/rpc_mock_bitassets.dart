import 'package:sail_ui/sail_ui.dart';

class MockBitAssetsRPC extends BitAssetsRPC {
  MockBitAssetsRPC()
      : super(
          conf: NodeConnectionSettings('mock town', 'mock mock', 1337, '', '', true),
          binary: BitAssets(),
          restartOnFailure: false,
        );

  @override
  Future<String> ammBurn({required String asset0, required String asset1, required int lpTokenAmount}) {
    return Future.value('mocked');
  }

  @override
  Future<String> ammMint({required String asset0, required String asset1, required int amount0, required int amount1}) {
    return Future.value('mocked');
  }

  @override
  Future<int> ammSwap({required String assetSpend, required String assetReceive, required int amountSpend}) {
    return Future.value(123);
  }

  @override
  Future<(double, double)> balance() {
    return Future.value((1.12345678, 2.24680));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future callRAW(String method, [List? params]) {
    return Future.value(null);
  }

  @override
  Future<void> connectPeer(String address) {
    return Future.value();
  }

  @override
  Future<String> createDeposit({required String address, required int feeSats, required int valueSats}) {
    return Future.value('mocked');
  }

  @override
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey}) {
    return Future.value('mocked');
  }

  @override
  Future<int> dutchAuctionBid({required String dutchAuctionId, required int bidSize}) {
    return Future.value(123);
  }

  @override
  Future<List<int>> dutchAuctionCollect(String dutchAuctionId) {
    return Future.value([123]);
  }

  @override
  Future<String> dutchAuctionCreate(DutchAuctionParams params) {
    return Future.value('mocked');
  }

  @override
  Future<List<DutchAuctionEntry>> dutchAuctions() {
    return Future.value([]);
  }

  @override
  Future<String> encryptMsg({required String msg, required String encryptionPubkey}) {
    return Future.value('mocked');
  }

  @override
  Future<String> generateMnemonic() {
    return Future.value('mocked');
  }

  @override
  Future<AmmPoolState?> getAmmPoolState({required String asset0, required String asset1}) {
    return Future.value(
      AmmPoolState(
        reserve0: 1,
        reserve1: 2,
        outstandingLpTokens: 123,
        creationTxid: 'mocked',
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> getAmmPrice({required String base, required String quote}) {
    return Future.value(
      {
        'base': 1,
        'quote': 2,
      },
    );
  }

  @override
  Future<String> getBMMInclusions(String blockHash) {
    return Future.value('mocked');
  }

  @override
  Future<BalanceResponse> getBalance() {
    return Future.value(
      BalanceResponse(
        totalSats: 1,
        availableSats: 2,
      ),
    );
  }

  @override
  Future<String?> getBestMainchainBlockHash() {
    return Future.value('mocked');
  }

  @override
  Future<String?> getBestSidechainBlockHash() {
    return Future.value('mocked');
  }

  @override
  Future<BitAssetRequest?> getBitAssetData(String assetId) {
    return Future.value(
      BitAssetRequest(
        initialSupply: 123,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) {
    return Future.value(
      {
        'hash': 'mocked',
        'height': 123,
      },
    );
  }

  @override
  Future<int> getBlockCount() {
    return Future.value(123);
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    return Future.value(
      BlockchainInfo(
        chain: 'mocked',
        blocks: 123,
        headers: 123,
        bestBlockHash: 'mocked',
        difficulty: 123,
        time: 123,
        medianTime: 123,
        verificationProgress: 123,
        initialBlockDownload: true,
        chainWork: 'mocked',
        sizeOnDisk: 123,
        pruned: true,
        warnings: [],
      ),
    );
  }

  @override
  Future<String> getDepositAddress() {
    return Future.value('mocked');
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() {
    return Future.value(123);
  }

  @override
  List<String> getMethods() {
    return ['mocked'];
  }

  @override
  Future<String> getNewAddress() {
    return Future.value('mocked');
  }

  @override
  Future<String> getNewEncryptionKey() {
    return Future.value('mocked');
  }

  @override
  Future<String> getNewVerifyingKey() {
    return Future.value('mocked');
  }

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() {
    return Future.value(PendingWithdrawalBundle.empty());
  }

  @override
  Future<String> getSideAddress() {
    return Future.value('mocked');
  }

  @override
  Future<int> getSidechainWealth() {
    return Future.value(123);
  }

  @override
  Future<List<String>> getWalletAddresses() {
    return Future.value(['mocked']);
  }

  @override
  Future<List> getWalletUTXOs() {
    return Future.value([]);
  }

  @override
  Future<List<BitAssetEntry>> listBitAssets() {
    return Future.value([]);
  }

  @override
  Future<List<BitAssetsPeerInfo>> listPeers() {
    return Future.value([]);
  }

  @override
  Future<List<CoreTransaction>> listTransactions() {
    return Future.value([]);
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() {
    return Future.value([]);
  }

  @override
  Future<Map<String, dynamic>> openapiSchema() {
    return Future.value({});
  }

  @override
  Future<int> ping() {
    return Future.value(123);
  }

  @override
  Future<String> registerBitAsset(String assetId, BitAssetRequest? data) {
    return Future.value('mocked');
  }

  @override
  Future<String> reserveBitAsset(String assetId) {
    return Future.value('mocked');
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) {
    return Future.value();
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(123);
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) {
    return Future.value('mocked');
  }

  @override
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey}) {
    return Future.value('mocked');
  }

  @override
  Future<Map<String, String>> signArbitraryMsgAsAddr({required String msg, required String address}) {
    return Future.value({'mocked': 'mocked'});
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<void> stopRPC() {
    return Future.value();
  }

  @override
  Future<String> transfer({required String dest, required int value, required int fee, String? memo}) {
    return Future.value('mocked');
  }

  @override
  Future<bool> verifySignature({required String msg, required String signature, required String verifyingKey}) {
    return Future.value(true);
  }

  @override
  Future<BmmResult> mine(int feeSats) {
    return Future.value(
      BmmResult.empty(),
    );
  }

  @override
  Future<String> withdraw(
    String mainchainAddress,
    int amountSats,
    int sidechainFeeSats,
    int mainchainFeeSats,
  ) {
    return Future.value('mocked');
  }
}
