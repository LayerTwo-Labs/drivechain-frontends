import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/chains.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:sidesail/pages/tabs/zcash/zcash_transfer_page.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/models/zcash_utxos.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/rpc/rpc_zcash.dart';
import 'package:sidesail/widgets/containers/tabs/zcash_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ZCashMeltCastTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashMeltCastTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashShieldCastViewModel(),
      builder: ((context, model, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return SailPage(
          scrollable: true,
          widgetTitle: ZCashWidgetTitle(
            depositNudgeAction: () => tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index),
          ),
          body: const ZCashMeltCast(),
        );
      }),
    );
  }
}

class ZCashShieldCastViewModel extends BaseViewModel {
  bool castMode = true;

  void setCastMode(bool to) {
    castMode = to;
    notifyListeners();
  }

  ZCashShieldCastViewModel();
}

class ZCashMeltCast extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashMeltCast({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashMeltCastViewModel(),
      builder: ((context, model, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: SailStyleValues.padding30),
          child: SailColumn(
            spacing: 0,
            children: [
              ActionTile(
                title: "What's going on?",
                category: Category.sidechain,
                icon: Icons.question_mark,
                onTap: () {
                  model.meltAndCastHelp(context);
                },
              ),
              ActionTile(
                title: 'Do everything for me',
                category: Category.sidechain,
                icon: Icons.work,
                onTap: () {
                  model.doEverything(context);
                },
              ),
              SailRow(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 0,
                children: [
                  Flexible(
                    child: SailColumn(
                      spacing: SailStyleValues.padding30,
                      children: [
                        DashboardGroup(
                          title: 'Melt',
                          widgetEnd: HelpButton(onPressed: () => model.meltHelp(context)),
                          children: [
                            ActionTile(
                              title: 'Melt',
                              category: Category.sidechain,
                              icon: Icons.shield,
                              onTap: () {
                                model.melt(context);
                              },
                            ),
                          ],
                        ),
                        if (model.pendingMelts.isNotEmpty)
                          DashboardGroup(
                            title: 'Pending melts',
                            children: [
                              SailColumn(
                                spacing: 0,
                                withDivider: true,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: model.pendingMelts.length,
                                    itemBuilder: (context, index) => PendingMeltView(
                                      key: ValueKey<String>(model.pendingMelts[index].utxo.raw),
                                      tx: model.pendingMelts[index],
                                    ),
                                  ),
                                ],
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
                    child: SailColumn(
                      spacing: SailStyleValues.padding30,
                      children: [
                        DashboardGroup(
                          title: 'Cast',
                          widgetEnd: SailRow(
                            spacing: SailStyleValues.padding08,
                            children: [
                              HelpButton(onPressed: () => model.castHelp(context)),
                              SailScaleButton(
                                child: SailSVG.icon(SailSVGAsset.iconCalendar),
                                onPressed: () => model.viewBills(),
                              ),
                            ],
                          ),
                          children: [
                            ActionTile(
                              title: 'Cast',
                              category: Category.sidechain,
                              icon: Icons.handyman,
                              onTap: () {
                                model.cast(context);
                              },
                            ),
                          ],
                        ),
                        if (model.pendingNonEmptyBills.isNotEmpty)
                          DashboardGroup(
                            title: 'Pending casts',
                            children: [
                              SailColumn(
                                spacing: 0,
                                withDivider: true,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: model.pendingNonEmptyBills.length,
                                    itemBuilder: (context, index) => PendingCastView(
                                      key: ValueKey<int>(model.pendingNonEmptyBills[index].powerOf),
                                      pending: model.pendingNonEmptyBills[index],
                                      chain: model.chain,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SailSpacing(SailStyleValues.padding30),
              DashboardGroup(
                title: 'UTXOs',
                widgetTrailing: SailText.secondary13(model.unshieldedUTXOs.length.toString()),
                widgetEnd: SailToggle(
                  label: 'Hide dust UTXOs',
                  value: model.hideDust,
                  onChanged: (to) => model.setShowAll(to),
                ),
                children: [
                  SailColumn(
                    spacing: 0,
                    withDivider: true,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final utxo in model.allUTXOs)
                        if (utxo is UnshieldedUTXO)
                          UnshieldedUTXOView(
                            utxo: utxo,
                            shieldAction: () => model.meltSingle(context, utxo),
                            meltMode: true,
                          )
                        else
                          ShieldedUTXOView(
                            utxo: utxo,
                            deshieldAction: () => model.castSingle(context, utxo),
                            castMode: true,
                          ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ZCashMeltCastViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  CastProvider get _castProvider => GetIt.I.get<CastProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();
  AppRouter get router => GetIt.I.get<AppRouter>();

  Chain get chain => _sideRPC.rpc.chain;
  String get zcashAddress => _zcashProvider.zcashAddress;
  List<PendingShield> get pendingMelts =>
      _zcashProvider.utxosToMelt.where((element) => element.executeTime.isAfter(DateTime.now())).toList();
  List<PendingCastBill> get pendingNonEmptyBills =>
      _castProvider.futureCasts.where((element) => element.pendingShields.isNotEmpty).toList();
  List<UnshieldedUTXO> get unshieldedUTXOs =>
      _zcashProvider.unshieldedUTXOs.where((u) => !hideDust || u.amount > zcashFee).toList();
  List<ShieldedUTXO> get shieldedUTXOs => _zcashProvider.shieldedUTXOs;
  List<dynamic> get allUTXOs => [...unshieldedUTXOs, ...shieldedUTXOs];

  List<CoreTransaction> get transparentTransactions => _zcashProvider.transparentTransactions;
  List<ShieldedUTXO> get privateTransactions => _zcashProvider.privateTransactions;

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool castMode = true;
  bool hideDust = true;

  void setShowAll(bool to) {
    hideDust = to;
    notifyListeners();
  }

  void setCastMode(bool to) {
    castMode = to;
    notifyListeners();
  }

  ZCashMeltCastViewModel() {
    _zcashProvider.addListener(notifyListeners);
    _castProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
  }

  void melt(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const MeltAction(
          doEverythingMode: false,
        );
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

  void meltSingle(BuildContext context, UnshieldedUTXO unshieldedUTXO) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return MeltSingleUTXOAction(utxo: unshieldedUTXO);
      },
    );
  }

  void castSingle(BuildContext context, ShieldedUTXO shieldedUTXO) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return CastSingleUTXOAction(utxo: shieldedUTXO);
      },
    );
  }

  Future<void> meltHelp(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const MeltHelp();
      },
    );
  }

  Future<void> castHelp(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const CastHelp();
      },
    );
  }

  Future<void> meltAndCastHelp(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const MeltAndCastHelp();
      },
    );
  }

  Future<void> doEverything(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const MeltAction(
          doEverythingMode: true,
        );
      },
    );
  }

  Future<void> viewBills() async {
    await router.push(const ZCashBillRoute());
  }

  @override
  void dispose() {
    super.dispose();
    _zcashProvider.removeListener(notifyListeners);
    _castProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
  }
}
