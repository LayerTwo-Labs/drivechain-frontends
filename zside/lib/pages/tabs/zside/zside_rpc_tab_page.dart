import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/console/integrated_console_view.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/routing/router.dart';

@RoutePage()
class ZSideRPCTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZSideRPCTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZSideRPCTabPageViewModel(),
      builder: ((context, model, child) {
        return SailCard(
          color: context.sailTheme.colors.background,
          child: Column(
            children: [
              Expanded(
                child: IntegratedConsoleView(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ZSideRPCTabPageViewModel extends BaseViewModel {
  ZSideRPC get _rpc => GetIt.I.get<ZSideRPC>();

  ZSideRPCTabPageViewModel() {
    _rpc.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _rpc.removeListener(notifyListeners);
  }
}
