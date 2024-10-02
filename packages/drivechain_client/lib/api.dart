import 'package:drivechain_client/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/gen/google/protobuf/empty.pb.dart';
import 'package:drivechain_client/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:drivechain_client/exceptions.dart';

/// API to the drivechain server.
abstract class API {
  WalletAPI get wallet;
  BitcoindAPI get bitcoind;
  DrivechainAPI get drivechain;
}

abstract class WalletAPI {
  // pure bitcoind wallet stuff here
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, [
    double? btcPerKvB,
    bool replaceByFee,
  ]);
  Future<GetBalanceResponse> getBalance();
  Future<String> getNewAddress();
  Future<List<Transaction>> listTransactions();

  // drivechain wallet stuff here
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot);
  Future<String> createSidechainDeposit(String destination, double amount, double fee);
}

abstract class BitcoindAPI {
  Future<List<Peer>> listPeers();
  Future<List<UnconfirmedTransaction>> listUnconfirmedTransactions();
  Future<List<ListRecentBlocksResponse_RecentBlock>> listRecentBlocks();
  Future<GetBlockchainInfoResponse> getBlockchainInfo();
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget);
}

abstract class DrivechainAPI {
  Future<List<ListSidechainsResponse_Sidechain>> listSidechains();
  Future<List<SidechainProposal>> listSidechainProposals();
}

class APILive extends API {
  Logger get log => GetIt.I.get<Logger>();
  late final DrivechainServiceClient _client;
  late final BitcoindServiceClient _bitcoindClient;
  late final WalletServiceClient _walletClient;

  late final WalletAPI _wallet;
  late final BitcoindAPI _bitcoind;
  late final DrivechainAPI _drivechain;

  APILive({
    required String host,
    required int port,
  }) {
    final channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    _client = DrivechainServiceClient(channel);
    _bitcoindClient = BitcoindServiceClient(channel);
    _walletClient = WalletServiceClient(channel);

    _wallet = _WalletAPILive(_walletClient);
    _bitcoind = _BitcoindAPILive(_bitcoindClient);
    _drivechain = _DrivechainAPILive(_client);
  }

  @override
  WalletAPI get wallet => _wallet;
  @override
  BitcoindAPI get bitcoind => _bitcoind;
  @override
  DrivechainAPI get drivechain => _drivechain;
}

class _WalletAPILive implements WalletAPI {
  final WalletServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _WalletAPILive(this._client);

  @override
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, [
    double? btcPerKvB,
    bool replaceByFee = false,
  ]) async {
    try {
      final request = SendTransactionRequest(
        destinations: {destination: Int64(amountSatoshi)},
        feeRate: btcPerKvB,
        rbf: replaceByFee,
      );

      final response = await _client.sendTransaction(request);
      return response.txid;
    } catch (e) {
      log.e('Error sending transaction: $e');
      throw WalletException('Failed to send transaction: ${e.toString()}');
    }
  }

  @override
  Future<GetBalanceResponse> getBalance() async {
    try {
      return await _client.getBalance(Empty());
    } catch (e) {
      log.e('Error getting balance: $e');
      throw WalletException('Failed to get balance: ${e.toString()}');
    }
  }

  @override
  Future<String> getNewAddress() async {
    try {
      final response = await _client.getNewAddress(Empty());
      return response.address;
    } catch (e) {
      log.e('Error getting new address: $e');
      throw WalletException('Failed to get new address: ${e.toString()}');
    }
  }

  @override
  Future<List<Transaction>> listTransactions() async {
    try {
      final response = await _client.listTransactions(Empty());
      return response.transactions;
    } catch (e) {
      log.e('Error listing transactions: $e');
      throw WalletException('Failed to list transactions: ${e.toString()}');
    }
  }

  @override
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot) async {
    try {
      final response = await _client.listSidechainDeposits(ListSidechainDepositsRequest()..slot = slot);
      return response.deposits;
    } catch (e) {
      log.e('Error listing sidechain deposits: $e');
      throw WalletException('Failed to list sidechain deposits: ${e.toString()}');
    }
  }

  @override
  Future<String> createSidechainDeposit(String destination, double amount, double fee) async {
    try {
      final response = await _client.createSidechainDeposit(
        CreateSidechainDepositRequest()
          ..destination = destination
          ..amount = amount
          ..fee = fee,
      );
      return response.txid;
    } catch (e) {
      log.e('Error creating sidechain deposit: $e');
      throw WalletException('Failed to create sidechain deposit: ${e.toString()}');
    }
  }
}

class _BitcoindAPILive implements BitcoindAPI {
  final BitcoindServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _BitcoindAPILive(this._client);

  @override
  Future<List<UnconfirmedTransaction>> listUnconfirmedTransactions() async {
    try {
      final response =
          await _client.listUnconfirmedTransactions(ListUnconfirmedTransactionsRequest()..count = Int64(20));
      return response.unconfirmedTransactions;
    } catch (e) {
      log.e('Error listing unconfirmed transactions: $e');
      throw BitcoindException('Failed to list unconfirmed transactions: ${e.toString()}');
    }
  }

  @override
  Future<List<ListRecentBlocksResponse_RecentBlock>> listRecentBlocks() async {
    try {
      final response = await _client.listRecentBlocks(ListRecentBlocksRequest()..count = Int64(20));
      return response.recentBlocks;
    } catch (e) {
      log.e('Error listing recent blocks: $e');
      throw BitcoindException('Failed to list recent blocks: ${e.toString()}');
    }
  }

  @override
  Future<GetBlockchainInfoResponse> getBlockchainInfo() async {
    try {
      final response = await _client.getBlockchainInfo(Empty());
      return response;
    } catch (e) {
      log.e('Error getting blockchain info: $e');
      throw BitcoindException('Failed to get blockchain info: ${e.toString()}');
    }
  }

  @override
  Future<List<Peer>> listPeers() async {
    try {
      final response = await _client.listPeers(Empty());
      return response.peers;
    } catch (e) {
      log.e('Error listing peers: $e');
      throw BitcoindException('Failed to list peers: ${e.toString()}');
    }
  }

  @override
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget) async {
    try {
      final response = await _client.estimateSmartFee(EstimateSmartFeeRequest()..confTarget = Int64(confTarget));
      return response;
    } catch (e) {
      log.e('Error estimating smart fee: $e');
      throw BitcoindException('Failed to estimate smart fee: ${e.toString()}');
    }
  }
}

class _DrivechainAPILive implements DrivechainAPI {
  final DrivechainServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _DrivechainAPILive(this._client);

  @override
  Future<List<ListSidechainsResponse_Sidechain>> listSidechains() async {
    try {
      final response = await _client.listSidechains(ListSidechainsRequest());
      return response.sidechains;
    } catch (e) {
      log.e('Error listing sidechains: $e');
      throw DrivechainException('Failed to list sidechains: ${e.toString()}');
    }
  }

  @override
  Future<List<SidechainProposal>> listSidechainProposals() async {
    try {
      final response = await _client.listSidechainProposals(ListSidechainProposalsRequest());
      return response.proposals;
    } catch (e) {
      log.e('Error listing sidechain proposals: $e');
      throw DrivechainException('Failed to list sidechain proposals: ${e.toString()}');
    }
  }
}
