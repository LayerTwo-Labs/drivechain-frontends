import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';

class MockMainchainRPC extends MainchainRPC {
  @override
  Future<double> estimateFee() async {
    return 0.001;
  }

  @override
  Future<void> createClient() async {
    return;
  }

  @override
  Future<(bool, String?)> testConnection() async {
    return (true, null);
  }

  @override
  Future<void> ping() async {
    return;
  }

  @override
  Future<int> getWithdrawalBundleWorkScore(int sidechain, String hash) async {
    return 1;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return List.empty();
  }
}
