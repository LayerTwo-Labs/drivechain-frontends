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
}
