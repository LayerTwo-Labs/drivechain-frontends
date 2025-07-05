import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/pages/tabs/home_page.dart';
import 'package:zside/pages/tabs/sidechain_overview_page.dart';
import 'package:zside/providers/transactions_provider.dart';
import 'package:zside/providers/zside_provider.dart';
import 'package:zside/routing/router.dart';
import 'package:zside/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:zside/widgets/containers/tabs/zside_tab_widgets.dart';

@RoutePage()
class ZSideTransferTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZSideTransferTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZSideTransferTabViewModel(),
      builder: ((context, model, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return SailPage(
          scrollable: true,
          widgetTitle: ZSideWidgetTitle(
            depositNudgeAction: () => tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding32),
            child: SailColumn(
              spacing: SailStyleValues.padding32,
              children: [
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
                            title: 'Transparent coins',
                            children: [
                              ActionTile(
                                title: 'Send transparent coins',
                                category: Category.sidechain,
                                icon: SailSVGAsset.iconArrowForward,
                                onTap: () async {
                                  model.sendTransparent(context);
                                },
                              ),
                              ActionTile(
                                title: 'Receive transparent coins',
                                category: Category.sidechain,
                                icon: SailSVGAsset.iconArrow,
                                onTap: () async {
                                  model.receiveTransparent(context);
                                },
                              ),
                            ],
                          ),
                          DashboardGroup(
                            title: 'Transparent UTXOs',
                            children: [
                              TransparentUTXOTable(
                                entries: model.transparentUTXOs,
                                searchWidget: LargeEmbeddedInput(
                                  controller: model.searchController,
                                  hintText: 'Search UTXOs...',
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
                            title: 'Private coins',
                            children: [
                              ActionTile(
                                title: 'Send private coins',
                                category: Category.sidechain,
                                icon: SailSVGAsset.iconArrowForward,
                                onTap: () async {
                                  await model.sendPrivate(context);
                                },
                              ),
                              ActionTile(
                                title: 'Receive private coins',
                                category: Category.sidechain,
                                icon: SailSVGAsset.iconArrow,
                                onTap: () async {
                                  model.receivePrivate(context);
                                },
                              ),
                            ],
                          ),
                          DashboardGroup(
                            title: 'Private UTXOs',
                            children: [
                              PrivateUTXOTable(
                                entries: model.shieldedUTXOs,
                                searchWidget: LargeEmbeddedInput(
                                  controller: model.privateSearchController,
                                  hintText: 'Search UTXOs...',
                                ),
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

class ZSideTransferTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  ZSideProvider get _zsideProvider => GetIt.I.get<ZSideProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();

  String get zsideAddress => _zsideProvider.zsideAddress;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController privateSearchController = TextEditingController();

  List<UnshieldedUTXO> get transparentUTXOs => _zsideProvider.unshieldedUTXOs
      .where(
        (utxo) =>
            (!hideDust || utxo.amount > zsideFee) &&
            (searchController.text.isEmpty ||
                utxo.txid.contains(searchController.text) ||
                utxo.address.contains(searchController.text)),
      )
      .toList();
  List<ShieldedUTXO> get shieldedUTXOs => _zsideProvider.shieldedUTXOs
      .where(
        (utxo) => privateSearchController.text.isEmpty || utxo.txid.contains(privateSearchController.text),
      )
      .toList();

  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool hideDust = false;

  void setHideDust(bool to) {
    hideDust = to;
    notifyListeners();
  }

  ZSideTransferTabViewModel() {
    searchController.addListener(notifyListeners);
    privateSearchController.addListener(notifyListeners);
    _zsideProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
    _transactionsProvider.addListener(notifyListeners);
  }

  Future<void> sendPrivate(BuildContext context) async {
    final privateBalance = shieldedUTXOs.fold(0.0, (sum, elem) => sum + elem.amount);

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return SendOnSidechainAction(
          maxAmount: max(privateBalance - _zsideProvider.sideFee, 0),
        );
      },
    );
  }

  void receivePrivate(BuildContext context) async {
    final provider = GetIt.I.get<ZSideProvider>();

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return ReceiveAction(
          customTitle: 'Receive private coins',
          customReceiveAction: () => provider.rpc.getNewShieldedAddress(),
          initialAddress: provider.zsideAddress,
        );
      },
    );
  }

  void sendTransparent(BuildContext context) async {
    final transparentBalance = transparentUTXOs.fold(0.0, (sum, elem) => sum + elem.amount);

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return SendOnSidechainAction(
          maxAmount: transparentBalance,
          customSendAction: (address, amount) async {
            return await _zsideProvider.rpc.sendTransparent(
              address,
              amount,
              zsideFee,
            );
          },
        );
      },
    );
  }

  void receiveTransparent(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return ReceiveAction(
          customReceiveAction: () async {
            return await _zsideProvider.rpc.getSideAddress();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.removeListener(notifyListeners);
    privateSearchController.removeListener(notifyListeners);
    super.dispose();
    _zsideProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
    _transactionsProvider.removeListener(notifyListeners);
  }
}

class ZSideWidgetTitle extends StatelessWidget {
  final VoidCallback depositNudgeAction;

  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZSideWidgetTitle({
    super.key,
    required this.depositNudgeAction,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => ZSideWidgetTitleViewModel(),
      builder: ((context, model, child) {
        if (model.balance != 0) {
          return SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.secondary13('Your ZSide-address: ${model.zsideAddress}'),
              Expanded(child: Container()),
            ],
          );
        }

        return SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailButton(
              label: 'Deposit coins',
              variant: ButtonVariant.primary,
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
              loading: model.isBusy,
            ),
            SailText.secondary12(
              'To get started, you must deposit coins to your sidechain. Deposit on the Parent Chain tab',
            ),
            Expanded(child: Container()),
          ],
        );
      }),
    );
  }
}

class ZSideWidgetTitleViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  ZSideProvider get _zsideProvider => GetIt.I.get<ZSideProvider>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  String get zsideAddress => _zsideProvider.zsideAddress;
  double get balance => _balanceProvider.balance + _balanceProvider.pendingBalance;

  bool showAll = false;

  ZSideWidgetTitleViewModel() {
    _zsideProvider.addListener(notifyListeners);
    _balanceProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _zsideProvider.removeListener(notifyListeners);
    _balanceProvider.removeListener(notifyListeners);
  }
}

