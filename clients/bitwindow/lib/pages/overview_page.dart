import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/gen/bitcoind/v1/bitcoind.pbgrpc.dart';
import 'package:bitwindow/gen/misc/v1/misc.pbgrpc.dart';
import 'package:bitwindow/providers/balance_provider.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/servers/api.dart';
import 'package:bitwindow/widgets/error_container.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ExperimentalBanner(),
            SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                TransactionsView(),
                CoinNewsView(),
              ],
            ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(6.0),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            SailTheme.of(context).colors.orange.withOpacity(0.25),
            SailTheme.of(context).colors.orangeLight.withOpacity(0.25),
          ],
        ),
        border: Border.all(
          color: SailTheme.of(context).colors.orange,
          width: 1.0,
        ),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailSVG.fromAsset(SailSVGAsset.iconWarning, color: SailTheme.of(context).colors.text),
          const SailSpacing(SailStyleValues.padding08),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SailText.primary15('Warning', bold: true),
                SailText.primary15(
                  'This is experimental sidechain software. Use at your own risk!',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TransactionsViewModel>.reactive(
      viewModelBuilder: () => TransactionsViewModel(),
      builder: (context, model, child) {
        if (model.hasErrorForKey('blockchain')) {
          return ErrorContainer(
            error: model.error('blockchain').toString(),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailRawCard(
                    bottomPadding: false,
                    title: 'Latest Transactions',
                    child: SizedBox(
                      height: 300,
                      child: LatestTransactionTable(
                        entries: model.recentTransactions,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SailStyleValues.padding16), // Add some space between the two tables
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailRawCard(
                    title: 'Latest blocks',
                    bottomPadding: false,
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
        );
      },
    );
  }
}

class TransactionsViewModel extends BaseViewModel {
  final BlockchainProvider blockchainProvider = GetIt.I.get<BlockchainProvider>();
  final BalanceProvider balanceProvider = GetIt.I.get<BalanceProvider>();
  TransactionsViewModel() {
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

  List<Block> get recentBlocks => blockchainProvider.recentBlocks;
  List<RecentTransaction> get recentTransactions => blockchainProvider.recentTransactions;
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

class LatestTransactionTable extends StatefulWidget {
  final List<RecentTransaction> entries;

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

  @override
  void initState() {
    super.initState();
  }

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
      getRowId: (index) => widget.entries[index].txid,
      headerBuilder: (context) => [
        SailTableHeaderCell(
          name: 'Time',
          onSort: () => onSort('time'),
        ),
        SailTableHeaderCell(
          name: 'Fee',
          onSort: () => onSort('fee'),
        ),
        SailTableHeaderCell(
          name: 'TxID',
          onSort: () => onSort('txid'),
        ),
        SailTableHeaderCell(
          name: 'Size',
          onSort: () => onSort('size'),
        ),
        SailTableHeaderCell(
          name: 'Height',
          onSort: () => onSort('block'),
        ),
      ],
      rowBuilder: (context, row, selected) {
        final entry = widget.entries[row];
        return [
          SailTableCell(value: entry.time.toDateTime().format()),
          SailTableCell(value: entry.feeSatoshi.toString()),
          SailTableCell(value: entry.txid),
          SailTableCell(value: entry.virtualSize.toString()),
          SailTableCell(value: entry.confirmedInBlock.blockHeight.toString()),
        ];
      },
      rowCount: widget.entries.length,
      columnWidths: const [150, 50, 200, 100, 70],
      drawGrid: true,
      sortColumnIndex: ['time', 'fee', 'txid', 'size', 'height'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['time', 'fee', 'txid', 'size', 'height'][columnIndex]);
      },
    );
  }
}

class LatestBlocksTable extends StatefulWidget {
  final List<Block> blocks;

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

  @override
  void initState() {
    super.initState();
  }

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
    widget.blocks.sort((a, b) {
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
      getRowId: (index) => widget.blocks[index].hash,
      headerBuilder: (context) => [
        SailTableHeaderCell(name: 'Time'),
        SailTableHeaderCell(name: 'Height'),
        SailTableHeaderCell(name: 'Block Hash'),
      ],
      rowBuilder: (context, row, selected) {
        final entry = widget.blocks[row];
        return [
          SailTableCell(value: entry.blockTime.toDateTime().format()),
          SailTableCell(value: entry.blockHeight.toString()),
          SailTableCell(value: entry.hash),
        ];
      },
      rowCount: widget.blocks.length,
      columnWidths: const [150, 100, 200],
      drawGrid: true,
      sortColumnIndex: ['time', 'height', 'hash'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['time', 'height', 'hash'][columnIndex]);
      },
    );
  }
}

class CoinNewsViewModel extends ChangeNotifier {
  String leftRegion = 'US';
  String rightRegion = 'Japan';
  final List<CoinNewsEntry> leftEntries = [];
  final List<CoinNewsEntry> rightEntries = [];

  bool _sortAscending = true;
  String _sortColumn = 'date';

  void setLeftRegion(String region) {
    leftRegion = region;
    notifyListeners();
  }

  void setRightRegion(String region) {
    rightRegion = region;
    notifyListeners();
  }

  void sortEntries(String column) {
    if (_sortColumn == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = column;
      _sortAscending = true;
    }
    notifyListeners();
  }
}

class CoinNewsView extends StatelessWidget {
  const CoinNewsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CoinNewsViewModel>.reactive(
      viewModelBuilder: () => CoinNewsViewModel(),
      builder: (context, viewModel, child) {
        return SailRawCard(
          header: Padding(
            padding: EdgeInsets.only(bottom: SailStyleValues.padding16),
            child: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailText.primary15(
                  'Coin News',
                  bold: true,
                ),
                Expanded(child: Container()),
                Opacity(
                  opacity: 0,
                  child: QtButton(
                    label: 'Broadcast News',
                    onPressed: () => displayBroadcastNewsDialog(context),
                    size: ButtonSize.small,
                  ),
                ),
                QtButton(
                  label: 'Graffitti Explorer',
                  onPressed: () => displayGraffittiExplorerDialog(context),
                  size: ButtonSize.small,
                  style: SailButtonStyle.secondary,
                ),
              ],
            ),
          ),
          child: SailRow(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: SailStyleValues.padding16,
            children: [
              Flexible(
                child: SailColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: SailStyleValues.padding16,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SailDropdownButton<String>(
                      items: [
                        SailDropdownItem(
                          value: 'US',
                          child: SailText.primary12('US Weekly'),
                        ),
                        SailDropdownItem(
                          value: 'Japan',
                          child: SailText.primary12('Japan Weekly'),
                        ),
                      ],
                      onChanged: viewModel.setLeftRegion,
                      value: viewModel.leftRegion,
                    ),
                    QtContainer(
                      child: SizedBox(
                        height: 300,
                        child: CoinNewsTable(
                          entries: viewModel.leftEntries,
                          onSort: viewModel.sortEntries,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SailDropdownButton<String>(
                      items: [
                        SailDropdownItem(
                          value: 'Japan',
                          child: SailText.primary12('Japan Weekly'),
                        ),
                        SailDropdownItem(
                          value: 'US',
                          child: SailText.primary12('US Weekly'),
                        ),
                      ],
                      onChanged: viewModel.setRightRegion,
                      value: viewModel.rightRegion,
                    ),
                    QtContainer(
                      child: SizedBox(
                        height: 300,
                        child: CoinNewsTable(
                          entries: viewModel.rightEntries,
                          onSort: viewModel.sortEntries,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> displayBroadcastNewsDialog(BuildContext context) async {
    await widgetDialog(
      context: context,
      title: 'Broadcast News',
      child: BroadcastNewsView(),
    );
  }

  Future<void> displayGraffittiExplorerDialog(BuildContext context) async {
    await widgetDialog(
      context: context,
      title: 'Graffitti Explorer',
      maxWidth: MediaQuery.of(context).size.width - 100,
      child: GraffittiExplorerView(),
    );
  }
}

class BroadcastNewsView extends StatelessWidget {
  const BroadcastNewsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BroadcastNewsViewModel>.reactive(
      viewModelBuilder: () => BroadcastNewsViewModel(),
      builder: (context, viewModel, child) {
        return SailColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          leadingSpacing: true,
          children: [
            SailDropdownButton<String>(
              items: [
                SailDropdownItem(
                  value: 'US',
                  child: SailText.primary12('US Weekly'),
                ),
                SailDropdownItem(
                  value: 'Japan',
                  child: SailText.primary12('Japan Weekly'),
                ),
              ],
              onChanged: viewModel.setRegion,
              value: viewModel.region,
            ),
            SailTextField(
              label: 'Headline (max 64 characters)',
              controller: viewModel.headlineController,
              hintText: 'Enter a headline',
              size: TextFieldSize.small,
            ),
            QtButton(
              label: 'Broadcast',
              onPressed: () => viewModel.broadcastNews(context),
              size: ButtonSize.small,
              disabled: viewModel.headlineController.text.isEmpty,
            ),
          ],
        );
      },
    );
  }
}

class BroadcastNewsViewModel extends BaseViewModel {
  String _region = 'US';
  String get region => _region;

  final TextEditingController headlineController = TextEditingController();

  BroadcastNewsViewModel() {
    headlineController.addListener(notifyListeners);
  }

  void setRegion(String newRegion) {
    _region = newRegion;
    notifyListeners();
  }

  Future<void> broadcastNews(BuildContext context) async {
    if (headlineController.text.isEmpty) {
      return;
    }

    if (headlineController.text.length > 64) {
      showSnackBar(context, 'Headline must be 64 characters or less');
      return;
    }

    showSnackBar(context, 'TODO: Actually broadcast the news');
  }

  @override
  void dispose() {
    headlineController.removeListener(notifyListeners);
    headlineController.dispose();
    super.dispose();
  }
}

class NewGraffittiView extends StatelessWidget {
  const NewGraffittiView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewGraffittiViewModel>.reactive(
      viewModelBuilder: () => NewGraffittiViewModel(),
      builder: (context, viewModel, child) {
        return SailColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: SailStyleValues.padding16,
          mainAxisSize: MainAxisSize.min,
          leadingSpacing: true,
          children: [
            SailTextField(
              label: 'Message (max 80 characters)',
              controller: viewModel.messageController,
              hintText: 'Enter a message',
              size: TextFieldSize.small,
            ),
            QtButton(
              label: 'Broadcast',
              onPressed: () => viewModel.createGraffitti(context),
              size: ButtonSize.small,
              disabled: viewModel.messageController.text.isEmpty,
            ),
          ],
        );
      },
    );
  }
}

class NewGraffittiViewModel extends BaseViewModel {
  final TextEditingController messageController = TextEditingController();
  final API _api = GetIt.I<API>();

  NewGraffittiViewModel() {
    messageController.addListener(notifyListeners);
  }

  Future<void> createGraffitti(BuildContext context) async {
    if (messageController.text.isEmpty) {
      return;
    }

    try {
      final address = await _api.wallet.getNewAddress();
      final _ = await _api.wallet.sendTransaction(
        address,
        10000,
        opReturnMessage: messageController.text,
      );

      if (!context.mounted) return;

      showSnackBar(context, 'graffiti broadcast successfully!');
      messageController.clear();
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, 'could not broadcast graffiti: $e');
    }
  }

  @override
  void dispose() {
    messageController.removeListener(notifyListeners);
    messageController.dispose();
    super.dispose();
  }
}

class CoinNewsTable extends StatelessWidget {
  final List<CoinNewsEntry> entries;
  final Function(String) onSort;

  const CoinNewsTable({
    super.key,
    required this.entries,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => entries[index].id,
      headerBuilder: (context) => [
        SailTableHeaderCell(name: 'Fee'),
        SailTableHeaderCell(name: 'Time'),
        SailTableHeaderCell(name: 'Headline'),
      ],
      rowBuilder: (context, row, selected) {
        final entry = entries[row];
        return [
          SailTableCell(value: entry.fe.toString()),
          SailTableCell(value: entry.time.format()),
          SailTableCell(value: entry.headline),
        ];
      },
      rowCount: entries.length,
      columnWidths: const [150, 200, 150],
      drawGrid: true,
      onSort: (columnIndex, ascending) {
        onSort(['fe', 'time', 'headline'][columnIndex]);
      },
    );
  }
}

class CoinNewsEntry {
  final String id;
  final num fe;
  final DateTime time;
  final String headline;

  CoinNewsEntry({
    required this.id,
    required this.fe,
    required this.time,
    required this.headline,
  });
}

class GraffittiExplorerView extends StatelessWidget {
  const GraffittiExplorerView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GraffittiExplorerViewModel>.reactive(
      viewModelBuilder: () => GraffittiExplorerViewModel(),
      builder: (context, viewModel, child) {
        return SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.end,
          leadingSpacing: true,
          children: [
            // add button here, that opens ANOTHER dialog, where you can enter a message.
            QtButton(
              label: 'New Graffitti',
              onPressed: () => newGraffittiDialog(context),
              size: ButtonSize.small,
            ),
            SizedBox(
              height: 500,
              child: GraffittiTable(
                entries: viewModel.entries,
                onSort: viewModel.onSort,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> newGraffittiDialog(BuildContext context) async {
    await widgetDialog(
      context: context,
      title: 'New Graffitti',
      child: NewGraffittiView(),
    );
  }
}

class GraffittiExplorerViewModel extends BaseViewModel {
  final BlockchainProvider _blockchainProvider = GetIt.I.get<BlockchainProvider>();

  String _sortColumn = 'time';
  bool _sortAscending = true;
  List<OPReturn> get entries => _blockchainProvider.opReturns;

  GraffittiExplorerViewModel() {
    _blockchainProvider.fetch();
    _blockchainProvider.addListener(notifyListeners);
  }

  void onSort(String column) {
    if (_sortColumn == column) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumn = column;
      _sortAscending = true;
    }
    _sortEntries();
    notifyListeners();
  }

  void _sortEntries() {
    entries.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (_sortColumn) {
        case 'fee':
          aValue = a.feeSatoshi.toInt();
          bValue = b.feeSatoshi.toInt();
          break;
        case 'message':
          aValue = a.message;
          bValue = b.message;
          break;
        case 'time':
          aValue = a.createTime.toDateTime().millisecondsSinceEpoch;
          bValue = b.createTime.toDateTime().millisecondsSinceEpoch;
          break;
        case 'height':
          aValue = a.height;
          bValue = b.height;
          break;
      }

      return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  void dispose() {
    _blockchainProvider.removeListener(notifyListeners);
    super.dispose();
  }
}

class GraffittiTable extends StatelessWidget {
  final List<OPReturn> entries;
  final Function(String) onSort;

  const GraffittiTable({
    super.key,
    required this.entries,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailTable(
      backgroundColor: theme.colors.backgroundSecondary,
      getRowId: (index) => entries[index].id,
      headerBuilder: (context) => [
        SailTableHeaderCell(name: 'Fee', onSort: () => onSort('fee')),
        SailTableHeaderCell(name: 'Message', onSort: () => onSort('message')),
        SailTableHeaderCell(name: 'Time', onSort: () => onSort('time')),
        SailTableHeaderCell(name: 'Height', onSort: () => onSort('height')),
      ],
      rowBuilder: (context, row, selected) {
        final entry = entries[row];
        return [
          SailTableCell(value: formatBitcoin(satoshiToBTC(entry.feeSatoshi.toInt()))),
          SailTableCell(value: entry.message),
          SailTableCell(value: entry.createTime.toDateTime().toLocal().format()),
          SailTableCell(value: entry.height.toString()),
        ];
      },
      rowCount: entries.length,
      columnWidths: const [150, 200, 250, 150],
      onSort: (columnIndex, ascending) {
        onSort(['fee', 'message', 'time', 'height'][columnIndex]);
      },
    );
  }
}
