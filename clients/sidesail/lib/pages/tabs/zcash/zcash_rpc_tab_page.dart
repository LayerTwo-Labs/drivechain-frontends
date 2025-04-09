import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/routing/router.dart';
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
        return SailCard(
          color: context.sailTheme.colors.background,
          child: Column(
            children: [
              Expanded(
                child: ConsoleView(
                  services: [
                    ConsoleService(
                      name: 'zcash',
                      commands: zcashRPCMethods,
                      execute: (command, args) => model._rpc.callRAW(command, args),
                    ),
                  ],
                ),
              ),
            ],
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
