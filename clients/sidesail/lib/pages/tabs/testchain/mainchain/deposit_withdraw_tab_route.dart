import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/widgets/containers/tabs/deposit_withdraw_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class DepositWithdrawTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const DepositWithdrawTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => DepositWithdrawTabViewModel(),
      builder: ((context, model, child) {
        return SailPage(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SailStyleValues.padding08,
                vertical: SailStyleValues.padding04,
              ),
              child: SailColumn(
                spacing: SailStyleValues.padding32,
                children: [
                  SailColumn(
                    spacing: SailStyleValues.padding32,
                    children: [
                      DepositTab(),
                      WithdrawTab(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
