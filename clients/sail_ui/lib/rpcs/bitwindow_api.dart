import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pbgrpc.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart';
import 'package:sail_ui/gen/misc/v1/misc.pbgrpc.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pbgrpc.dart';

/// API to the drivechain server.
abstract class BitwindowRPC extends RPCConnection {
  BitwindowRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
  });

  BitwindowAPI get bitwindowd;
  WalletAPI get wallet;
  BitcoindAPI get bitcoind;
  DrivechainAPI get drivechain;
  MiscAPI get misc;
}

abstract class BitwindowAPI {
  Future<void> stop();
}

abstract class WalletAPI {
  // pure bitcoind wallet stuff here
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, {
    double? btcPerKvB,
    String? opReturnMessage,
  });
  Future<GetBalanceResponse> getBalance();
  Future<String> getNewAddress();
  Future<List<WalletTransaction>> listTransactions();

  // drivechain wallet stuff here
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot);
  Future<String> createSidechainDeposit(int slot, String destination, double amount, double fee);
}

abstract class BitcoindAPI {
  Future<List<Peer>> listPeers();
  Future<List<RecentTransaction>> listRecentTransactions();
  Future<List<Block>> listRecentBlocks();
  Future<GetBlockchainInfoResponse> getBlockchainInfo();
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget);
}

abstract class DrivechainAPI {
  Future<List<ListSidechainsResponse_Sidechain>> listSidechains();
  Future<List<SidechainProposal>> listSidechainProposals();
}

abstract class MiscAPI {
  Future<List<OPReturn>> listOPReturns();
  Future<List<CoinNews>> listCoinNews();
  Future<List<Topic>> listTopics();
  Future<CreateTopicResponse> createTopic(String topic, String name);
  Future<BroadcastNewsResponse> broadcastNews(String topic, String headline);
}

class BitwindowRPCLive extends BitwindowRPC {
  @override
  late final BitwindowAPI bitwindowd;
  @override
  late final WalletAPI wallet;
  @override
  late final BitcoindAPI bitcoind;
  @override
  late final DrivechainAPI drivechain;
  @override
  late final MiscAPI misc;

  // Private constructor
  BitwindowRPCLive._create({
    required super.conf,
    required super.binary,
    required super.logPath,
  });

  // Async factory
  static Future<BitwindowRPCLive> create({
    required String host,
    required int port,
    required Binary binary,
    required String logPath,
  }) async {
    final conf = await getMainchainConf();

    final instance = BitwindowRPCLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
    );

    await instance._init(host, port);
    return instance;
  }

  Future<void> _init(String host, int port) async {
    final channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    bitwindowd = _BitwindowAPILive(BitwindowdServiceClient(channel));
    wallet = _WalletAPILive(WalletServiceClient(channel));
    bitcoind = _BitcoindAPILive(BitcoindServiceClient(channel));
    drivechain = _DrivechainAPILive(DrivechainServiceClient(channel));
    misc = _MiscAPILive(MiscServiceClient(channel));

    await startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    return [
      '--bitcoincore.rpcuser=${mainchainConf.username}',
      '--bitcoincore.rpcpassword=${mainchainConf.password}',
      '--log.path=$logPath',
    ];
  }

  @override
  Future<int> ping() async {
    return await bitcoind.getBlockchainInfo().then((value) => value.blocks);
  }

  @override
  Future<(double, double)> balance() async {
    final balanceSat = await wallet.getBalance();
    return (satoshiToBTC(balanceSat.confirmedSatoshi.toInt()), satoshiToBTC(balanceSat.pendingSatoshi.toInt()));
  }

  @override
  Future<void> stopRPC() async {
    await bitwindowd.stop();
    // can't trust the rpc, give it a moment to stop
    await Future.delayed(const Duration(milliseconds: 1500));
  }
}

class _BitwindowAPILive implements BitwindowAPI {
  final BitwindowdServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _BitwindowAPILive(this._client);

  @override
  Future<void> stop() async {
    await _client.stop(Empty());
  }
}

class _WalletAPILive implements WalletAPI {
  final WalletServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _WalletAPILive(this._client);

  @override
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, {
    double? btcPerKvB,
    String? opReturnMessage,
  }) async {
    try {
      final request = SendTransactionRequest(
        destinations: {destination: Int64(amountSatoshi)},
        feeRate: btcPerKvB,
        opReturnMessage: opReturnMessage,
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
  Future<List<WalletTransaction>> listTransactions() async {
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
  Future<String> createSidechainDeposit(int slot, String destination, double amount, double fee) async {
    try {
      final response = await _client.createSidechainDeposit(
        CreateSidechainDepositRequest()
          ..slot = Int64(slot)
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
  Future<List<RecentTransaction>> listRecentTransactions() async {
    try {
      final response = await _client.listRecentTransactions(ListRecentTransactionsRequest()..count = Int64(20));
      return response.transactions;
    } catch (e) {
      final error = 'could not list unconfirmed transactions: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
    }
  }

  @override
  Future<List<Block>> listRecentBlocks() async {
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

class _MiscAPILive implements MiscAPI {
  final MiscServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _MiscAPILive(this._client);

  @override
  Future<List<OPReturn>> listOPReturns() async {
    try {
      final response = await _client.listOPReturn(Empty());
      return response.opReturns;
    } catch (e) {
      final error = 'could not list op returns: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
    }
  }

  @override
  Future<BroadcastNewsResponse> broadcastNews(String topic, String headline) async {
    try {
      final response = await _client.broadcastNews(
        BroadcastNewsRequest()
          ..topic = topic
          ..headline = headline,
      );
      return response;
    } catch (e) {
      final error = 'could not broadcast news: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
    }
  }

  @override
  Future<CreateTopicResponse> createTopic(String topic, String name) async {
    try {
      final response = await _client.createTopic(
        CreateTopicRequest()
          ..topic = topic
          ..name = name,
      );
      return response;
    } catch (e) {
      final error = 'could not create topic: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
    }
  }

  @override
  Future<List<CoinNews>> listCoinNews() async {
    try {
      final response = await _client.listCoinNews(ListCoinNewsRequest());
      return response.coinNews;
    } catch (e) {
      final error = 'could not list coin news: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
    }
  }

  @override
  Future<List<Topic>> listTopics() async {
    try {
      final response = await _client.listTopics(Empty());
      return response.topics;
    } catch (e) {
      final error = 'could not list topics: ${extractGRPCError(e)}';
      log.e(error);
      throw BitcoindException(error);
    }
  }
}

class WalletException implements Exception {
  final String message;
  WalletException(this.message);
  @override
  String toString() => 'WalletException: $message';
}

class BitcoindException implements Exception {
  final String message;
  BitcoindException(this.message);
  @override
  String toString() => 'BitcoindException: $message';
}

class DrivechainException implements Exception {
  final String message;
  DrivechainException(this.message);
  @override
  String toString() => 'DrivechainException: $message';
}
