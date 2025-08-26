import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/providers/zside_provider.dart';
import 'package:zside/routing/router.dart';
import 'package:zside/widgets/containers/tabs/zside_tab_widgets.dart';

@RoutePage()
class ZSideShieldDeshieldTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZSideShieldDeshieldTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZSideShieldTabViewModel(),
      builder: ((context, model, child) {
        return QtPage(
          child: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding32),
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailCard(
                            bottomPadding: false,
                            title: 'Transparent UTXOs ${model.unshieldedUTXOs.length}',
                            subtitle: 'View and shield your transparent UTXOs',
                            widgetHeaderEnd: SailToggle(
                              label: 'Hide dust UTXOs',
                              value: model.hideDust,
                              onChanged: (to) => model.setShowAll(to),
                            ),
                            child: SizedBox(
                              height: 300,
                              child: UnshieldedUTXOTable(
                                entries: model.unshieldedUTXOs,
                                onShield: (utxo) => model.shield(context, utxo),
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
                          SailCard(
                            title: 'Private UTXOs ${model.shieldedUTXOs.length}',
                            subtitle: 'View and deshield your private UTXOs',
                            bottomPadding: false,
                            child: SizedBox(
                              height: 300,
                              child: ShieldedUTXOTable(
                                entries: model.shieldedUTXOs,
                                onDeshield: (utxo) => model.deshield(context, utxo),
                              ),
                            ),
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

class ZSideShieldTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  ZSideProvider get _zsideProvider => GetIt.I.get<ZSideProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  String get zsideAddress => _zsideProvider.zsideAddress;
  List<UnshieldedUTXO> get unshieldedUTXOs =>
      _zsideProvider.unshieldedUTXOs.where((u) => !hideDust || u.amount > zsideFee).toList();
  List<ShieldedUTXO> get shieldedUTXOs => _zsideProvider.shieldedUTXOs;

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool hideDust = false;

  void setShowAll(bool to) {
    hideDust = to;
    notifyListeners();
  }

  ZSideShieldTabViewModel() {
    _zsideProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
  }

  void melt(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const MeltAction(doEverythingMode: false);
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
    _zsideProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
  }
}

class UnshieldedUTXOTable extends StatefulWidget {
  final List<UnshieldedUTXO> entries;
  final Function(UnshieldedUTXO) onShield;

  const UnshieldedUTXOTable({super.key, required this.entries, required this.onShield});

  @override
  State<UnshieldedUTXOTable> createState() => _UnshieldedUTXOTableState();
}

class _UnshieldedUTXOTableState extends State<UnshieldedUTXOTable> {
  String sortColumn = 'amount';
  bool sortAscending = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onSort(sortColumn);
  }

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortEntries();
    setState(() {});
  }

  void sortEntries() {
    widget.entries.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (sortColumn) {
        case 'amount':
          aValue = a.amount;
          bValue = b.amount;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => widget.entries[index].txid,
      headerBuilder: (context) => [
        const SailTableHeaderCell(name: 'Actions'),
        SailTableHeaderCell(name: 'Amount', onSort: () => onSort('amount')),
        SailTableHeaderCell(name: 'TxID', onSort: () => onSort('txid')),
      ],
      rowBuilder: (context, row, selected) {
        final entry = widget.entries[row];
        return [
          SailTableCell(
            value: '',
            child: SailButton(
              label: 'Shield',
              variant: ButtonVariant.secondary,
              padding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
              onPressed: () => widget.onShield(entry),
            ),
          ),
          SailTableCell(value: formatBitcoin(entry.amount)),
          SailTableCell(value: entry.txid),
        ];
      },
      rowCount: widget.entries.length,
      drawGrid: true,
    );
  }
}

class ShieldedUTXOTable extends StatefulWidget {
  final List<ShieldedUTXO> entries;
  final Function(ShieldedUTXO) onDeshield;

  const ShieldedUTXOTable({super.key, required this.entries, required this.onDeshield});

  @override
  State<ShieldedUTXOTable> createState() => _ShieldedUTXOTableState();
}

class _ShieldedUTXOTableState extends State<ShieldedUTXOTable> {
  String sortColumn = 'amount';
  bool sortAscending = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    onSort(sortColumn);
  }

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortEntries();
    setState(() {});
  }

  void sortEntries() {
    widget.entries.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (sortColumn) {
        case 'amount':
          aValue = a.amount;
          bValue = b.amount;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => widget.entries[index].txid,
      headerBuilder: (context) => [
        const SailTableHeaderCell(name: 'Actions'),
        SailTableHeaderCell(name: 'Amount', onSort: () => onSort('amount')),
        SailTableHeaderCell(name: 'TxID', onSort: () => onSort('txid')),
      ],
      rowBuilder: (context, row, selected) {
        final entry = widget.entries[row];
        return [
          SailTableCell(
            value: '',
            child: SailButton(
              label: 'Deshield',
              variant: ButtonVariant.secondary,
              padding: const EdgeInsets.only(left: 12, right: 12, top: 2, bottom: 2),
              onPressed: () => widget.onDeshield(entry),
            ),
          ),
          SailTableCell(value: formatBitcoin(entry.amount)),
          SailTableCell(value: entry.txid),
        ];
      },
      rowCount: widget.entries.length,
      drawGrid: true,
    );
  }
}
