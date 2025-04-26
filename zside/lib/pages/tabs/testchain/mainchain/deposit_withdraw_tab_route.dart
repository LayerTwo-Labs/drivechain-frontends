import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/routing/router.dart';
import 'package:zside/widgets/containers/tabs/deposit_withdraw_tab_widgets.dart';

@RoutePage()
class DepositWithdrawTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const DepositWithdrawTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => DepositWithdrawTabViewModel(),
      builder: ((context, model, child) {
        return QtPage(
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                DepositTab(),
                WithdrawTab(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
