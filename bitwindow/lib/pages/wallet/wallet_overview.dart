import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<OverviewViewModel>.reactive(
          viewModelBuilder: () => OverviewViewModel(),
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                children: [
                  SailRow(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Expanded(
                        child: SailCardStats(
                          title: 'Balance',
                          subtitle: '${formatBitcoin(model.pendingBalance)} pending',
                          value: formatBitcoin(model.balance, symbol: ''),
                          bitcoinAmount: true,
                          icon: SailSVGAsset.bitcoin,
                        ),
                      ),
                      Expanded(
                        child: SailCardStats(
                          title: 'Number of UTXOs',
                          value: model.stats?.utxosCurrent.toString() ?? '0',
                          subtitle:
                              '${model.stats?.utxosUniqueAddresses.toString() ?? '0'} unique address${model.stats?.utxosUniqueAddresses.toInt() == 1 ? '' : 'es'}',
                          icon: SailSVGAsset.bitcoin,
                        ),
                      ),
                      Expanded(
                        child: SailCardStats(
                          title: 'Sidechain Deposit Volume',
                          value: formatBitcoin(model.stats?.sidechainDepositVolume.toInt() ?? 0, symbol: ''),
                          subtitle:
                              '${formatBitcoin(model.stats?.sidechainDepositVolumeLast30Days.toInt() ?? 0, symbol: '')} last 30 days',
                          bitcoinAmount: true,
                          icon: SailSVGAsset.wallet,
                        ),
                      ),
                      Expanded(
                        child: SailCardStats(
                          title: 'Transaction Count',
                          value: model.stats?.transactionCountTotal.toString() ?? '0',
                          subtitle: '${model.stats?.transactionCountSinceMonth.toString() ?? '0'} in last month',
                          icon: SailSVGAsset.activity,
                        ),
                      ),
                    ],
                  ),
                  TransactionTable(
                    model: model,
                    searchWidget: SailTextField(
                      controller: model.searchController,
                      hintText: 'Enter address or transaction id to search',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class TransactionTable extends StatefulWidget {
  final Widget searchWidget;
  final OverviewViewModel model;

  const TransactionTable({
    super.key,
    required this.model,
    required this.searchWidget,
  });

  @override
  State<TransactionTable> createState() => _TransactionTableState();
}

class _TransactionTableState extends State<TransactionTable> {
  String sortColumn = 'date';
  bool sortAscending = false;

  List<WalletTransaction> get sortedEntries {
    final entries = List<WalletTransaction>.from(widget.model.entries);
    entries.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortColumn) {
        case 'date':
          aValue = a.confirmationTime.timestamp.seconds;
          bValue = b.confirmationTime.timestamp.seconds;
          // If timestamps are equal, use txid as secondary sort
          if (aValue == bValue) {
            return sortAscending ? a.txid.compareTo(b.txid) : b.txid.compareTo(a.txid);
          }
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'address':
          aValue = a.address;
          bValue = b.address;
          break;
        case 'note':
          aValue = a.note;
          bValue = b.note;
          break;
        case 'amount':
          // Calculate total amount for each transaction
          aValue = (a.receivedSatoshi - a.sentSatoshi).abs();
          bValue = (b.receivedSatoshi - b.sentSatoshi).abs();
          break;
        default:
          aValue = a.confirmationTime.timestamp.seconds;
          bValue = b.confirmationTime.timestamp.seconds;
      }
      aValue ??= '';
      bValue ??= '';
      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
    return entries;
  }

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = sortedEntries;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SailCard(
          title: 'Wallet Transaction History',
          subtitle: 'Contains send, receive and sidechain-interaction transactions.',
          bottomPadding: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SailStyleValues.padding16,
                ),
                child: widget.searchWidget,
              ),
              SizedBox(
                height: 300,
                child: SailTable(
                  getRowId: (index) => entries[index].txid,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(
                      name: 'Date',
                      onSort: () => onSort('date'),
                    ),
                    SailTableHeaderCell(
                      name: 'TXID',
                      onSort: () => onSort('txid'),
                    ),
                    SailTableHeaderCell(
                      name: 'Address',
                      onSort: () => onSort('address'),
                    ),
                    SailTableHeaderCell(
                      name: 'Note',
                      onSort: () => onSort('note'),
                    ),
                    SailTableHeaderCell(
                      name: 'Amount',
                      onSort: () => onSort('amount'),
                    ),
                  ],
                  rowBuilder: (context, row, selected) {
                    final entry = entries[row];

                    // Calculate amount and determine sign
                    final amountDiff = entry.receivedSatoshi - entry.sentSatoshi;
                    final sign = amountDiff > 0 ? '+' : '-';
                    final formattedAmount = '$sign${formatBitcoin(
                      satoshiToBTC(amountDiff.abs().toInt()),
                      symbol: '',
                    )}';

                    return [
                      SailTableCell(
                        value: formatDate(entry.confirmationTime.timestamp.toDateTime().toLocal()),
                      ),
                      SailTableCell(
                        value: '${entry.txid.substring(0, 10)}..',
                        copyValue: entry.txid,
                      ),
                      SailTableCell(
                        value: '${entry.address}${entry.addressLabel.isNotEmpty ? ' (${entry.addressLabel})' : ''}',
                      ),
                      SailTableCell(
                        value: entry.note,
                      ),
                      SailTableCell(
                        value: formattedAmount,
                        monospace: true,
                      ),
                    ];
                  },
                  contextMenuItems: (rowId) {
                    final entry = entries.firstWhere((e) => e.txid == rowId);

                    return [
                      SailMenuItem(
                        onSelected: () async {
                          await showTransactionDetails(context, rowId);
                        },
                        child: SailText.primary12('Show Details'),
                      ),
                      SailMenuItem(
                        closeOnSelect: false,
                        onSelected: () async {
                          await Future.microtask(() async {
                            if (!context.mounted) return;
                            await showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  child: SailCardEditValues(
                                    title: entry.note.isEmpty ? 'Add Note' : 'Edit Note',
                                    subtitle:
                                        "${entry.note.isEmpty ? "Set a" : "Update the"} note and click Save when you're done",
                                    fields: [
                                      EditField(name: 'Note', currentValue: entry.note),
                                    ],
                                    onSave: (updatedFields) async {
                                      final newNote = updatedFields.firstWhere((f) => f.name == 'Note').currentValue;
                                      await widget.model.saveNote(context, entry.txid, newNote);
                                    },
                                  ),
                                ),
                              ),
                            );
                          });
                        },
                        child: SailText.primary12(entry.note.isEmpty ? 'Add Note' : 'Update Note'),
                      ),
                      MempoolMenuItem(txid: entry.txid),
                    ];
                  },
                  rowCount: entries.length,
                  columnWidths: const [120, 60, 320, 120, 120],
                  drawGrid: true,
                  sortColumnIndex: [
                    'date',
                    'txid',
                    'address',
                    'note',
                    'amount',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['date', 'txid', 'address', 'note', 'amount'][columnIndex]);
                  },
                  onDoubleTap: (rowId) => showTransactionDetails(context, rowId),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OverviewViewModel extends BaseViewModel {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  final BitwindowRPC _bitwindowRPC = GetIt.I<BitwindowRPC>();
  final BalanceProvider _balanceProvider = GetIt.I<BalanceProvider>();

  List<WalletTransaction> get entries => _txProvider.walletTransactions
      .where(
        (tx) => searchController.text.isEmpty || tx.txid.contains(searchController.text),
      )
      .toList();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  String sortColumn = 'date';
  bool sortAscending = true;
  GetStatsResponse? stats;

  @override
  String? modelError;

  final TextEditingController searchController = TextEditingController();

  OverviewViewModel() {
    searchController.addListener(notifyListeners);
    _txProvider.addListener(notifyListeners);
    _txProvider.addListener(getStats);
    _balanceProvider.addListener(getStats);
    getStats();
  }

  Future<void> getStats() async {
    stats = await _bitwindowRPC.wallet.getStats();
    notifyListeners();
  }

  Future<void> saveNote(BuildContext context, String txid, String note) async {
    try {
      setBusy(true);
      notifyListeners();
      await _txProvider.saveNote(txid, note);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      modelError = error.toString();
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.removeListener(notifyListeners);
    _txProvider.removeListener(notifyListeners);
    _txProvider.removeListener(getStats);
    super.dispose();
  }
}
