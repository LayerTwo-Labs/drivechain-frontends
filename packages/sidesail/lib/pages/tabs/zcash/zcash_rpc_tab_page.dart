import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';
import 'package:sidesail/widgets/containers/tabs/console.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ZCashRPCTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashRPCTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashRPCTabPageViewModel(),
      builder: ((context, model, child) {
        return SailPage(
          scrollable: true,
          title: 'RPC',
          subtitle: 'Send RPCs directly to the ZCash sidechain. Try typing in "getblockcount" in the input below.',
          body: Padding(
            padding: const EdgeInsets.only(bottom: 10 * SailStyleValues.padding50),
            child: Column(
              children: [
                RPCWidget(
                  rpcMethods: zcashRPCMethods,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class ZCashRPCTabPageViewModel extends BaseViewModel {
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  ZCashRPCTabPageViewModel() {
    _rpc.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _rpc.removeListener(notifyListeners);
  }
}
