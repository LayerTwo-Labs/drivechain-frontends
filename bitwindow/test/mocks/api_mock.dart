import 'package:fixnum/src/int64.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart';
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

  MockAPI({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  });

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
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
  Future<List<DeniabilityUTXO>> listDenials() {
    return Future.value([]);
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
}

class MockWalletAPI implements WalletAPI {
  @override
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, {
    double? btcPerKvB,
    String? label,
    String? opReturnMessage,
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
}

class MockBitcoindAPI implements BitcoindAPI {
  @override
  Future<List<Peer>> listPeers() async {
    return [];
  }

  @override
  Future<List<RecentTransaction>> listRecentTransactions() async {
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
  Future<Block> getBlock({String? hash, int? height}) async {
    return Block();
  }

  @override
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50}) {
    return Future.value((<Block>[], false));
  }

  @override
  Future<AddMultisigAddressResponse> addMultisigAddress(
    int nRequired,
    List<String> keys,
    String label,
    String wallet,
  ) async {
    return AddMultisigAddressResponse();
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
  Future<DumpPrivKeyResponse> dumpPrivKey(String address, String wallet) async {
    return DumpPrivKeyResponse();
  }

  @override
  Future<DumpWalletResponse> dumpWallet(String filename, String wallet) async {
    return DumpWalletResponse();
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
  Future<ImportAddressResponse> importAddress(String address, String label, bool rescan, String wallet) async {
    return ImportAddressResponse();
  }

  @override
  Future<ImportPrivKeyResponse> importPrivKey(String privateKey, String label, bool rescan, String wallet) async {
    return ImportPrivKeyResponse();
  }

  @override
  Future<ImportPubKeyResponse> importPubKey(String pubkey, bool rescan, String wallet) async {
    return ImportPubKeyResponse();
  }

  @override
  Future<ImportWalletResponse> importWallet(String filename, String wallet) async {
    return ImportWalletResponse();
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
