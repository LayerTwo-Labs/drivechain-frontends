import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';

class MockSidechainRPC extends SidechainRPC {
  MockSidechainRPC()
      : super(
          conf: SingleNodeConnectionSettings('mock town', 'mock mock', 1337, '', ''),
          chain: TestSidechain(),
        );

  @override
  Future<(double, double)> getBalance() async {
    return (1.12345678, 2.24680);
  }

  @override
  Future callRAW(String method, [dynamic params]) async {
    return;
  }

  @override
  bool get connected => true;

  @override
  Future<void> ping() async {}

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return List.empty();
  }
}
