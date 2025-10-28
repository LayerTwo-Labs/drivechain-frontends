import 'package:fixnum/src/int64.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart' hide UnspentOutput;
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart';
import 'package:sail_ui/gen/health/v1/health.pb.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class MockAPI extends BitwindowRPC {
  @override
  BitwindowAPI get bitwindowd => MockBitwindowdAPI();
  @override
  final WalletAPI wallet = MockWalletAPI();
  @override
  final BitcoindAPI bitcoind = MockBitcoindAPI();
  @override
  final DrivechainAPI drivechain = MockDrivechainAPI();
  @override
  final MiscAPI misc = MockMiscAPI();
  @override
  final HealthAPI health = MockHealthAPI();

  @override
  Stream<CheckResponse> get healthStream => Stream.periodic(const Duration(seconds: 1)).map((_) => CheckResponse());

  MockAPI({
    required super.binaryType,
    required super.restartOnFailure,
  });

  @override
  Future<List<String>> binaryArgs() async {
    return [];
  }

  @override
  Future<int> ping() async {
    return 1;
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<(double, double)> balance() async {
    return (1.0, 2.0);
  }

  @override
  Future<void> stopRPC() async {
    return;
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  Future callRAW(String url, [String body = '{}']) {
    return Future.value(null);
  }

  @override
  List<String> getMethods() {
    return [];
  }
}

class MockBitwindowdAPI implements BitwindowAPI {
  @override
  Future<void> stop() async {
    return;
  }

  @override
  Future<void> cancelDenial(Int64 id) {
    return Future.value();
  }

  @override
  Future<void> createDenial({
    required String txid,
    required int vout,
    required int numHops,
    required int delaySeconds,
  }) {
    return Future.value();
  }

  @override
  Future<List<AddressBookEntry>> listAddressBook() {
    return Future.value([]);
  }

  @override
  Future<void> createAddressBookEntry(String label, String address, Direction direction) {
    return Future.value();
  }

  @override
  Future<void> updateAddressBookEntry(Int64 id, String label) {
    return Future.value();
  }

  @override
  Future<void> deleteAddressBookEntry(Int64 id) {
    return Future.value();
  }

  @override
  Future<GetSyncInfoResponse> getSyncInfo() {
    return Future.value(
      GetSyncInfoResponse(
        tipBlockHeight: Int64(100),
        tipBlockTime: Int64(100),
        tipBlockHash: 'mock_hash',
        headerHeight: Int64(100),
        syncProgress: 0.5,
      ),
    );
  }

  @override
  Future<void> setTransactionNote(String txid, String note) async {
    return;
  }

  @override
  Future<GetFireplaceStatsResponse> getFireplaceStats() {
    return Future.value(GetFireplaceStatsResponse());
  }

  @override
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50}) {
    return Future.value((<Block>[], false));
  }

  @override
  Future<List<RecentTransaction>> listRecentTransactions() {
    return Future.value([]);
  }
}

class MockWalletAPI implements WalletAPI {
  @override
  Future<String> sendTransaction(
    Map<String, int> destinations, {
    int? feeSatPerVbyte,
    int? fixedFeeSats,
    String? label,
    String? opReturnMessage,
    List<UnspentOutput>? requiredInputs,
  }) async {
    return 'mock_txid';
  }

  @override
  Future<GetBalanceResponse> getBalance() async {
    return GetBalanceResponse();
  }

  @override
  Future<String> getNewAddress() async {
    return 'mock_address';
  }

  @override
  Future<List<WalletTransaction>> listTransactions() async {
    return [];
  }

  @override
  Future<List<UnspentOutput>> listUnspent() async {
    return [];
  }

  @override
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot) async {
    return [];
  }

  @override
  Future<String> createSidechainDeposit(int slot, String destination, double amount, double fee) async {
    return 'mock_deposit_txid';
  }

  @override
  Future<String> signMessage(String message) async {
    return 'mock_signature';
  }

  @override
  Future<bool> verifyMessage(String message, String signature, String publicKey) async {
    return true;
  }

  @override
  Future<GetStatsResponse> getStats() async {
    return GetStatsResponse();
  }

  @override
  Future<List<ReceiveAddress>> listReceiveAddresses() async {
    return [];
  }

  @override
  Future<CheckChequeFundingResponse> checkChequeFunding(int id) {
    return Future.value(CheckChequeFundingResponse());
  }

  @override
  Future<CreateChequeResponse> createCheque(int expectedAmountSats) {
    return Future.value(CreateChequeResponse());
  }

  @override
  Future<Cheque> getCheque(int id) {
    return Future.value(Cheque());
  }

  @override
  Future<void> isWalletUnlocked() {
    return Future.value();
  }

  @override
  Future<List<Cheque>> listCheques() {
    return Future.value([]);
  }

  @override
  Future<void> lockWallet() {
    return Future.value();
  }

  @override
  Future<String> sweepCheque(int id, String destinationAddress, int feeSatPerVbyte) {
    return Future.value('');
  }

  @override
  Future<void> unlockWallet(String password) {
    return Future.value();
  }

  @override
  Future<void> deleteCheque(int id) async {
    return;
  }
}

