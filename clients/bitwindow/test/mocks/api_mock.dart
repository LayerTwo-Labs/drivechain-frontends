import 'package:bitwindow/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:bitwindow/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:bitwindow/gen/misc/v1/misc.pbgrpc.dart';
import 'package:bitwindow/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:bitwindow/servers/api.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';

class MockAPI extends API {
  @override
  late final WalletAPI wallet = MockWalletAPI();

  @override
  late final BitcoindAPI bitcoind = MockBitcoindAPI();

  @override
  late final DrivechainAPI drivechain = MockDrivechainAPI();

  @override
  late final MiscAPI misc = MockMiscAPI();

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
  Future<void> stop() async {
    return;
  }
}

class MockWalletAPI implements WalletAPI {
  @override
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, {
    double? btcPerKvB,
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
  Future<BroadcastNewsResponse> broadcastNews(String topic, String headline) async {
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
