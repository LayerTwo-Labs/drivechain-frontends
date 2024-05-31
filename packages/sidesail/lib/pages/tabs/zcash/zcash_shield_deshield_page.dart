import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/components/dashboard_group.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:sidesail/pages/tabs/zcash/zcash_transfer_page.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/widgets/containers/tabs/zcash_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ZCashShieldDeshieldTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashShieldDeshieldTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashShieldTabViewModel(),
      builder: ((context, viewModel, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return SailPage(
          scrollable: true,
          widgetTitle: ZCashWidgetTitle(
            depositNudgeAction: () => tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding30),
            child: SailColumn(
              spacing: SailStyleValues.padding30,
              children: [
                SailRow(
                  spacing: 0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: DashboardGroup(
                        title: 'Transparent UTXOs',
                        widgetTrailing: SailText.secondary13(viewModel.unshieldedUTXOs.length.toString()),
                        widgetEnd: SailToggle(
                          label: 'Hide dust UTXOs',
                          value: viewModel.hideDust,
                          onChanged: (to) => viewModel.setShowAll(to),
                        ),
                        children: [
                          SailColumn(
                            spacing: 0,
                            withDivider: true,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final utxo in viewModel.unshieldedUTXOs)
                                UnshieldedUTXOView(
                                  utxo: utxo,
                                  shieldAction: () => viewModel.shield(context, utxo),
                                  meltMode: false,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: theme.colors.divider,
                    ),
                    Flexible(
                      child: DashboardGroup(
                        title: 'Private UTXOs',
                        widgetTrailing: SailText.secondary13(viewModel.shieldedUTXOs.length.toString()),
                        children: [
                          SailColumn(
                            spacing: 0,
                            withDivider: true,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final utxo in viewModel.shieldedUTXOs)
                                ShieldedUTXOView(
                                  utxo: utxo,
                                  deshieldAction: () => viewModel.deshield(context, utxo),
                                  castMode: false,
                                ),
                            ],
                          ),
                        ],
                      ),
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

class ZCashShieldTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  String get zcashAddress => _zcashProvider.zcashAddress;
  List<UnshieldedUTXO> get unshieldedUTXOs =>
      _zcashProvider.unshieldedUTXOs.where((u) => !hideDust || u.amount > 0.0001).toList();
  List<ShieldedUTXO> get shieldedUTXOs => _zcashProvider.shieldedUTXOs;

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool hideDust = false;

  void setShowAll(bool to) {
    hideDust = to;
    notifyListeners();
  }

  ZCashShieldTabViewModel() {
    _zcashProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
  }

  void melt(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const MeltAction();
      },
    );
  }

  void cast(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const CastAction();
      },
    );
  }

  void shield(BuildContext context, UnshieldedUTXO unshieldedUTXO) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return ShieldUTXOAction(utxo: unshieldedUTXO);
      },
    );
  }

  void deshield(BuildContext context, ShieldedUTXO shieldedUTXO) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return DeshieldUTXOAction(utxo: shieldedUTXO);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _zcashProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
  }
}
