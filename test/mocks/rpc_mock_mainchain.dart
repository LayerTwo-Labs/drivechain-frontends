import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';

class MockMainchainRPC extends MainchainRPC {
  MockMainchainRPC() : super(conf: SingleNodeConnectionSettings('./mocked.conf', 'mocktown', 1337, '', ''));

  @override
  Future<double> estimateFee() async {
    return 0.001;
  }

  @override
  bool get connected => true;

  @override
  Future<void> ping() async {}

  @override
  Future<int> getWithdrawalBundleWorkScore(int sidechain, String hash) async {
    return 1;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
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
}