class MockBitcoindAPI implements BitcoindAPI {
  @override
  Future<List<Peer>> listPeers() async {
    return [];
  }

  @override
  Future<GetBlockchainInfoResponse> getBlockchainInfo() async {
    return GetBlockchainInfoResponse();
  }

  @override
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget) async {
    return EstimateSmartFeeResponse();
  }

  @override
  Future<GetRawTransactionResponse> getRawTransaction(String txid) async {
    return GetRawTransactionResponse();
  }

  @override
  Future<GetBlockResponse> getBlock({String? hash, int? height}) async {
    return GetBlockResponse();
  }

  @override
  Future<BackupWalletResponse> backupWallet(String destination, String wallet) async {
    return BackupWalletResponse();
  }

  @override
  Future<CreateMultisigResponse> createMultisig(int nRequired, List<String> keys) async {
    return CreateMultisigResponse();
  }

  @override
  Future<CreateWalletResponse> createWallet(
    String name,
    String passphrase,
    bool avoidReuse,
    bool disablePrivateKeys,
    bool blank,
  ) async {
    return CreateWalletResponse();
  }

  @override
  Future<GetAccountResponse> getAccount(String address, String wallet) async {
    return GetAccountResponse();
  }

  @override
  Future<GetAddressesByAccountResponse> getAddressesByAccount(String account, String wallet) async {
    return GetAddressesByAccountResponse();
  }

  @override
  Future<KeyPoolRefillResponse> keyPoolRefill(int newSize, String wallet) async {
    return KeyPoolRefillResponse();
  }

  @override
  Future<ListAccountsResponse> listAccounts(int minConf, String wallet) async {
    return ListAccountsResponse();
  }

  @override
  Future<SetAccountResponse> setAccount(String address, String account, String wallet) async {
    return SetAccountResponse();
  }

  @override
  Future<UnloadWalletResponse> unloadWallet(String walletName, String wallet) async {
    return UnloadWalletResponse();
  }

  @override
  Future<AnalyzePsbtResponse> analyzePsbt(AnalyzePsbtRequest request) async {
    return AnalyzePsbtResponse();
  }

  @override
  Future<CombinePsbtResponse> combinePsbt(CombinePsbtRequest request) async {
    return CombinePsbtResponse();
  }

  @override
  Future<CreatePsbtResponse> createPsbt(CreatePsbtRequest request) async {
    return CreatePsbtResponse();
  }

  @override
  Future<DecodePsbtResponse> decodePsbt(DecodePsbtRequest request) async {
    return DecodePsbtResponse();
  }

  @override
  Future<JoinPsbtsResponse> joinPsbts(JoinPsbtsRequest request) async {
    return JoinPsbtsResponse();
  }

  @override
  Future<TestMempoolAcceptResponse> testMempoolAccept(TestMempoolAcceptRequest request) async {
    return TestMempoolAcceptResponse();
  }

  @override
  Future<UtxoUpdatePsbtResponse> utxoUpdatePsbt(UtxoUpdatePsbtRequest request) async {
    return UtxoUpdatePsbtResponse();
  }
}

class MockDrivechainAPI implements DrivechainAPI {
  @override
  Future<List<ListSidechainsResponse_Sidechain>> listSidechains() async {
    return [];
  }

  @override
  Future<List<SidechainProposal>> listSidechainProposals() async {
    return [];
  }
}

class MockMiscAPI implements MiscAPI {
  @override
  Future<List<OPReturn>> listOPReturns() async {
    return [];
  }

  @override
  Future<BroadcastNewsResponse> broadcastNews(String topic, String headline, String content) async {
    return BroadcastNewsResponse();
  }

  @override
  Future<CreateTopicResponse> createTopic(String topic, String name) async {
    return CreateTopicResponse();
  }

  @override
  Future<List<CoinNews>> listCoinNews() async {
    return [];
  }

  @override
  Future<List<Topic>> listTopics() async {
    return [];
  }
}

class MockHealthAPI implements HealthAPI {
  @override
  Future<CheckResponse> check() async {
    return CheckResponse();
  }

  @override
  Stream<CheckResponse> watch() {
    return Stream.periodic(const Duration(seconds: 1)).map((_) => CheckResponse());
  }
}
