import 'package:bitwindow/api.dart';
import 'package:bitwindow/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:bitwindow/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:bitwindow/gen/wallet/v1/wallet.pbgrpc.dart';

class MockAPI implements API {
  @override
  late final WalletAPI wallet = MockWalletAPI();

  @override
  late final BitcoindAPI bitcoind = MockBitcoindAPI();

  @override
  late final DrivechainAPI drivechain = MockDrivechainAPI();
}

class MockWalletAPI implements WalletAPI {
  @override
  Future<String> sendTransaction(String destination, int amountSatoshi,
      [double? btcPerKvB, bool replaceByFee = false,]) async {
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
  Future<List<Transaction>> listTransactions() async {
    return [];
  }

  @override
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot) async {
    return [];
  }

  @override
  Future<String> createSidechainDeposit(String destination, double amount, double fee) async {
    return 'mock_deposit_txid';
  }
}

class MockBitcoindAPI implements BitcoindAPI {
  @override
  Future<List<Peer>> listPeers() async {
    return [];
  }

  @override
  Future<List<UnconfirmedTransaction>> listUnconfirmedTransactions() async {
    return [];
  }

  @override
  Future<List<ListRecentBlocksResponse_RecentBlock>> listRecentBlocks() async {
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
