import 'package:bitwindow/exceptions.dart';
import 'package:bitwindow/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:bitwindow/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:bitwindow/gen/google/protobuf/empty.pb.dart';
import 'package:bitwindow/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:bitwindow/util/error.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';

/// API to the drivechain server.
abstract class API extends RPCConnection {
  API({
    required super.conf,
    required super.binaryName,
    required super.logPath,
  });

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
  late final DrivechainServiceClient _client;
  late final BitcoindServiceClient _bitcoindClient;
  late final WalletServiceClient _walletClient;

  late final WalletAPI _wallet;
  late final BitcoindAPI _bitcoind;
  late final DrivechainAPI _drivechain;

  APILive({
    required String host,
    required int port,
    required super.conf,
    required super.binaryName,
    required super.logPath,
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

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    return [
      '--electrum.host=drivechain.live:50001',
      '--electrum.no-ssl',
      '--bitcoincore.rpcuser=${mainchainConf.username}',
      '--bitcoincore.rpcpassword=${mainchainConf.password}',
      '--log.path=$logPath',
    ];
  }

  @override
  Future<int> ping() async {
    return await _bitcoind.getBlockchainInfo().then((value) => value.blocks);
  }

  @override
  Future<void> stop() async {
    // TODO: not implemented
  }
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
      final error = 'could not send transaction: ${extractGRPCError(e)}';
      log.e(error);
      throw WalletException(error);
    }
  }

  @override
  Future<GetBalanceResponse> getBalance() async {
    try {
      return await _client.getBalance(Empty());
    } catch (e) {
      final error = 'could not get balance: ${extractGRPCError(e)}';
      log.e(error);
      throw WalletException(error);
    }
  }

  @override
  Future<String> getNewAddress() async {
    try {
      final response = await _client.getNewAddress(Empty());
      return response.address;
    } catch (e) {
      final error = 'could not get new address: ${extractGRPCError(e)}';
      log.e(error);
      throw WalletException(error);
    }
  }

  @override
  Future<List<Transaction>> listTransactions() async {
    try {
      final response = await _client.listTransactions(Empty());
      return response.transactions;
    } catch (e) {
      final error = 'could not list transactions: ${extractGRPCError(e)}';
      log.e(error);
      throw WalletException(error);
    }
  }

  @override
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot) async {
    try {
      final response = await _client.listSidechainDeposits(ListSidechainDepositsRequest()..slot = slot);
      return response.deposits;
    } catch (e) {
      final error = 'could not list sidechain deposits: ${extractGRPCError(e)}';
      log.e(error);
      throw WalletException(error);
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
      final error = extractGRPCError(e);
      log.e('could not create deposit: $error');
      throw WalletException(error);
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
      final error = 'could not list unconfirmed transactions: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
    }
  }

  @override
  Future<List<ListRecentBlocksResponse_RecentBlock>> listRecentBlocks() async {
    try {
      final response = await _client.listRecentBlocks(ListRecentBlocksRequest()..count = Int64(20));
      return response.recentBlocks;
    } catch (e) {
      final error = 'could not list recent blocks: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
    }
  }

  @override
  Future<GetBlockchainInfoResponse> getBlockchainInfo() async {
    // This should not try catched because callers elsewhere expect
    // it to throw if the connection is not live.
    final response = await _client.getBlockchainInfo(Empty());
    return response;
  }

  @override
  Future<List<Peer>> listPeers() async {
    try {
      final response = await _client.listPeers(Empty());
      return response.peers;
    } catch (e) {
      final error = 'could not list peers: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
    }
  }

  @override
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget) async {
    try {
      final response = await _client.estimateSmartFee(EstimateSmartFeeRequest()..confTarget = Int64(confTarget));
      return response;
    } catch (e) {
      final error = 'could not estimate smart fee: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
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
      final error = 'could not list sidechains: ${extractGRPCError(e)}';
      log.e(error);
      throw DrivechainException(error);
    }
  }

  @override
  Future<List<SidechainProposal>> listSidechainProposals() async {
    try {
      final response = await _client.listSidechainProposals(ListSidechainProposalsRequest());
      return response.proposals;
    } catch (e) {
      final error = 'could not list sidechain proposals: ${extractGRPCError(e)}';
      log.e(error);
      throw DrivechainException(error);
    }
  }
}
