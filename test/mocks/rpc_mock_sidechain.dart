import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

class MockSidechainRPC extends SidechainRPC {
  MockSidechainRPC() {
    chain = TestSidechain();
  }

  @override
  Future<(double, double)> getBalance() async {
    return (1.12345678, 2.24680);
  }

  @override
  Future callRAW(String method, [dynamic params]) async {
    return;
  }

  @override
  Future<(bool, String?)> testConnection() async {
    return (true, null);
  }

  @override
  Future<void> createClient() async {
    return;
  }

  @override
  Future<void> ping() async {
    return;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return List.empty();
  }
}
