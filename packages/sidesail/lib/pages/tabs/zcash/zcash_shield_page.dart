import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:sidesail/widgets/containers/tabs/zcash_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ZCashShieldTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashShieldTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashShieldTabViewModel(),
      builder: ((context, viewModel, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return SailPage(
          scrollable: true,
          widgetTitle: ZCashWidgetTitle(
            depositNudgeAction: () => tabsRouter.setActiveIndex(ParentChainHome),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding30),
            child: SailColumn(
              spacing: SailStyleValues.padding30,
              children: [
                DashboardGroup(
                  title: 'Actions',
                  children: [
                    ActionTile(
                      title: 'Melt all unshielded UTXOs',
                      category: Category.sidechain,
                      icon: Icons.shield,
                      onTap: () {
                        viewModel.melt(context);
                      },
                    ),
                  ],
                ),
                DashboardGroup(
                  title: 'Operation statuses',
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.operations.length,
                          itemBuilder: (context, index) => OperationView(
                            key: ValueKey<String>(viewModel.operations[index].id),
                            tx: viewModel.operations[index],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                DashboardGroup(
                  title: 'Unshielded UTXOs',
                  widgetTrailing: SailText.secondary13(viewModel.unshieldedUTXOs.length.toString()),
                  endWidget: SailToggle(
                    label: 'Show all UTXOs',
                    value: viewModel.showAll,
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
                          ),
                      ],
                    ),
                  ],
                ),
                DashboardGroup(
                  title: 'Shielded UTXOs',
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
                          ),
                      ],
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
  List<OperationStatus> get operations => _zcashProvider.operations.reversed.toList();
  List<UnshieldedUTXO> get unshieldedUTXOs =>
      _zcashProvider.unshieldedUTXOs.where((u) => showAll || u.amount > 0.0001).toList();
  List<ShieldedUTXO> get shieldedUTXOs => _zcashProvider.shieldedUTXOs;

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool showAll = false;

  void setShowAll(bool to) {
    showAll = to;
    notifyListeners();
  }

  ZCashShieldTabViewModel() {
    _zcashProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
    init();
  }

  Future<void> init() async {}

  void melt(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const MeltAction();
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

@RoutePage()
class ZCashWidgetTitle extends ViewModelWidget<ZCashShieldTabViewModel> {
  final VoidCallback depositNudgeAction;

  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashWidgetTitle({
    super.key,
    required this.depositNudgeAction,
  });

  @override
  Widget build(BuildContext context, ZCashShieldTabViewModel viewModel) {
    if (viewModel.balance == 0) {
      return SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          SailText.secondary13('Your ZCash-address: ${viewModel.zcashAddress}'),
          Expanded(child: Container()),
        ],
      );
    }

    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        SailButton.primary(
          'Deposit coins',
          onPressed: () async {
            try {
              depositNudgeAction();
            } catch (err) {
              if (!context.mounted) {
                return;
              }

              await errorDialog(
                context: context,
                action: 'Deposit coins',
                title: 'Could not move to deposit tab',
                subtitle: err.toString(),
              );
            }
          },
          loading: viewModel.isBusy,
          size: ButtonSize.small,
        ),
        SailText.secondary12(
          'To get started, you must deposit coins to your sidechain. Peg-In on the Parent Chain tab',
        ),
        Expanded(child: Container()),
      ],
    );
  }
}
