import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/gen/google/protobuf/empty.pb.dart';
import 'package:drivechain_client/gen/wallet/v1/wallet.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

/// API to the drivechain server.
abstract class API {
  Future<String> sendTransaction(
    Map<String, int> destinations, [
    double? satoshiPerVbyte,
  ]);
  Future<GetBalanceResponse> getBalance();
  Future<String> getNewAddress();
  Future<List<Transaction>> listTransactions();
  Future<List<UnconfirmedTransaction>> listUnconfirmedTransactions();
}

class APILive extends API {
  late final DrivechainServiceClient _client;
  late final WalletServiceClient _walletClient;

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
    _walletClient = WalletServiceClient(channel);
  }

  @override
  Future<String> sendTransaction(
    Map<String, int> destinations, [
    double? satoshiPerVbyte,
  ]) async {
    final request = SendTransactionRequest(
      destinations: destinations.map((k, v) => MapEntry(k, Int64(v))),
      satoshiPerVbyte: satoshiPerVbyte,
    );

    final response = await _walletClient.sendTransaction(request);
    return response.txid;
  }

  @override
  Future<GetBalanceResponse> getBalance() async {
    return await _walletClient.getBalance(Empty());
  }

  @override
  Future<String> getNewAddress() async {
    final response = await _walletClient.getNewAddress(Empty());
    return response.address;
  }

  @override
  Future<List<Transaction>> listTransactions() async {
    final response = await _walletClient.listTransactions(Empty());
    return response.transactions;
  }

  @override
  Future<List<UnconfirmedTransaction>> listUnconfirmedTransactions() async {
    final response = await _client.listUnconfirmedTransactions(Empty());
    return response.unconfirmedTransactions;
  }

  Future<List<ListRecentBlocksResponse_RecentBlock>> listRecentBlocks() async {
    final response = await _client.listRecentBlocks(Empty());
    return response.recentBlocks;
  }
}
