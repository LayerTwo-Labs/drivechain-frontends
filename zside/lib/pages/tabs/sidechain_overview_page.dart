import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/providers/transactions_provider.dart';

@RoutePage()
class SidechainOverviewTabPage extends StatelessWidget {
  const SidechainOverviewTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => OverviewTabViewModel(),
      builder: ((context, model, child) {
        return QtPage(
          child: SailRow(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SailStyleValues.padding08,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: SailColumn(
                    spacing: SailStyleValues.padding08,
                    children: [
                      // Top row with balance and receive
                      SizedBox(
                        height: 181, // Fixed height for top section
                        child: SailRow(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Balance card
                            Expanded(
                              child: SailCard(
                                title: 'Balance',
                                child: SailColumn(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary24(
                                      '${formatBitcoin(model.totalBalance)} ${model.ticker}',
                                      bold: true,
                                    ),
                                    const SizedBox(height: 4), // Further reduced spacing
                                    BalanceRow(
                                      label: 'Available',
                                      amount: model.balance,
                                      ticker: model.ticker,
                                    ),
                                    BalanceRow(
                                      label: 'Pending',
                                      amount: model.pendingBalance,
                                      ticker: model.ticker,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SailCard(
                        title: 'Receive on Sidechain',
                        error: model.receiveError,
                        child: SailColumn(
                          spacing: SailStyleValues.padding04,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (model.isGeneratingAddress)
                              const Center(child: LoadingIndicator())
                            else ...[
                              SailColumn(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SailTextField(
                                    controller: TextEditingController(text: model.receiveAddress),
                                    hintText: 'Generating deposit address...',
                                    readOnly: true,
                                    suffixWidget: CopyButton(
                                      text: model.receiveAddress ?? '',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SailCard(
                        title: 'Send on Sidechain',
                        error: model.sendError,
                        child: SailColumn(
                          spacing: SailStyleValues.padding16,
                          children: [
                            SailText.secondary15('Pay to'),
                            SailTextField(
                              controller: model.bitcoinAddressController,
                              hintText: 'Enter a bitcoin address',
                            ),
                            NumericField(
                              label: 'Amount',
                              controller: model.bitcoinAmountController,
                              hintText: '0.00',
                            ),
                            SailButton(
                              label: 'Send',
                              onPressed: () => model.executeSendOnSidechain(context),
                              loading: model.isSending,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Transaction history
              Expanded(
                child: TransactionsTab(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class OverviewTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  final labelController = TextEditingController();

  String? receiveAddress;
  double? sidechainFee;
  String? sendError;
  String? receiveError;

  // Properties for sending
  double? get sendAmount => double.tryParse(bitcoinAmountController.text);
  double? get maxAmount => max(_balanceProvider.balance - (sidechainFee ?? 0), 0);
  String get ticker => _rpc.chain.ticker;
  String get sidechainName => _rpc.chain.name;
  List<CoreTransaction> get transactions => _transactionsProvider.sidechainTransactions;

  String get totalBitcoinAmount => formatBitcoin(
        ((double.tryParse(bitcoinAmountController.text) ?? 0) + (sidechainFee ?? 0)),
        symbol: ticker,
      );

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;
  double get totalBalance => balance + pendingBalance;

  bool _sendingTransaction = false;
  bool _generatingAddress = false;

  bool get isSending => _sendingTransaction;
  bool get isGeneratingAddress => _generatingAddress;

  OverviewTabViewModel() {
    _initControllers();
    _initFees();
    _transactionsProvider.addListener(ensureAddress);
    _balanceProvider.addListener(ensureAddress);
    generateReceiveAddress();
  }

  void _initControllers() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(_capAmount);
  }

  Future<void> _initFees() async {
    await Future.wait([estimateSidechainFee()]);
  }

  void ensureAddress() {
    if (receiveAddress == null) {
      generateReceiveAddress();
    }
    notifyListeners();
  }

  void _capAmount() {
    String currentInput = bitcoinAmountController.text;
    if (maxAmount != null && (double.tryParse(currentInput) != null && double.parse(currentInput) > maxAmount!)) {
      bitcoinAmountController.text = maxAmount.toString();
      bitcoinAmountController.selection = TextSelection.fromPosition(
        TextPosition(offset: bitcoinAmountController.text.length),
      );
    }
    notifyListeners();
  }

  Future<void> estimateSidechainFee() async {
    sidechainFee = await _rpc.sideEstimateFee();
    notifyListeners();
  }

  Future<void> generateReceiveAddress() async {
    _generatingAddress = true;
    receiveError = null;
    notifyListeners();

    try {
      receiveAddress = await _rpc.getSideAddress();
    } catch (error) {
      log.e('Failed to generate receive address', error: error);
      receiveError = error.toString();
      receiveAddress = null;
    } finally {
      _generatingAddress = false;
      notifyListeners();
    }
  }

  Future<void> executeSendOnSidechain(BuildContext context) async {
    sendError = null;

    if (sendAmount == null) {
      sendError = 'Please enter a valid amount';
      notifyListeners();
      return;
    }

    if (sidechainFee == null) {
      sendError = 'Could not calculate network fee';
      notifyListeners();
      return;
    }

    final address = bitcoinAddressController.text.trim();
    if (address.isEmpty) {
      sendError = 'Please enter a destination address';
      notifyListeners();
      return;
    }

    if (!context.mounted) return;

    _sendingTransaction = true;
    notifyListeners();

    try {
      final txid = await _doSidechainSend(context, address, sendAmount!);
      if (!context.mounted) return;

      await successDialog(
        context: context,
        action: 'Send on sidechain',
        title: 'You sent $sendAmount $ticker to $address',
        subtitle: 'TXID: $txid',
      );

      // Clear the input fields after successful send
      bitcoinAddressController.clear();
      bitcoinAmountController.clear();
    } catch (error) {
      log.e('Send failed', error: error);
      sendError = error.toString();
    } finally {
      _sendingTransaction = false;
      notifyListeners();
    }
  }

  Future<String> _doSidechainSend(BuildContext context, String address, double amount) async {
    log.i('doing sidechain withdrawal: $amount $ticker to $address with $sidechainFee SC fee');

    try {
      final sendTXID = await _rpc.sideSend(
        address,
        amount,
        false,
      );

      unawaited(_balanceProvider.fetch());
      unawaited(_transactionsProvider.fetch());

      return sendTXID;
    } catch (error) {
      log.e('Could not execute withdrawal', error: error);
      rethrow;
    }
  }

  void castHelp(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const DepositWithdrawHelp();
      },
    );
  }

  @override
  void dispose() {
    bitcoinAddressController.dispose();
    bitcoinAmountController.dispose();
    labelController.dispose();
    _transactionsProvider.removeListener(ensureAddress);
    _balanceProvider.removeListener(ensureAddress);
    super.dispose();
  }
}

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LatestWalletTransactionsViewModel>.reactive(
      viewModelBuilder: () => LatestWalletTransactionsViewModel(),
      builder: (context, model, child) {
        return TransactionTable(
          entries: model.entries,
          searchWidget: SailTextField(
            controller: model.searchController,
            hintText: 'Search with txid, address or amount',
          ),
        );
      },
    );
  }
}

class TransactionTable extends StatefulWidget {
  final List<CoreTransaction> entries;
  final Widget searchWidget;

  const TransactionTable({
    super.key,
    required this.entries,
    required this.searchWidget,
  });

  @override
  State<TransactionTable> createState() => _TransactionTableState();
}

class _TransactionTableState extends State<TransactionTable> {
  String sortColumn = 'date';
  bool sortAscending = true;
  List<CoreTransaction> entries = [];

  @override
  void initState() {
    super.initState();
    entries = widget.entries;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!listEquals(entries, widget.entries)) {
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
        case 'height':
          aValue = a.confirmations;
          bValue = b.confirmations;
          break;
        case 'date':
          aValue = a.time;
          bValue = b.time;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'amount':
          aValue = a.amount;
          bValue = b.amount;
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
          title: 'Wallet Transaction History',
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
                      name: 'Conf Height',
                      onSort: () => onSort('height'),
                    ),
                    SailTableHeaderCell(
                      name: 'Amount',
                      onSort: () => onSort('amount'),
                    ),
                    SailTableHeaderCell(
                      name: 'TxID',
                      onSort: () => onSort('txid'),
                    ),
                    SailTableHeaderCell(
                      name: 'Date',
                      onSort: () => onSort('date'),
                    ),
                  ],
                  rowBuilder: (context, row, selected) {
                    final entry = widget.entries[row];
                    final amount = formatBitcoin(satoshiToBTC(entry.amount.toInt()));

                    return [
                      SailTableCell(
                        value: entry.confirmations == 0 ? 'Unconfirmed' : entry.confirmations.toString(),
                      ),
                      SailTableCell(
                        value: amount,
                        monospace: true,
                      ),
                      SailTableCell(
                        value: '${entry.txid.substring(0, 6)}..:${entry.vout}',
                        copyValue: '${entry.txid}:${entry.vout}',
                      ),
                      SailTableCell(
                        value: DateTime.fromMillisecondsSinceEpoch(entry.blocktime * 1000).toLocal().toString(),
                      ),
                    ];
                  },
                  rowCount: widget.entries.length,
                  drawGrid: true,
                  sortColumnIndex: [
                    'height',
                    'date',
                    'txid',
                    'amount',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['height', 'date', 'txid', 'amount'][columnIndex]);
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

  void _showUtxoDetails(BuildContext context, CoreTransaction utxo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'Transaction Details',
            subtitle: 'Details of the selected transaction',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'TxID', value: utxo.txid),
                  DetailRow(label: 'Amount', value: formatBitcoin(satoshiToBTC(utxo.amount.toInt()))),
                  DetailRow(label: 'Date', value: utxo.time.toLocal().format()),
                  DetailRow(label: 'Confirmation Height', value: utxo.confirmations.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: SailText.primary13(
              label,
              monospace: true,
              color: context.sailTheme.colors.textTertiary,
            ),
          ),
          Expanded(
            child: SailText.secondary13(
              value,
              monospace: true,
            ),
          ),
        ],
      ),
    );
  }
}

class LatestWalletTransactionsViewModel extends BaseViewModel {
  final TransactionsProvider _txProvider = GetIt.I<TransactionsProvider>();
  final TextEditingController searchController = TextEditingController();

  List<CoreTransaction> get entries => _txProvider.sidechainTransactions
      .where(
        (tx) => searchController.text.isEmpty || tx.txid.toLowerCase().contains(searchController.text.toLowerCase()),
      )
      .toList();

  LatestWalletTransactionsViewModel() {
    searchController.addListener(notifyListeners);
    _txProvider.addListener(notifyListeners);

    // Initialize data
    _initData();
  }

  Future<void> _initData() async {
    try {
      setBusy(true);
      await _txProvider.fetch();
    } catch (e) {
      // Handle error if needed
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    searchController.removeListener(notifyListeners);
    _txProvider.removeListener(notifyListeners);
    searchController.dispose();
    super.dispose();
  }
}

class BalanceRow extends StatelessWidget {
  final String label;
  final double amount;
  final String ticker;

  const BalanceRow({
    super.key,
    required this.label,
    required this.amount,
    required this.ticker,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary15(label),
          SailText.secondary15('${formatBitcoin(amount)} $ticker'),
        ],
      ),
    );
  }
}

class TransactionHistoryCard extends ViewModelWidget<OverviewTabViewModel> {
  const TransactionHistoryCard({super.key});

  @override
  Widget build(BuildContext context, OverviewTabViewModel viewModel) {
    return Expanded(
      child: ViewModelBuilder<LatestWalletTransactionsViewModel>.reactive(
        viewModelBuilder: () => LatestWalletTransactionsViewModel(),
        builder: (context, model, child) {
          return TransactionTable(
            entries: model.entries,
            searchWidget: SailTextField(
              controller: model.searchController,
              hintText: 'Search with txid, address or amount',
            ),
          );
        },
      ),
    );
  }
}
