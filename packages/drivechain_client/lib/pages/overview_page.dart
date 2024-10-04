import 'package:auto_route/auto_route.dart';
import 'package:drivechain_client/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:drivechain_client/providers/balance_provider.dart';
import 'package:drivechain_client/providers/blockchain_provider.dart';
import 'package:drivechain_client/widgets/error_container.dart';
import 'package:drivechain_client/widgets/qt_container.dart';
import 'package:drivechain_client/widgets/qt_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money2/money2.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/containers/qt_page.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const QtPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExperimentalBanner(),
          SizedBox(height: SailStyleValues.padding15),
          BalancesView(),
          SizedBox(height: SailStyleValues.padding15),
          TransactionsView(),
        ],
      ),
    );
  }
}

class ExperimentalBanner extends StatelessWidget {
  const ExperimentalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: SailTheme.of(context).colors.orangeLight.withOpacity(0.8),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(4.0),
      child: SailText.primary12(
        'This is experimental sidechain software. Use at your own risk!',
        bold: true,
      ),
    );
  }
}

class BalancesView extends StatelessWidget {
  const BalancesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BalancesViewModel(),
      builder: (context, model, child) {
        if (model.hasErrorForKey('balance')) {
          return ErrorContainer(
            error: model.error('balance').toString(),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SailText.primary13(
                      'Balances',
                      bold: true,
                    ),
                    const SizedBox(height: SailStyleValues.padding15),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.primary13('Available: '),
                          SailText.primary13(
                            formatBitcoin(
                              satoshiToBTC(model.confirmedBalance),
                            ),
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SailStyleValues.padding15),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.primary13('Pending: '),
                          SailText.primary13(
                            formatBitcoin(
                              satoshiToBTC(model.pendingBalance),
                            ),
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const QtSeparator(width: 150),
                    const SizedBox(height: 24.0),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SailText.primary13('Total: '),
                          SailText.primary13(
                            formatBitcoin(
                              satoshiToBTC(
                                model.totalBalance,
                              ),
                            ),
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BitcoinPrice(
                      money: Money.fromNumWithCurrency(
                        50000,
                        CommonCurrencies().usd,
                      ),
                    ),
                    const SizedBox(height: SailStyleValues.padding15),
                    // Sum of all balances converted to USD at current BTC price
                    SailText.primary13(
                      Money.fromNumWithCurrency(
                        model.totalBalanceUSD,
                        CommonCurrencies().usd,
                      ).format('S###,###.##'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BalancesViewModel>.reactive(
      viewModelBuilder: () => BalancesViewModel(),
      builder: (context, model, child) {
        if (model.hasErrorForKey('blockchain')) {
          return ErrorContainer(
            error: model.error('blockchain').toString(),
          );
        }
        return Expanded(
          child: QtContainer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary13('Latest transactions:'),
                      const SailSpacing(SailStyleValues.padding08),
                      QtContainer(
                        tight: true,
                        child: SizedBox(
                          height: 300,
                          child: LatestTransactionTable(
                            entries: model.unconfirmedTransactions,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SailStyleValues.padding15), // Add some space between the two tables
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary13('Latest blocks:'),
                      const SailSpacing(SailStyleValues.padding08),
                      QtContainer(
                        tight: true,
                        child: SizedBox(
                          height: 300,
                          child: LatestBlocksTable(
                            blocks: model.recentBlocks,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BalancesViewModel extends BaseViewModel {
  final BlockchainProvider blockchainProvider = GetIt.I.get<BlockchainProvider>();
  final BalanceProvider balanceProvider = GetIt.I.get<BalanceProvider>();

  BalancesViewModel() {
    balanceProvider.addListener(notifyListeners);
    blockchainProvider.addListener(notifyListeners);
  }

  void errorListener() {
    if (balanceProvider.error != null) {
      setErrorForObject('balance', balanceProvider.error);
    }
    if (blockchainProvider.error != null) {
      setErrorForObject('blockchain', blockchainProvider.error);
    }
  }

  int get confirmedBalance => balanceProvider.balance;
  int get pendingBalance => balanceProvider.pendingBalance;
  int get totalBalance => balanceProvider.balance + balanceProvider.pendingBalance;
  double get totalBalanceUSD => (satoshiToBTC(totalBalance) * 50000);

  List<ListRecentBlocksResponse_RecentBlock> get recentBlocks => blockchainProvider.recentBlocks;
  List<UnconfirmedTransaction> get unconfirmedTransactions => blockchainProvider.unconfirmedTXs;
}

class QtSeparator extends StatelessWidget {
  final double width;

  const QtSeparator({
    super.key,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
      ),
      child: Container(
        height: 1.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.35, 0.36, 1.0],
            colors: [
              Colors.grey,
              Colors.grey.withOpacity(0.3),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
      ),
    );
  }
}

class BitcoinPrice extends StatelessWidget {
  final Money money;

  const BitcoinPrice({super.key, required this.money});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SailText.primary13(
          '${money.format('S###,###.##')}/BTC',
        ),
        const SizedBox(width: 8.0),
        QtIconButton(
          onPressed: () {
            showSnackBar(context, 'Not implemented');
          },
          icon: Icon(Icons.settings),
        ),
      ],
    );
  }
}

class LatestTransactionTable extends StatefulWidget {
  final List<UnconfirmedTransaction> entries;

  const LatestTransactionTable({
    super.key,
    required this.entries,
  });

  @override
  State<LatestTransactionTable> createState() => _LatestTransactionTableState();
}

class _LatestTransactionTableState extends State<LatestTransactionTable> {
  String sortColumn = 'time';
  bool sortAscending = true;
  List<UnconfirmedTransaction> entries = [];

  @override
  void initState() {
    super.initState();
    entries = widget.entries;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!listEquals(entries, widget.entries)) {
      entries = widget.entries;
      onSort(sortColumn);
    }
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
    entries.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (sortColumn) {
        case 'time':
          aValue = a.time.toDateTime().millisecondsSinceEpoch;
          bValue = b.time.toDateTime().millisecondsSinceEpoch;
          break;
        case 'fee':
          aValue = a.feeSatoshi;
          bValue = b.feeSatoshi;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'size':
          aValue = a.virtualSize;
          bValue = b.virtualSize;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => entries[index].txid,
      headerBuilder: (context) => [
        SailTableHeaderCell(
          child: SailText.primary12('Time'),
          onSort: () => onSort('time'),
        ),
        SailTableHeaderCell(
          child: SailText.primary12('sat/vB'),
          onSort: () => onSort('fee'),
        ),
        SailTableHeaderCell(
          child: SailText.primary12('TxID'),
          onSort: () => onSort('txid'),
        ),
        SailTableHeaderCell(
          child: SailText.primary12('Size'),
          onSort: () => onSort('size'),
        ),
      ],
      rowBuilder: (context, row, selected) {
        final entry = entries[row];
        return [
          SailTableCell(child: SailText.primary12(entry.time.toDateTime().format())),
          SailTableCell(child: SailText.primary12(entry.feeSatoshi.toString())),
          SailTableCell(child: SailText.primary12(entry.txid)),
          SailTableCell(child: SailText.primary12(entry.virtualSize.toString())),
        ];
      },
      rowCount: entries.length,
      columnCount: 4,
      columnWidths: const [150, 100, 200, 100],
      headerDecoration: BoxDecoration(
        color: context.sailTheme.colors.formFieldBorder,
      ),
      drawGrid: true,
      sortColumnIndex: ['time', 'fee', 'txid', 'size'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['time', 'fee', 'txid', 'size'][columnIndex]);
      },
    );
  }
}

class LatestBlocksTable extends StatefulWidget {
  final List<ListRecentBlocksResponse_RecentBlock> blocks;

  const LatestBlocksTable({
    super.key,
    required this.blocks,
  });

  @override
  State<LatestBlocksTable> createState() => _LatestBlocksTableState();
}

class _LatestBlocksTableState extends State<LatestBlocksTable> {
  String sortColumn = 'time';
  bool sortAscending = true;
  List<ListRecentBlocksResponse_RecentBlock> blocks = [];

  @override
  void initState() {
    super.initState();
    blocks = widget.blocks;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!listEquals(blocks, widget.blocks)) {
      blocks = widget.blocks;
      onSort(sortColumn);
    }
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
    blocks.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (sortColumn) {
        case 'time':
          aValue = a.blockTime.toDateTime().millisecondsSinceEpoch;
          bValue = b.blockTime.toDateTime().millisecondsSinceEpoch;
          break;
        case 'height':
          aValue = a.blockHeight;
          bValue = b.blockHeight;
          break;
        case 'hash':
          aValue = a.hash;
          bValue = b.hash;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => blocks[index].hash,
      headerBuilder: (context) => [
        SailTableHeaderCell(child: SailText.primary12('Time')),
        SailTableHeaderCell(child: SailText.primary12('Height')),
        SailTableHeaderCell(child: SailText.primary12('Hash')),
      ],
      rowBuilder: (context, row, selected) {
        final entry = blocks[row];
        return [
          SailTableCell(child: SailText.primary12(entry.blockTime.toDateTime().format())),
          SailTableCell(child: SailText.primary12(entry.blockHeight.toString())),
          SailTableCell(child: SailText.primary12(entry.hash)),
        ];
      },
      rowCount: blocks.length,
      columnCount: 3,
      columnWidths: const [150, 100, 200],
      headerDecoration: BoxDecoration(
        color: context.sailTheme.colors.formFieldBorder,
      ),
      drawGrid: true,
      sortColumnIndex: ['time', 'height', 'hash'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['time', 'height', 'hash'][columnIndex]);
      },
    );
  }
}
