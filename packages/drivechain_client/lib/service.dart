import 'package:drivechain_client/env.dart';
import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/gen/google/protobuf/empty.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:grpc/grpc.dart';

class DrivechainService extends InheritedWidget {
  late final DrivechainServiceClient _client;

  DrivechainService({required super.child, super.key}) {
    final channel = ClientChannel(
      env(Environment.drivechainHost),
      port: env(Environment.drivechainPort),
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    _client = DrivechainServiceClient(channel);
  }

  Future<String> sendTransaction(
    Map<String, int> destinations, [
    double? satoshiPerVbyte,
  ]) async {
    final request = SendTransactionRequest(
      destinations: destinations.map((k, v) => MapEntry(k, Int64(v))),
      satoshiPerVbyte: satoshiPerVbyte,
    );

    final response = await _client.sendTransaction(request);
    return response.txid;
  }

  Future<GetBalanceResponse> getBalance() async {
    return await _client.getBalance(Empty());
  }

  Future<String> getNewAddress() async {
    final response = await _client.getNewAddress(Empty());
    return response.address;
  }

  Future<List<Transaction>> listTransactions() async {
    final response = await _client.listTransactions(Empty());
    return response.transactions;
  }

  Future<List<UnconfirmedTransaction>> listUnconfirmedTransactions() async {
    final response = await _client.listUnconfirmedTransactions(Empty());
    return response.unconfirmedTransactions;
  }

  Future<List<ListRecentBlocksResponse_RecentBlock>> listRecentBlocks() async {
    final response = await _client.listRecentBlocks(Empty());
    return response.recentBlocks;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static DrivechainService of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DrivechainService>()!;
  }
}
