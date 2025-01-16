import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/rpc/models/active_sidechains.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';

import 'mock_binary.dart';

class MockMainchainRPC extends MainchainRPC {
  MockMainchainRPC()
      : super(
          conf: NodeConnectionSettings('./mocked.conf', 'mocktown', 1337, '', '', true),
          binary: MockBinary(),
          logPath: './mocked.log',
        );

  @override
  Future<double> estimateFee() async {
    return 0.001;
  }

  @override
  bool get connected => true;

  @override
  Future<int> getWithdrawalBundleWorkScore(int sidechain, String hash) async {
    return 1;
  }

  @override
  Future<List<UTXO>> listUnspent() async {
    return List.empty();
  }

  @override
  Future<List<MainchainWithdrawal>> listSpentWithdrawals() async {
    return List.empty();
  }

  @override
  Future<List<MainchainWithdrawalStatus>> listWithdrawalStatus(int slot) async {
    return List.empty();
  }

  @override
  Future<List<MainchainWithdrawal>> listFailedWithdrawals() async {
    return List.empty();
  }

  @override
  Future<ActiveSidechain> createSidechainProposal(int slot, String title) async {
    return ActiveSidechain(
      title: title,
      description: "it's a mocked blockchain",
      nversion: 69,
    );
  }

  @override
  Future<List<String>> generate(int blocks) async {
    return List.filled(blocks, 'deadbeef');
  }

  @override
  Future<List<ActiveSidechain>> listActiveSidechains() async {
    return [
      ActiveSidechain(
        title: 'Testchain',
        description: "it's still a mocked blockchain",
        nversion: 69,
      ),
    ];
  }

  @override
  Future<void> stop() async {
    return;
  }

  @override
  Future<int> ping() async {
    return 69;
  }

  @override
  Future<String> getNewAddress() async {
    return '3deadbeef';
  }

  @override
  Future<String> send(String address, double amount, bool subtractFeeFromAmount) async {
    return 'txiddeeadbeef';
  }

  @override
  Future<(double, double)> getBalance() async {
    return (1.0, 2.0);
  }

  @override
  Future<String> createSidechainDeposit(int sidechainSlot, String address, double amount) async {
    return 'txiddeadbeef';
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    return BlockchainInfo(
      difficulty: 0,
      time: 0,
      medianTime: 0,
      verificationProgress: 0,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
      chain: chain.name,
      initialBlockDownload: false,
      blocks: 0,
      headers: 0,
      bestBlockHash: '',
    );
  }

  @override
  Future<void> waitForIBD() async {
    return;
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    return [];
  }
}