class TransparentUTXOTable extends StatefulWidget {
  final List<UnshieldedUTXO> entries;
  final Widget searchWidget;

  const TransparentUTXOTable({
    super.key,
    required this.entries,
    required this.searchWidget,
  });

  @override
  State<TransparentUTXOTable> createState() => _TransparentUTXOTableState();
}

class _TransparentUTXOTableState extends State<TransparentUTXOTable> {
  String sortColumn = 'amount';
  bool sortAscending = true;
  List<UnshieldedUTXO> entries = [];

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
        case 'confirmations':
          aValue = a.confirmations;
          bValue = b.confirmations;
          break;
        case 'amount':
          aValue = a.amount;
          bValue = b.amount;
          break;
        case 'address':
          aValue = a.address;
          bValue = b.address;
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SailCard(
          title: 'Transparent UTXOs',
          subtitle: 'List of unspent transaction outputs in your transparent address',
          bottomPadding: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SailStyleValues.padding16,
                ),
                child: widget.searchWidget,
              ),
              Expanded(
                child: SailTable(
                  getRowId: (index) => widget.entries[index].txid,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(
                      name: 'Confirmations',
                      onSort: () => onSort('confirmations'),
                    ),
                    SailTableHeaderCell(
                      name: 'Amount',
                      onSort: () => onSort('amount'),
                    ),
                    SailTableHeaderCell(
                      name: 'Address',
                      onSort: () => onSort('address'),
                    ),
                    SailTableHeaderCell(
                      name: 'TxID',
                      onSort: () => onSort('txid'),
                    ),
                  ],
                  rowBuilder: (context, row, selected) {
                    final entry = widget.entries[row];
                    return [
                      SailTableCell(
                        value: entry.confirmations.toString(),
                      ),
                      SailTableCell(
                        value: formatBitcoin(entry.amount),
                        monospace: true,
                      ),
                      SailTableCell(
                        value: entry.address,
                      ),
                      SailTableCell(
                        value: entry.txid.substring(0, 6),
                        copyValue: entry.txid,
                      ),
                    ];
                  },
                  rowCount: widget.entries.length,
                  drawGrid: true,
                  sortColumnIndex: [
                    'confirmations',
                    'amount',
                    'address',
                    'txid',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['confirmations', 'amount', 'address', 'txid'][columnIndex]);
                  },
                  onDoubleTap: (rowId) {
                    final utxo = widget.entries.firstWhere(
                      (u) => u.txid == rowId,
                    );
                    _showUtxoDetails(context, utxo);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUtxoDetails(BuildContext context, UnshieldedUTXO utxo) {
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
                  DetailRow(label: 'TxID', value: utxo.txid),
                  DetailRow(label: 'Amount', value: formatBitcoin(utxo.amount)),
                  DetailRow(label: 'Address', value: utxo.address),
                  DetailRow(label: 'Confirmations', value: utxo.confirmations.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrivateUTXOTable extends StatefulWidget {
  final List<ShieldedUTXO> entries;
  final Widget searchWidget;

  const PrivateUTXOTable({
    super.key,
    required this.entries,
    required this.searchWidget,
  });

  @override
  State<PrivateUTXOTable> createState() => _PrivateUTXOTableState();
}

class _PrivateUTXOTableState extends State<PrivateUTXOTable> {
  String sortColumn = 'amount';
  bool sortAscending = true;
  List<ShieldedUTXO> entries = [];

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
        case 'confirmations':
          aValue = a.confirmations;
          bValue = b.confirmations;
          break;
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SailCard(
          title: 'Private UTXOs',
          subtitle: 'List of unspent transaction outputs in your private address',
          bottomPadding: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SailStyleValues.padding16,
                ),
                child: widget.searchWidget,
              ),
              Expanded(
                child: SailTable(
                  getRowId: (index) => widget.entries[index].txid,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(
                      name: 'Confirmations',
                      onSort: () => onSort('confirmations'),
                    ),
                    SailTableHeaderCell(
                      name: 'Amount',
                      onSort: () => onSort('amount'),
                    ),
                    SailTableHeaderCell(
                      name: 'TxID',
                      onSort: () => onSort('txid'),
                    ),
                  ],
                  rowBuilder: (context, row, selected) {
                    final entry = widget.entries[row];
                    return [
                      SailTableCell(
                        value: entry.confirmations.toString(),
                      ),
                      SailTableCell(
                        value: formatBitcoin(entry.amount),
                        monospace: true,
                        textColor: getCastColor(entry.amount),
                      ),
                      SailTableCell(
                        value: entry.txid.substring(0, 6),
                        copyValue: entry.txid,
                      ),
                    ];
                  },
                  rowCount: widget.entries.length,
                  drawGrid: true,
                  sortColumnIndex: [
                    'confirmations',
                    'amount',
                    'txid',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['confirmations', 'amount', 'txid'][columnIndex]);
                  },
                  onDoubleTap: (rowId) {
                    final utxo = widget.entries.firstWhere(
                      (u) => u.txid == rowId,
                    );
                    _showUtxoDetails(context, utxo);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUtxoDetails(BuildContext context, ShieldedUTXO utxo) {
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
                  DetailRow(label: 'TxID', value: utxo.txid),
                  DetailRow(label: 'Amount', value: formatBitcoin(utxo.amount)),
                  DetailRow(label: 'Confirmations', value: utxo.confirmations.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
