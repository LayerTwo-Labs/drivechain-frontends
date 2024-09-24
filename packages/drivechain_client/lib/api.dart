import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/gen/google/protobuf/empty.pb.dart';
import 'package:drivechain_client/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

/// API to the drivechain server.
abstract class API {
  WalletAPI get wallet;
  BitcoindAPI get bitcoind;
}

abstract class WalletAPI {
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, [
    double? btcPerKvB,
    bool replaceByFee,
  ]);
  Future<GetBalanceResponse> getBalance();
  Future<String> getNewAddress();
  Future<List<Transaction>> listTransactions();
}

abstract class BitcoindAPI {
  Future<List<Peer>> listPeers();
  Future<List<UnconfirmedTransaction>> listUnconfirmedTransactions();
  Future<List<ListRecentBlocksResponse_RecentBlock>> listRecentBlocks();
  Future<GetBlockchainInfoResponse> getBlockchainInfo();
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget);
}

class APILive extends API {
  late final BitcoindServiceClient _bitcoindClient;
  late final WalletServiceClient _walletClient;

  late final WalletAPI _wallet;
  late final BitcoindAPI _bitcoind;

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

    _bitcoindClient = BitcoindServiceClient(channel);
    _walletClient = WalletServiceClient(channel);

    _wallet = _WalletAPILive(_walletClient);
    _bitcoind = _BitcoindAPILive(_bitcoindClient);
  }

  @override
  WalletAPI get wallet => _wallet;
  @override
  BitcoindAPI get bitcoind => _bitcoind;
}

class _WalletAPILive implements WalletAPI {
  final WalletServiceClient _client;

  _WalletAPILive(this._client);

  @override
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, [
    double? btcPerKvB,
    bool replaceByFee = false,
  ]) async {
    final request = SendTransactionRequest(
      destinations: {destination: Int64(amountSatoshi)},
      feeRate: btcPerKvB,
      rbf: replaceByFee,
    );

    final response = await _client.sendTransaction(request);
    return response.txid;
  }

  @override
  Future<GetBalanceResponse> getBalance() async {
    return await _client.getBalance(Empty());
  }

  @override
  Future<String> getNewAddress() async {
    final response = await _client.getNewAddress(Empty());
    return response.address;
  }

  @override
  Future<List<Transaction>> listTransactions() async {
    final response = await _client.listTransactions(Empty());
    return response.transactions;
  }
}

class _BitcoindAPILive implements BitcoindAPI {
  final BitcoindServiceClient _client;

  _BitcoindAPILive(this._client);

  @override
  Future<List<UnconfirmedTransaction>> listUnconfirmedTransactions() async {
    final response = await _client.listUnconfirmedTransactions(ListUnconfirmedTransactionsRequest()..count = Int64(20));
    return response.unconfirmedTransactions;
  }

  @override
  Future<List<ListRecentBlocksResponse_RecentBlock>> listRecentBlocks() async {
    final response = await _client.listRecentBlocks(ListRecentBlocksRequest()..count = Int64(20));
    return response.recentBlocks;
  }

  @override
  Future<GetBlockchainInfoResponse> getBlockchainInfo() async {
    final response = await _client.getBlockchainInfo(Empty());
    return response;
  }

  @override
  Future<List<Peer>> listPeers() async {
    final response = await _client.listPeers(Empty());
    return response.peers;
  }

  @override
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget) async {
    final response = await _client.estimateSmartFee(EstimateSmartFeeRequest()..confTarget = Int64(confTarget));
    return response;
  }
}
