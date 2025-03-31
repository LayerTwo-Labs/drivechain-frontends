import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_ethereum.dart';
import 'package:stacked/stacked.dart';
import 'package:web3dart/web3dart.dart';

@RoutePage()
class EthereumRPCTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const EthereumRPCTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => EthereumRPCTabPageViewModel(),
      builder: ((context, model, child) {
        return SailPage(
          scrollable: true,
          title: 'RPC',
          subtitle: 'Send RPCs directly to the Ethereum sidechain. Try typing in "eth_blockNumber" in the input below.',
          widgetTitle: SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              if (model.account == null)
                SailButton(
                  label: 'Create account',
                  onPressed: () async {
                    try {
                      await model.createAccount();
                    } catch (err) {
                      if (!context.mounted) {
                        return;
                      }

                      await errorDialog(
                        context: context,
                        action: 'Create account',
                        title: 'Could not create account',
                        subtitle: err.toString(),
                      );
                    }
                  },
                  loading: model.isBusy,
                ),
              if (model.account == null)
                SailText.secondary12('You need an account to deposit and withdraw sidechain-coins'),
              if (model.account != null) SailText.secondary13('Your ETH-address: ${model.account!.toString()}'),
              Expanded(child: Container()),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 10 * SailStyleValues.padding64),
            child: ConsoleView(
              services: [
                ConsoleService(
                  name: 'ethereum',
                  commands: ethRPCMethods,
                  execute: (command, args) => model._rpc.callRAW(command, args),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class EthereumRPCTabPageViewModel extends BaseViewModel {
  EthereumRPC get _rpc => GetIt.I.get<EthereumRPC>();

  EthereumAddress? get account => _rpc.account;

  EthereumRPCTabPageViewModel() {
    _rpc.addListener(notifyListeners);
  }

  bool running = false;

  Future<void> createAccount() async {
    try {
      setBusy(true);
      if (account != null) {
        throw Exception('you can only make one account using the GUI');
      }

      await _rpc.newAccount();
    } finally {
      setBusy(false);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _rpc.removeListener(notifyListeners);
  }
}
