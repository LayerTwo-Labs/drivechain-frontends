import 'dart:async';
import 'dart:io';

import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final formatter = GetIt.I<FormatterProvider>();

        return ViewModelBuilder<OverviewViewModel>.reactive(
          viewModelBuilder: () => OverviewViewModel(),
          builder: (context, model, child) {
            return ListenableBuilder(
              listenable: formatter,
              builder: (context, child) => SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  children: [
                    SailRow(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 16,
                      children: [
                        Expanded(
                          child: WalletStats(
                            title: 'Balance',
                            subtitle: '${formatter.formatBTC(model.pendingBalance)} pending',
                            value: formatter
                                .formatBTC(model.balance)
                                .replaceAll(' ${formatter.currentUnit.symbol}', ''),
                            bitcoinAmount: true,
                            icon: SailSVGAsset.bitcoin,
                          ),
                        ),
                        Expanded(
                          child: WalletStats(
                            title: 'Number of UTXOs',
                            value: model.stats?.utxosCurrent.toString() ?? '0',
                            subtitle:
                                '${model.stats?.utxosUniqueAddresses.toString() ?? '0'} unique address${model.stats?.utxosUniqueAddresses.toInt() == 1 ? '' : 'es'}',
                            icon: SailSVGAsset.coins,
                          ),
                        ),
                        // Show sidechain deposit volume (greyed out on mainnet)
                        Expanded(
                          child: Tooltip(
                            message: GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains
                                ? ''
                                : 'Sidechains require Forknet or Signet network',
                            child: Opacity(
                              opacity: GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains ? 1.0 : 0.4,
                              child: WalletStats(
                                title: 'Sidechain Deposit Volume',
                                value: GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains
                                    ? formatter
                                          .formatSats(model.stats?.sidechainDepositVolume.toInt() ?? 0)
                                          .replaceAll(' ${formatter.currentUnit.symbol}', '')
                                    : '-',
                                subtitle: GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains
                                    ? '${formatter.formatSats(model.stats?.sidechainDepositVolumeLast30Days.toInt() ?? 0)} last 30 days'
                                    : 'Switch networks to unlock',
                                bitcoinAmount: GetIt.I.get<BitcoinConfProvider>().networkSupportsSidechains,
                                icon: SailSVGAsset.wallet,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: WalletStats(
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
                        hintText: 'Search with txid, address or amount',
                      ),
                    ),
                  ],
                ),
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
    final formatter = GetIt.I<FormatterProvider>();
    final entries = sortedEntries;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SailCard(
          title: 'Wallet Transaction History',
          titleTooltip:
              'This transaction list contains all your wallet transactions. Sends, receives, and sidechain-interaction transactions.',
          bottomPadding: false,
          widgetHeaderEnd: SailButton(
            label: 'Export CSV',
            variant: ButtonVariant.secondary,
            small: true,
            icon: SailSVGAsset.iconDownload,
            onPressed: () async {
              await widget.model.exportTransactionsToCSV(context, entries);
            },
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: SailStyleValues.padding16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.searchWidget,
                    const SizedBox(height: SailStyleValues.padding12),
                    DateRangeFilterWidget(model: widget.model),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: SailSkeletonizer(
                  description: 'Waiting for enforcer to boot and wallet to sync..',
                  enabled: widget.model.loading,
                  child: ListenableBuilder(
                    listenable: formatter,
                    builder: (context, child) => SailTable(
                      getRowId: (index) => entries[index].txid,
                      headerBuilder: (context) => [
                        SailTableHeaderCell(
                          name: 'Date',
                          alignment: Alignment.centerLeft,
                          onSort: () => onSort('date'),
                        ),
                        SailTableHeaderCell(
                          name: 'TXID',
                          alignment: Alignment.centerLeft,
                          onSort: () => onSort('txid'),
                        ),
                        SailTableHeaderCell(
                          name: 'Address',
                          alignment: Alignment.centerLeft,
                          onSort: () => onSort('address'),
                        ),
                        SailTableHeaderCell(
                          name: 'Note',
                          alignment: Alignment.centerLeft,
                          onSort: () => onSort('note'),
                        ),
                        SailTableHeaderCell(
                          name: 'Amount',
                          alignment: Alignment.centerLeft,
                          onSort: () => onSort('amount'),
                        ),
                      ],
                      rowBuilder: (context, row, selected) {
                        final entry = entries[row];

                        // Calculate amount and determine sign
                        final amountDiff = entry.receivedSatoshi - entry.sentSatoshi;
                        final sign = amountDiff > 0 ? '+' : '-';
                        final formattedAmount = '$sign${formatter.formatSats(amountDiff.abs().toInt())}';

                        return [
                          SailTableCell(
                            value: formatDate(entry.confirmationTime.timestamp.toDateTime().toLocal()),
                            alignment: Alignment.centerLeft,
                          ),
                          SailTableCell(
                            value: '${entry.txid.substring(0, 10)}..',
                            copyValue: entry.txid,
                            alignment: Alignment.centerLeft,
                          ),
                          SailTableCell(
                            value: '${entry.address}${entry.addressLabel.isNotEmpty ? ' (${entry.addressLabel})' : ''}',
                            alignment: Alignment.centerLeft,
                          ),
                          SailTableCell(
                            value: entry.note,
                            alignment: Alignment.centerLeft,
                          ),
                          SailTableCell(
                            value: formattedAmount,
                            alignment: Alignment.centerLeft,
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
                                          final newNote = updatedFields
                                              .firstWhere((f) => f.name == 'Note')
                                              .currentValue;
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
                      emptyPlaceholder: 'No transactions yet',
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OverviewViewModel extends BaseViewModel with ChangeTrackingMixin {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  final BitwindowRPC _bitwindowRPC = GetIt.I<BitwindowRPC>();
  final EnforcerRPC _enforcerRPC = GetIt.I<EnforcerRPC>();
  final BalanceProvider _balanceProvider = GetIt.I<BalanceProvider>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  DateTimeRange? dateRange;

  List<WalletTransaction> get entries {
    if (loading) {
      return [
        WalletTransaction(
          txid: 'dummy_tx_1',
          feeSats: Int64(1000),
          receivedSatoshi: Int64(50000000), // 0.5 BTC
          sentSatoshi: Int64(0),
          address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
          addressLabel: 'Main Wallet',
          note: 'Received payment',
          confirmationTime: Confirmation(
            height: 800000,
            timestamp: Timestamp.fromDateTime(DateTime(2024)),
          ),
        ),
        WalletTransaction(
          txid: 'dummy_tx_2',
          feeSats: Int64(2000),
          receivedSatoshi: Int64(0),
          sentSatoshi: Int64(100000000), // 1 BTC
          address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
          addressLabel: 'Exchange',
          note: 'Sent to exchange',
          confirmationTime: Confirmation(
            height: 800001,
            timestamp: Timestamp.fromDateTime(DateTime(2024)),
          ),
        ),
        WalletTransaction(
          txid: 'dummy_tx_3',
          feeSats: Int64(1500),
          receivedSatoshi: Int64(25000000), // 0.25 BTC
          sentSatoshi: Int64(0),
          address: 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
          addressLabel: 'Mining Pool',
          note: 'Mining reward',
          confirmationTime: Confirmation(
            height: 800002,
            timestamp: Timestamp.fromDateTime(DateTime(2024)),
          ),
        ),
      ];
    }

    final filteredTransactions = _txProvider.walletTransactions.where((tx) {
      final txDate = tx.confirmationTime.timestamp.toDateTime();

      if (searchController.text.isNotEmpty && !tx.txid.contains(searchController.text)) {
        return false;
      }

      if (dateRange != null) {
        final rangeStart = DateTime(dateRange!.start.year, dateRange!.start.month, dateRange!.start.day);
        final rangeEnd = DateTime(dateRange!.end.year, dateRange!.end.month, dateRange!.end.day, 23, 59, 59);

        if (txDate.isBefore(rangeStart) || txDate.isAfter(rangeEnd)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Always sort by date, newest first
    filteredTransactions.sort((a, b) {
      final aTime = a.confirmationTime.timestamp.seconds;
      final bTime = b.confirmationTime.timestamp.seconds;
      // If timestamps are equal, use txid as secondary sort
      if (aTime == bTime) {
        return b.txid.compareTo(a.txid);
      }
      return bTime.compareTo(aTime); // Newest first
    });

    return filteredTransactions;
  }

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  String sortColumn = 'date';
  bool sortAscending = true;
  GetStatsResponse? stats;

  @override
  String? modelError;

  final TextEditingController searchController = TextEditingController();

  bool get loading => _enforcerRPC.initializingBinary;

  OverviewViewModel() {
    initChangeTracker();
    searchController.addListener(_onChange);
    _txProvider.addListener(_onChange);
    _txProvider.addListener(_debouncedGetStats);
    _balanceProvider.addListener(_onChange);
    _balanceProvider.addListener(_debouncedGetStats);
    _enforcerRPC.addListener(_onChange);
    getStats();
  }

  void _onChange() {
    track('entries', entries);
    track('balance', balance);
    track('pendingBalance', pendingBalance);
    track('searchText', searchController.text);
    track('dateRange', dateRange);
    track('loading', loading);
    track('stats', stats);
    notifyIfChanged();
  }

  void setDateRange(DateTimeRange? range) {
    dateRange = range;
    notifyListeners();
  }

  void clearDateFilter() {
    dateRange = null;
    notifyListeners();
  }

  // Debounce stats fetching
  Timer? _statsTimer;
  void _debouncedGetStats() {
    _statsTimer?.cancel();
    _statsTimer = Timer(const Duration(milliseconds: 100), () {
      getStats();
    });
  }

  Future<void> getStats() async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) return;

    final newStats = await _bitwindowRPC.wallet.getStats(walletId);
    if (track('stats', newStats)) {
      stats = newStats;
      notifyListeners();
    }
  }

  Future<void> saveNote(BuildContext context, String txid, String note) async {
    try {
      setBusy(true);
      await _txProvider.saveNote(txid, note);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (error.toString() != modelError) {
        modelError = error.toString();
        notifyListeners();
      }
    } finally {
      setBusy(false);
    }
  }

  Future<void> exportTransactionsToCSV(BuildContext context, List<WalletTransaction> transactions) async {
    try {
      setBusy(true);

      if (transactions.isEmpty) {
        if (context.mounted) {
          showSnackBar(context, 'No transactions to export');
        }
        return;
      }

      final defaultFileName = 'bitwindow-transactions-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Transactions to CSV',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        return;
      }

      final csvData = _generateCSV(transactions);
      final file = File(result);
      await file.writeAsString(csvData);

      if (context.mounted) {
        showSnackBar(context, 'Transactions exported successfully to $result');
      }
    } catch (error) {
      if (context.mounted) {
        showSnackBar(context, 'Export failed: $error');
      }
      modelError = error.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  String _generateCSV(List<WalletTransaction> transactions) {
    final headers = [
      'Date',
      'TXID',
      'Type',
      'Address',
      'Label',
      'Amount (BTC)',
      'Amount (sats)',
      'Fee (sats)',
      'Note',
      'Block Height',
    ];

    final rows = <List<String>>[headers];

    for (final tx in transactions) {
      final netAmount = tx.receivedSatoshi - tx.sentSatoshi;
      final type = netAmount > 0 ? 'Received' : 'Sent';
      final amountBTC = (netAmount.toInt() / 100000000).toStringAsFixed(8);
      final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(tx.confirmationTime.timestamp.toDateTime().toLocal());

      rows.add([
        date,
        tx.txid,
        type,
        tx.address,
        tx.addressLabel,
        amountBTC,
        netAmount.toString(),
        tx.feeSats.toString(),
        tx.note,
        tx.confirmationTime.height.toString(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    searchController.removeListener(_onChange);
    _txProvider.removeListener(_onChange);
    _txProvider.removeListener(_debouncedGetStats);
    _balanceProvider.removeListener(_debouncedGetStats);
    super.dispose();
  }
}

class WalletStats extends ViewModelWidget<OverviewViewModel> {
  final String title;
  final String subtitle;
  final String value;
  final SailSVGAsset icon;
  final bool bitcoinAmount;

  const WalletStats({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    this.bitcoinAmount = false,
  });

  @override
  Widget build(BuildContext context, OverviewViewModel viewModel) {
    return SailCardStats(
      title: title,
      subtitle: subtitle,
      value: value,
      icon: icon,
      loading: LoadingDetails(
        enabled: viewModel.loading,
        description: 'Waiting for enforcer to boot and wallet to sync..',
      ),
    );
  }
}

class DateRangeFilterWidget extends StatelessWidget {
  final OverviewViewModel model;

  const DateRangeFilterWidget({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2009, 1, 3),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: model.dateRange,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: context.sailTheme.colors.primary,
                  onPrimary: context.sailTheme.colors.background,
                  surface: context.sailTheme.colors.backgroundSecondary,
                  onSurface: context.sailTheme.colors.text,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedRange != null) {
          model.setDateRange(pickedRange);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SailStyleValues.padding16,
          vertical: SailStyleValues.padding12,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.sailTheme.colors.divider,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SailSVG.icon(SailSVGAsset.iconCalendar, width: 16),
            const SizedBox(width: SailStyleValues.padding08),
            SailText.primary13(
              model.dateRange == null
                  ? 'Select date range'
                  : '${DateFormat('MMM dd, yyyy').format(model.dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(model.dateRange!.end)}',
            ),
            if (model.dateRange != null) ...[
              const SizedBox(width: SailStyleValues.padding08),
              GestureDetector(
                onTap: () => model.clearDateFilter(),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: context.sailTheme.colors.text,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
