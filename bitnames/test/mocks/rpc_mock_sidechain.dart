import 'package:sail_ui/sail_ui.dart';

class MockSidechainRPC extends SidechainRPC {
  MockSidechainRPC()
    : super(
        binaryType: BinaryType.testSidechain,
        restartOnFailure: false,
      );

  @override
  Future<(double, double)> balance() async {
    return (1.12345678, 2.24680);
  }

  @override
  Future callRAW(String method, [dynamic params]) async {
    return;
  }

  @override
  bool get connected => true;

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return List.empty();
  }

  @override
  Future<List<String>> binaryArgs() async {
    return List.empty();
  }

  @override
  Future<String> getDepositAddress() async {
    return formatDepositAddress('3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi', 0);
  }

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async {
    return 'txiddeadbeef';
  }

  @override
  Future<double> sideEstimateFee() async {
    return 0.00001;
  }

  @override
  Future<int> ping() async {
    return await getBlockCount();
  }

  @override
  Future<int> getBlockCount() async {
    return 1;
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    return 'deadbeefdeadbeefdeadbeef';
  }

  @override
  Future<void> stopRPC() async {
    return;
  }

  @override
  Future<String> getSideAddress() async {
    return 'taddress';
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    // can't trust the rpc, give it a moment to stop
    await Future.delayed(const Duration(seconds: 3));
    return BlockchainInfo(
      chain: 'mocknet',
      blocks: 100,
      headers: 100,
      bestBlockHash: '',
      difficulty: 0,
      time: 0,
      medianTime: 0,
      verificationProgress: 100.0,
      initialBlockDownload: false,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  List<String> getMethods() {
    return [];
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    return [];
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    return BmmResult.empty();
  }

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async {
    return null;
  }
}
