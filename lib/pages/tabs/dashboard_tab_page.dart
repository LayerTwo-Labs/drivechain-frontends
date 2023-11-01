import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class DashboardTabPage extends StatelessWidget {
  const DashboardTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomePageViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          title: '',
          widgetTitle: Row(
            children: [
              SailText.mediumPrimary14('Balance: ${viewModel.sidechainBalance} SBTC'),
              Expanded(child: Container()),
              SailText.mediumPrimary14('Unconfirmed balance: ${viewModel.sidechainPendingBalance} SBTC'),
            ],
          ),
          body: Column(
            children: [
              DashboardGroup(
                title: 'Actions',
                children: [
                  ActionTile(
                    title: 'Peg-out to mainchain',
                    category: Category.mainchain,
                    icon: Icons.remove,
                    onTap: () {
                      viewModel.pegOut(context);
                    },
                  ),
                  ActionTile(
                    title: 'Peg-in from mainchain',
                    category: Category.mainchain,
                    icon: Icons.add,
                    onTap: () {
                      viewModel.pegIn(context);
                    },
                  ),
                  ActionTile(
                    title: 'Send on sidechain',
                    category: Category.sidechain,
                    icon: Icons.remove,
                    onTap: () {
                      viewModel.send(context);
                    },
                  ),
                  ActionTile(
                    title: 'Receive on sidechain',
                    category: Category.sidechain,
                    icon: Icons.add,
                    onTap: () {
                      viewModel.receive(context);
                    },
                  ),
                ],
              ),
              const SailSpacing(SailStyleValues.padding30),
              DashboardGroup(
                title: 'Transactions',
                children: [
                  SailText.mediumPrimary20('TBD'),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class HomePageViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  String get sidechainBalance => _balanceProvider.balance.toStringAsFixed(8);
  String get sidechainPendingBalance => _balanceProvider.pendingBalance.toStringAsFixed(8);

  Timer? balanceTimer;

  HomePageViewModel() {
    // by adding a listener, we subscribe to changes to the balance
    // provider. We don't use the updates for anything other than
    // showing the new value though, so we keep it simple, and just
    // pass notifyListeners of this view model directly
    _balanceProvider.addListener(notifyListeners);

    balanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _balanceProvider.fetch();
    });
  }

  void pegOut(BuildContext context) async {
    final theme = SailTheme.of(context);

    await showDialog(
      context: context,
      barrierColor: theme.colors.background.withOpacity(0.4),
      builder: (BuildContext context) {
        return const PegOutAction();
      },
    );
  }

  void pegIn(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PegInAction();
      },
    );
  }

  void send(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SendOnSidechainAction();
      },
    );
  }

  void receive(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ReceiveOnSidechainAction();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (balanceTimer != null) {
      balanceTimer!.cancel();
    }
  }
}
