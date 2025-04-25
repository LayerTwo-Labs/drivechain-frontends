import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:thunder/routing/router.dart';
import 'package:thunder/rpc/rpc_testchain.dart';

@RoutePage()
class TestchainRPCTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const TestchainRPCTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => TestchainRPCTabPageViewModel(),
      builder: ((context, model, child) {
        return SailPage(
          scrollable: true,
          title: 'RPC',
          subtitle: 'Send RPCs directly to the Testchain sidechain. Try typing in "getblockcount" in the input below.',
          body: Padding(
            padding: const EdgeInsets.only(bottom: 10 * SailStyleValues.padding64),
            child: Column(
              children: [
                ConsoleView(
                  services: [
                    ConsoleService(
                      name: 'testchain',
                      commands: testRPCMethods,
                      execute: (command, args) => model._rpc.callRAW(command, args),
                    ),
                  ],
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
