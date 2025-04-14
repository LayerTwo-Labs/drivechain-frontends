import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/pages/tabs/sidechain_overview_page.dart';
import 'package:sidesail/providers/cast_provider.dart';
import 'package:sidesail/providers/zcash_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/widgets/containers/tabs/zcash_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class ZCashMeltCastTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashMeltCastTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZCashMeltCastViewModel(),
      builder: ((context, model, child) {
        return QtPage(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: SailStyleValues.padding32),
              child: SailColumn(
                spacing: SailStyleValues.padding32,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MeltButton(
                              onPressed: () => model.melt(context),
                            ),
                            const SizedBox(height: SailStyleValues.padding16),
                            SailCard(
                              bottomPadding: false,
                              title: 'Pending melts',
                              subtitle: 'See list of ongoing melts and their status',
                              widgetHeaderEnd: HelpButton(onPressed: () => model.meltHelp(context)),
                              child: SizedBox(
                                height: 300,
                                child: PendingMeltTable(
                                  entries: model.pendingMelts,
                                  onMelt: () => model.melt(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SailStyleValues.padding16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CastButton(
                              onPressed: () async => model.cast(context),
                            ),
                            const SizedBox(height: SailStyleValues.padding16),
                            SailCard(
                              title: 'Pending casts',
                              subtitle: 'See list of ongoing casts and their status',
                              bottomPadding: false,
                              widgetHeaderEnd: SailRow(
                                spacing: SailStyleValues.padding08,
                                children: [
                                  HelpButton(onPressed: () => model.castHelp(context)),
                                  SailButton(
                                    variant: ButtonVariant.icon,
                                    onPressed: () => model.viewBills(),
                                    icon: SailSVGAsset.iconCalendar,
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                height: 300,
                                child: PendingCastsTable(
                                  entries: model.pendingNonEmptyBills,
                                  chain: model.chain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SailButton(
                    label: 'View Z Operation Status',
                    variant: ButtonVariant.secondary,
                    onPressed: () async {
                      await router.push(const ZCashOperationStatusesTabRoute());
                    },
                  ),
                  SizedBox(
                    height: 300,
                    child: OperationsTable(
                      entries: model.operations,
                      onClear: () => model.clear(),
                    ),
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
          padding: const EdgeInsets.only(bottom: SailStyleValues.padding32),
          child: SailColumn(
            spacing: 0,
            children: [
              ActionTile(
                title: "What's going on?",
                category: Category.sidechain,
                icon: SailSVGAsset.iconArrow,
                onTap: () async {
                  await model.meltAndCastHelp(context);
                },
              ),
              ActionTile(
                title: 'Do everything for me',
                category: Category.sidechain,
                icon: SailSVGAsset.iconArrow,
                onTap: () async {
                  await model.doEverything(context);
                },
              ),
              SailRow(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 0,
                children: [
                  Flexible(
                    child: SailColumn(
                      spacing: SailStyleValues.padding32,
                      children: [
                        DashboardGroup(
                          title: 'Melt',
                          widgetEnd: HelpButton(onPressed: () => model.meltHelp(context)),
                          children: [
                            ActionTile(
                              title: 'Melt',
                              category: Category.sidechain,
                              icon: SailSVGAsset.iconArrow,
                              onTap: () async {
                                model.melt(context);
                              },
                            ),
                          ],
                        ),
                        if (model.pendingMelts.isNotEmpty)
                          DashboardGroup(
                            title: 'Pending melts',
                            children: [
                              SizedBox(
                                height: 300,
                                child: PendingMeltTable(
                                  entries: model.pendingMelts,
                                  onMelt: () => model.melt(context),
                                ),
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
                      spacing: SailStyleValues.padding32,
                      children: [
                        DashboardGroup(
                          title: 'Cast',
                          widgetEnd: SailRow(
                            spacing: SailStyleValues.padding08,
                            children: [
                              HelpButton(onPressed: () => model.castHelp(context)),
                              SailButton(
                                variant: ButtonVariant.icon,
                                onPressed: () => model.viewBills(),
                                icon: SailSVGAsset.iconCalendar,
                              ),
                            ],
                          ),
                          children: [
                            ActionTile(
                              title: 'Cast',
                              category: Category.sidechain,
                              icon: SailSVGAsset.iconArrow,
                              onTap: () async {
                                model.cast(context);
                              },
                            ),
                          ],
                        ),
                        if (model.pendingNonEmptyBills.isNotEmpty)
                          DashboardGroup(
                            title: 'Pending casts',
                            children: [
                              SizedBox(
                                height: 300,
                                child: PendingCastsTable(
                                  entries: model.pendingNonEmptyBills,
                                  chain: model.chain,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SailSpacing(SailStyleValues.padding32),
              DashboardGroup(
                title: 'UTXOs',
                widgetTrailing: SailText.secondary13(model.unshieldedUTXOs.length.toString()),
                widgetEnd: SailToggle(
                  label: 'Hide dust UTXOs',
                  value: model.hideDust,
                  onChanged: (to) => model.setShowAll(to),
                ),
                children: [
                  SizedBox(
                    height: 300,
                    child: UTXOsTable(
                      entries: model.allUTXOs,
                      hideDust: model.hideDust,
                      onMeltSingle: (context, utxo) => model.meltSingle(context, utxo),
                      onCastSingle: (context, utxo) => model.castSingle(context, utxo),
                    ),
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

  Binary get chain => _sideRPC.rpc.chain;
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

  List<OperationStatus> get operations => _zcashProvider.operations;

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

  void clear() {
    _zcashProvider.operations = List.empty();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _zcashProvider.removeListener(notifyListeners);
    _castProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
  }
}

class PendingMeltTable extends StatefulWidget {
  final List<PendingShield> entries;
  final VoidCallback onMelt;

  const PendingMeltTable({
    super.key,
    required this.entries,
    required this.onMelt,
  });

  @override
  State<PendingMeltTable> createState() => _PendingMeltTableState();
}

class _PendingMeltTableState extends State<PendingMeltTable> {
  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => widget.entries[index].utxo.raw,
      headerBuilder: (context) => const [
        SailTableHeaderCell(name: 'Amount'),
        SailTableHeaderCell(name: 'Address'),
        SailTableHeaderCell(name: 'Date'),
        SailTableHeaderCell(name: '# Conf'),
      ],
      contextMenuItems: (rowId) => [
        SailMenuItem(
          child: Row(
            children: [
              SailSVG.icon(SailSVGAsset.iconSearch, width: 16),
              const SizedBox(width: 8),
              const Text('View Details'),
            ],
          ),
          onSelected: () {
            final entry = widget.entries.firstWhere((e) => e.utxo.raw == rowId);
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: PendingMeltView(tx: entry),
              ),
            );
          },
        ),
      ],
      rowBuilder: (context, row, selected) {
        final entry = widget.entries[row];
        return [
          SailTableCell(
            value: formatBitcoin(entry.utxo.amount),
          ),
          SailTableCell(value: entry.utxo.address),
          SailTableCell(value: entry.executeTime.format()),
          SailTableCell(value: entry.utxo.confirmations.toString()),
        ];
      },
      rowCount: widget.entries.length,
      columnWidths: const [100, 200, 150, 100],
      drawGrid: true,
    );
  }
}

class PendingCastsTable extends StatefulWidget {
  final List<PendingCastBill> entries;
  final Binary chain;

  const PendingCastsTable({
    super.key,
    required this.entries,
    required this.chain,
  });

  @override
  State<PendingCastsTable> createState() => _PendingCastsTableState();
}

class _PendingCastsTableState extends State<PendingCastsTable> {
  String sortColumn = 'executeTime';
  bool sortAscending = true;
  List<PendingCastBill> entries = [];

  @override
  void initState() {
    super.initState();
    entries = widget.entries;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!foundation.listEquals(entries, widget.entries)) {
      entries = List.from(widget.entries);
      sortEntries();
    }
  }

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
      sortEntries();
    });
  }

  void sortEntries() {
    entries.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'amount':
          aValue = a.castAmount;
          bValue = b.castAmount;
          break;
        case 'executeTime':
          aValue = a.executeTime.millisecondsSinceEpoch;
          bValue = b.executeTime.millisecondsSinceEpoch;
          break;
        case 'powerOf':
          aValue = a.powerOf;
          bValue = b.powerOf;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => entries[index].powerOf.toString(),
      headerBuilder: (context) => [
        SailTableHeaderCell(
          name: 'Bill Amount',
          onSort: () => onSort('amount'),
        ),
        SailTableHeaderCell(
          name: 'Broadcast Day',
          onSort: () => onSort('executeTime'),
        ),
        SailTableHeaderCell(
          name: 'Power',
          onSort: () => onSort('powerOf'),
        ),
        const SailTableHeaderCell(name: 'ETA'),
      ],
      rowBuilder: (context, row, selected) {
        final entry = entries[row];
        return [
          SailTableCell(
            value: formatBitcoin(entry.castAmount),
            monospace: true,
          ),
          SailTableCell(
            value: entry.executeTime.toLocal().format(),
            monospace: true,
          ),
          SailTableCell(
            value: entry.powerOf.toString(),
            monospace: true,
          ),
          SailTableCell(
            value: formatExecuteIn(entry.executeIn),
            monospace: true,
          ),
        ];
      },
      rowCount: entries.length,
      columnWidths: const [150, 150, 100, 100],
      drawGrid: true,
      sortColumnIndex: [
        'amount',
        'executeTime',
        'powerOf',
      ].indexOf(sortColumn),
      sortAscending: sortAscending,
      onDoubleTap: (rowId) {
        final bill = entries.firstWhere(
          (b) => b.powerOf.toString() == rowId,
        );
        _showBillDetails(context, bill);
      },
    );
  }

  void _showBillDetails(BuildContext context, PendingCastBill bill) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'Cast Bill Details',
            subtitle: 'Details of the selected cast bill',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'Amount', value: formatBitcoin(bill.castAmount)),
                  DetailRow(label: 'Execute Time', value: bill.executeTime.toLocal().format()),
                  DetailRow(label: 'Power', value: bill.powerOf.toString()),
                  DetailRow(label: 'ETA', value: formatExecuteIn(bill.executeIn)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatExecuteIn(Duration duration) {
    if (duration.inDays > 1) {
      return '${duration.inDays} days';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (duration.inDays == 1) {
      return '1 day ${hours % 24} hours';
    }

    if (hours == 0) {
      return '$minutes minutes';
    }

    return '$hours hours ${minutes > 0 ? '$minutes minutes' : ''}';
  }
}

class MeltButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MeltButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: SailStyleValues.borderRadius,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              theme.colors.orange.withValues(alpha: 0.25),
              theme.colors.orangeLight.withValues(alpha: 0.25),
            ],
          ),
          border: Border.all(
            color: theme.colors.orange,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            SailRow(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.icon(
                  SailSVGAsset.iconMelt,
                  color: theme.colors.text,
                  height: 24,
                ),
                SailText.primary24('Melt', bold: true),
              ],
            ),
            SailText.secondary13(
              'Click here to Melt ALL of your transparent Coins',
              color: theme.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class CastButton extends StatelessWidget {
  final Future<void> Function() onPressed;

  const CastButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: SailStyleValues.borderRadius,
          color: theme.colors.backgroundSecondary,
          border: Border.all(
            color: theme.colors.orange,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            SailRow(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.icon(
                  SailSVGAsset.iconCast,
                  color: theme.colors.text,
                  height: 24,
                ),
                SailText.primary24('Cast', bold: true),
              ],
            ),
            SailText.secondary13(
              'Click here to Cast 95-100% of your z-value as 4 new Coins',
              color: theme.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class UTXOsTable extends StatefulWidget {
  final List<dynamic> entries;
  final bool hideDust;
  final Function(BuildContext, UnshieldedUTXO) onMeltSingle;
  final Function(BuildContext, ShieldedUTXO) onCastSingle;

  const UTXOsTable({
    super.key,
    required this.entries,
    required this.hideDust,
    required this.onMeltSingle,
    required this.onCastSingle,
  });

  @override
  State<UTXOsTable> createState() => _UTXOsTableState();
}

class _UTXOsTableState extends State<UTXOsTable> {
  String sortColumn = 'amount';
  bool sortAscending = true;
  List<dynamic> entries = [];

  @override
  void initState() {
    super.initState();
    entries = widget.entries;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!foundation.listEquals(entries, widget.entries)) {
      entries = List.from(widget.entries);
      sortEntries();
    }
  }

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
      sortEntries();
    });
  }

  void sortEntries() {
    entries.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'amount':
          aValue = a is UnshieldedUTXO ? a.amount : a.amount;
          bValue = b is UnshieldedUTXO ? b.amount : b.amount;
          break;
        case 'type':
          aValue = a is UnshieldedUTXO ? 'Unshielded' : 'Shielded';
          bValue = b is UnshieldedUTXO ? 'Unshielded' : 'Shielded';
          break;
        case 'confirmations':
          aValue = a is UnshieldedUTXO ? a.confirmations : a.confirmations;
          bValue = b is UnshieldedUTXO ? b.confirmations : b.confirmations;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final container = GetIt.I.get<SidechainContainer>();

    return SailTable(
      getRowId: (index) => entries[index] is UnshieldedUTXO
          ? (entries[index] as UnshieldedUTXO).address
          : (entries[index] as ShieldedUTXO).txid,
      headerBuilder: (context) => [
        SailTableHeaderCell(
          name: 'Amount',
          onSort: () => onSort('amount'),
        ),
        SailTableHeaderCell(
          name: 'Status',
          onSort: () => onSort('type'),
        ),
        SailTableHeaderCell(
          name: 'Confirmations',
          onSort: () => onSort('confirmations'),
        ),
        const SailTableHeaderCell(name: 'Actions'),
      ],
      rowBuilder: (context, row, selected) {
        final entry = entries[row];
        final isUnshielded = entry is UnshieldedUTXO;
        final amount = isUnshielded ? entry.amount : entry.amount;
        final confirmations = isUnshielded ? entry.confirmations : entry.confirmations;
        final isSafeAmount = isCastAmount(amount);
        final color = getCastColor(amount);

        return [
          SailTableCell(
            value: formatBitcoin(amount, symbol: container.rpc.chain.ticker),
            child: Tooltip(
              message: isUnshielded
                  ? (isSafeAmount ? 'Melted, safe UTXO' : 'Not melted, unsafe amount')
                  : (isSafeAmount ? 'Casted, safe UTXO' : 'Not casted, unsafe UTXO'),
              child: SailText.primary13(
                formatBitcoin(amount, symbol: container.rpc.chain.ticker),
                color: color,
                monospace: true,
              ),
            ),
          ),
          SailTableCell(
            value: isUnshielded ? 'Unshielded' : 'Shielded',
            child: Row(
              children: [
                SailText.primary13(
                  isUnshielded ? 'Unshielded' : 'Shielded',
                  monospace: true,
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: isUnshielded
                      ? (isSafeAmount ? 'Melted' : 'Not melted')
                      : (isSafeAmount ? 'Casted' : 'Not casted'),
                  child: SailSVG.icon(
                    isSafeAmount ? SailSVGAsset.iconSuccess : SailSVGAsset.iconWarning,
                    width: 13,
                  ),
                ),
              ],
            ),
          ),
          SailTableCell(
            value: confirmations.toString(),
            child: Row(
              children: [
                SailText.primary13(
                  confirmations.toString(),
                  monospace: true,
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: confirmations >= 1 ? '$confirmations confirmations' : 'Unconfirmed',
                  child: SailSVG.icon(
                    confirmations >= 1 ? SailSVGAsset.iconSuccess : SailSVGAsset.iconPending,
                    width: 13,
                  ),
                ),
              ],
            ),
          ),
          SailTableCell(
            value: '',
            child: SailButton(
              variant: ButtonVariant.secondary,
              label: isUnshielded ? 'Melt' : 'Cast',
              onPressed: () async {
                if (isUnshielded) {
                  await widget.onMeltSingle(context, entry);
                } else {
                  await widget.onCastSingle(context, entry);
                }
              },
              disabled: amount <= zcashFee,
            ),
          ),
        ];
      },
      rowCount: entries.length,
      columnWidths: const [150, 100, 120, 100],
      drawGrid: true,
      sortColumnIndex: [
        'amount',
        'type',
        'confirmations',
      ].indexOf(sortColumn),
      sortAscending: sortAscending,
      onDoubleTap: (rowId) {
        final utxo = entries.firstWhere(
          (u) => (u is UnshieldedUTXO ? u.address : u.txid) == rowId,
        );
        _showUTXODetails(context, utxo);
      },
    );
  }

  void _showUTXODetails(BuildContext context, dynamic utxo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'UTXO Details',
            subtitle: 'Details of the selected UTXO',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(
                    label: 'Amount',
                    value: formatBitcoin(
                      utxo.amount,
                      symbol: GetIt.I.get<SidechainContainer>().rpc.chain.ticker,
                    ),
                  ),
                  DetailRow(
                    label: 'Type',
                    value: utxo is UnshieldedUTXO ? 'Unshielded' : 'Shielded',
                  ),
                  DetailRow(
                    label: utxo is UnshieldedUTXO ? 'Address' : 'TxID',
                    value: utxo is UnshieldedUTXO ? utxo.address : utxo.txid,
                  ),
                  DetailRow(
                    label: 'Confirmations',
                    value: utxo.confirmations.toString(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OperationsTable extends StatefulWidget {
  final List<OperationStatus> entries;
  final VoidCallback onClear;

  const OperationsTable({
    super.key,
    required this.entries,
    required this.onClear,
  });

  @override
  State<OperationsTable> createState() => _OperationsTableState();
}

class _OperationsTableState extends State<OperationsTable> {
  String sortColumn = 'date';
  bool sortAscending = false; // Default newest first
  List<OperationStatus> entries = [];

  @override
  void initState() {
    super.initState();
    entries = widget.entries;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!foundation.listEquals(entries, widget.entries)) {
      entries = List.from(widget.entries);
      sortEntries();
    }
  }

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
      sortEntries();
    });
  }

  void sortEntries() {
    entries.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'date':
          aValue = a.creationTime.millisecondsSinceEpoch;
          bValue = b.creationTime.millisecondsSinceEpoch;
          break;
        case 'method':
          aValue = a.method;
          bValue = b.method;
          break;
        case 'status':
          aValue = a.status;
          bValue = b.status;
          break;
        case 'id':
          aValue = a.id;
          bValue = b.id;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Operation statuses',
      subtitle: 'List of zero-knowledge operations and their status',
      bottomPadding: false,
      widgetHeaderEnd: SailRow(
        spacing: SailStyleValues.padding12,
        children: [
          SailButton(
            label: 'Clear',
            variant: ButtonVariant.ghost,
            onPressed: () async {
              widget.onClear();
            },
          ),
          HelpButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const Dialog(
                  child: OperationHelp(),
                ),
              );
            },
          ),
        ],
      ),
      child: SailTable(
        getRowId: (index) => entries[index].id,
        headerBuilder: (context) => [
          SailTableHeaderCell(
            name: 'Date',
            onSort: () => onSort('date'),
          ),
          SailTableHeaderCell(
            name: 'Method',
            onSort: () => onSort('method'),
          ),
          SailTableHeaderCell(
            name: 'Status',
            onSort: () => onSort('status'),
          ),
          SailTableHeaderCell(
            name: 'Operation ID',
            onSort: () => onSort('id'),
          ),
        ],
        rowBuilder: (context, row, selected) {
          final entry = entries[row];

          return [
            SailTableCell(
              value: DateFormat('dd MMM HH:mm:ss').format(entry.creationTime),
              monospace: true,
            ),
            SailTableCell(
              value: entry.method,
              monospace: true,
            ),
            SailTableCell(
              value: entry.status,
              textColor: entry.status == 'success' ? SailColorScheme.green : SailColorScheme.red,
              monospace: true,
              child: entry.status == 'success'
                  ? Tooltip(
                      message: 'Success',
                      child: SailSVG.icon(SailSVGAsset.iconSuccess, width: 13),
                    )
                  : Tooltip(
                      message: 'Failed',
                      child: SailSVG.icon(SailSVGAsset.iconFailed, width: 13),
                    ),
            ),
            SailTableCell(
              value: entry.id,
              monospace: true,
            ),
          ];
        },
        rowCount: entries.length,
        columnWidths: const [150, 100, 100, 200],
        drawGrid: true,
        sortColumnIndex: [
          'date',
          'method',
          'status',
          'id',
        ].indexOf(sortColumn),
        sortAscending: sortAscending,
        onDoubleTap: (rowId) {
          final operation = entries.firstWhere((op) => op.id == rowId);
          _showOperationDetails(context, operation);
        },
      ),
    );
  }

  void _showOperationDetails(BuildContext context, OperationStatus operation) {
    final decodedTX = jsonDecode(operation.raw);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'Operation Details',
            subtitle: 'Details of the selected operation',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'Operation ID', value: operation.id),
                  DetailRow(label: 'Method', value: operation.method),
                  DetailRow(label: 'Status', value: operation.status),
                  DetailRow(
                    label: 'Creation Time',
                    value: DateFormat('dd MMM HH:mm:ss').format(operation.creationTime),
                  ),
                  DetailRow(label: 'Raw Data', value: const JsonEncoder.withIndent('  ').convert(decodedTX)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PendingMeltView extends StatelessWidget {
  final PendingShield tx;

  const PendingMeltView({
    super.key,
    required this.tx,
  });

  @override
  Widget build(BuildContext context) {
    final container = GetIt.I.get<SidechainContainer>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SailCard(
          title: 'Pending Melt Details',
          subtitle: 'Details of the selected pending melt',
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(
                  label: 'Amount',
                  value: formatBitcoin(tx.utxo.amount, symbol: container.rpc.chain.ticker),
                ),
                DetailRow(
                  label: 'From Address',
                  value: tx.utxo.address,
                ),
                DetailRow(
                  label: 'Execute Time',
                  value: tx.executeTime.format(),
                ),
                DetailRow(
                  label: 'Confirmations',
                  value: tx.utxo.confirmations.toString(),
                ),
                DetailRow(
                  label: 'Raw Transaction',
                  value: tx.utxo.raw,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
