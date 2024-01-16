import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/models/active_sidechains.dart';
import 'package:sidesail/rpc/models/utxo.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';

class MockMainchainRPC extends MainchainRPC {
  MockMainchainRPC() : super(conf: SingleNodeConnectionSettings('./mocked.conf', 'mocktown', 1337, '', '', true));

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
  Future<void> stopNode() async {
    return;
  }

  @override
  Future<int> fetchBlockCount() async {
    return 69;
  }
}
