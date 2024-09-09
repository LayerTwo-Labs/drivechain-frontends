import 'package:drivechain_client/env.dart';
import 'package:drivechain_client/gen/drivechain/v1/drivechain.pbgrpc.dart';
import 'package:drivechain_client/gen/google/protobuf/empty.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:grpc/grpc.dart';

class DrivechainService extends InheritedWidget {
  late final DrivechainServiceClient _client;
  
  // Response cache
  final Map<String, GetBalanceResponse> _balanceCache = {};
  final Map<String, List<Transaction>> _transactionsCache = {};
  final Map<String, List<UnconfirmedTransaction>> _unconfirmedTransactionsCache = {};
  final Map<String, List<ListRecentBlocksResponse_RecentBlock>> _recentBlocksCache = {};

  // Cache timestamps
  final Map<String, DateTime> _cacheTimestamps = {};

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

  /// Returns a tuple of the confirmed and pending balance in satoshi
  Future<GetBalanceResponse> getBalance() async {
    const cacheKey = 'balance';
    if (_balanceCache.containsKey(cacheKey) &&
        _cacheTimestamps[cacheKey] != null &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!) < const Duration(minutes: 1)) {
      return _balanceCache[cacheKey]!;
    }

    final response = await _client.getBalance(Empty());
    _balanceCache[cacheKey] = response;
    _cacheTimestamps[cacheKey] = DateTime.now();
    return response;
  }

  Future<String> getNewAddress() async {
    final response = await _client.getNewAddress(Empty());
    return response.address;
  }

  Future<List<Transaction>> listTransactions() async {
    const cacheKey = 'transactions';
    if (_transactionsCache.containsKey(cacheKey) &&
        _cacheTimestamps[cacheKey] != null &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!) < const Duration(minutes: 1)) {
      return _transactionsCache[cacheKey]!;
    }

    final response = await _client.listTransactions(Empty());
    _transactionsCache[cacheKey] = response.transactions;
    _cacheTimestamps[cacheKey] = DateTime.now();
    return response.transactions;
  }

  Future<List<UnconfirmedTransaction>> listUnconfirmedTransactions() async {
    const cacheKey = 'unconfirmedTransactions';
    if (_unconfirmedTransactionsCache.containsKey(cacheKey) &&
        _cacheTimestamps[cacheKey] != null &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!) < const Duration(minutes: 1)) {
      return _unconfirmedTransactionsCache[cacheKey]!;
    }

    final response = await _client.listUnconfirmedTransactions(Empty());
    _unconfirmedTransactionsCache[cacheKey] = response.unconfirmedTransactions;
    _cacheTimestamps[cacheKey] = DateTime.now();
    return response.unconfirmedTransactions;
  }

  Future<List<ListRecentBlocksResponse_RecentBlock>> listRecentBlocks() async {
    const cacheKey = 'recentBlocks';
    if (_recentBlocksCache.containsKey(cacheKey) &&
        _cacheTimestamps[cacheKey] != null &&
        DateTime.now().difference(_cacheTimestamps[cacheKey]!) < const Duration(minutes: 1)) {
      return _recentBlocksCache[cacheKey]!;
    }

    final response = await _client.listRecentBlocks(Empty());
    _recentBlocksCache[cacheKey] = response.recentBlocks;
    _cacheTimestamps[cacheKey] = DateTime.now();
    return response.recentBlocks;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static DrivechainService of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DrivechainService>()!;
  }
}
