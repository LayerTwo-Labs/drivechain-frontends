import 'package:sidesail/rpc/rpc_mainchain.dart';

class MockMainchainRPC extends MainchainRPC {
  @override
  Future<double> estimateFee() async {
    return 0.001;
  }
}
