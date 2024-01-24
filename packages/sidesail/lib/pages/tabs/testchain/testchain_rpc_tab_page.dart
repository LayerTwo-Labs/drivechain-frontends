import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_testchain.dart';
import 'package:sidesail/widgets/containers/tabs/console.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class TestchainRPCTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const TestchainRPCTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => TestchainRPCTabPageViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          scrollable: true,
          title: 'RPC',
          subtitle: 'Call RPCs directly to the Testchain sidechain. Try typing in "getblockcount" in the input below.',
          body: Padding(
            padding: const EdgeInsets.only(bottom: 10 * SailStyleValues.padding50),
            child: Column(
              children: [
                RPCWidget(
                  rpcMethods: testRPCMethods,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class TestchainRPCTabPageViewModel extends BaseViewModel {
  TestchainRPC get _rpc => GetIt.I.get<TestchainRPC>();

  TestchainRPCTabPageViewModel() {
    _rpc.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _rpc.removeListener(notifyListeners);
  }
}
