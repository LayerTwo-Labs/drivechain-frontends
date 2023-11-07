import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';

class MockSidechainRPC extends SidechainRPC {
  MockSidechainRPC() {
    chain = TestSidechain();
  }

  @override
  Future<String> mainGenerateAddress() async {
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
  Future<double> sideEstimateFee() async {
    return 0.001;
  }

  @override
  Future<String> sideGenerateAddress() async {
    return 's1deadbeef';
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) async {
    return 'txidmainbeef';
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    return 'txidsidebeef';
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return List.empty();
  }

  @override
  Future<int> sideBlockCount() async {
    return 1;
  }

  @override
  Future<int> mainBlockCount() async {
    return 1;
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
  Future<WithdrawalBundle> mainCurrentWithdrawalBundle() async {
    return WithdrawalBundle(
      hash: '',
      bundleSize: 0,
      blockHeight: 0,
      withdrawals: [],
    );
  }

  @override
  Future<FutureWithdrawalBundle> mainNextWithdrawalBundle() async {
    return FutureWithdrawalBundle(cumulativeWeight: 0, withdrawals: []);
  }
}
