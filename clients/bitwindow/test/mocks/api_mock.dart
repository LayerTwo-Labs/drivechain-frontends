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
  Future<void> createDenial({required int numHops, required int delaySeconds}) {
    return Future.value();
  }

  @override
  Future<List<Denial>> listDenials() {
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
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot) async {
    return [];
  }

  @override
  Future<String> createSidechainDeposit(int slot, String destination, double amount, double fee) async {
    return 'mock_deposit_txid';
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
  Future<List<Block>> listRecentBlocks() async {
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
