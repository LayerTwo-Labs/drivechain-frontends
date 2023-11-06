import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_withdrawal_bundle.dart';

class MockSidechainRPC extends SidechainRPC {
  MockSidechainRPC() {
    chain = TestSidechain();
  }

  @override
  Future<String> generatePegInAddress() async {
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
  Future<BmmResult> refreshBMM(int bidSatoshis) async {
    return BmmResult(
      hashLastMainBlock: '',
      bmmBlockCreated: '',
      bmmBlockSubmitted: '',
      bmmBlockSubmittedBlind: '',
      ntxn: 0,
      nfees: 0,
      txid: '',
      error: '',
      raw: '',
    );
  }

  @override
  Future<double> estimateFee() async {
    return 0.001;
  }

  @override
  Future<String> getRefundAddress() async {
    return 'sc1_deadbeef';
  }

  @override
  Future<String> generateSidechainAddress() async {
    return 's1deadbeef';
  }

  @override
  Future<String> pegOut(String address, double amount, double sidechainFee, double mainchainFee) async {
    return 'txidmainbeef';
  }

  @override
  Future<String> sidechainSend(String address, double amount, bool subtractFeeFromAmount) async {
    return 'txidsidebeef';
  }

  @override
  Future<List<Transaction>> listTransactions() async {
    return List.empty();
  }

  @override
  Future<int> blockCount() async {
    return 1;
  }

  @override
  Future<int> mainchainBlockCount() async {
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
  Future<WithdrawalBundle> currentWithdrawalBundle() async {
    return WithdrawalBundle(
      hash: '',
      bundleSize: 0,
      blockHeight: 0,
      withdrawals: [],
    );
  }

  @override
  Future<FutureWithdrawalBundle> nextWithdrawalBundle() async {
    return FutureWithdrawalBundle(cumulativeWeight: 0, withdrawals: []);
  }
}
