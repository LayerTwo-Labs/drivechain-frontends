import 'package:sidesail/rpc/rpc.dart';

class MockRPC extends RPC {
  @override
  Future<String> fetchWithdrawalBundleStatus() async {
    return '<some sensible value>';
  }

  @override
  Future<String> generateDepositAddress() async {
    return 'bc1...?';
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
  Future<Map<String, dynamic>> refreshBMM(int bidSatoshis) async {
    return <String, String>{};
  }

  @override
  Future<double> estimateSidechainFee() async {
    return 0.001;
  }

  @override
  Future<String> getRefundAddress() async {
    return 'sc1..?';
  }
}
