import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/providers/sidechain/address_provider.dart';
import 'package:sail_ui/providers/sidechain/transactions_provider.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/rpcs/thunder_utxo.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/utils/change_tracker.dart';
import 'package:stacked/stacked.dart';

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
                                    SailSkeletonizer(
                                      enabled: !model.balanceInitialized,
                                      description: 'Waiting for thunder to boot...',
                                      child: SailText.primary24(
                                        '${formatBitcoin(model.totalBalance)} ${model.ticker}',
                                        bold: true,
                                      ),
                                    ),
                                    const SizedBox(height: 4), // Further reduced spacing
                                    BalanceRow(
                                      label: 'Available',
                                      amount: model.balance,
                                      ticker: model.ticker,
                                      loading: !model.balanceInitialized,
                                    ),
                                    BalanceRow(
                                      label: 'Pending',
                                      amount: model.pendingBalance,
                                      ticker: model.ticker,
                                      loading: !model.balanceInitialized,
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
                            SailColumn(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailTextField(
                                  loading: LoadingDetails(
                                    enabled: model.receiveAddress == null,
                                    description: 'Waiting for thunder to boot...',
                                  ),
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
                child: UTXOsTab(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class OverviewTabViewModel extends BaseViewModel with ChangeTrackingMixin {
  @override
  final log = Logger(level: Level.debug);
  TransactionProvider get _transactionsProvider => GetIt.I.get<TransactionProvider>();
  SidechainRPC get _rpc => GetIt.I.get<SidechainRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  AddressProvider get _addressProvider => GetIt.I.get<AddressProvider>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  final labelController = TextEditingController();

  double? sidechainFee;
  String? sendError;
  String? receiveError;
  bool isSending = false;

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
  bool get balanceInitialized => _balanceProvider.initialized;

  String? get receiveAddress => _addressProvider.receiveAddress;

  bool get allConnected => _rpc.connected;

  OverviewTabViewModel() {
    initChangeTracker();
    _initControllers();
    _initFees();
    _transactionsProvider.addListener(_onChange);
    _balanceProvider.addListener(_onChange);
    _addressProvider.addListener(_onChange);
    _rpc.addListener(_onChange);
  }

  void _onChange() {
    track('balance', balance);
    track('pendingBalance', pendingBalance);
    track('transactions', transactions);
    track('receiveAddress', receiveAddress);
    track('allConnected', allConnected);
    track('balanceInitialized', balanceInitialized);
    notifyIfChanged();
  }

  void _initControllers() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(_capAmount);
  }

  Future<void> _initFees() async {
    await Future.wait([estimateSidechainFee()]);
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

    isSending = true;
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
      isSending = false;
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
    _transactionsProvider.removeListener(_onChange);
    _balanceProvider.removeListener(_onChange);
    _addressProvider.removeListener(_onChange);
    super.dispose();
  }
}

class DepositWithdrawHelp extends StatelessWidget {
  ThunderRPC get _rpc => GetIt.I.get<ThunderRPC>();

  const DepositWithdrawHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return QuestionContainer(
      category: 'Deposit & Withdraw help',
      children: [
        const QuestionTitle('What are deposits and withdrawals?'),
        QuestionText(
          'You are currently connected to two blockchains. Bitcoin Core with BIP 300+301, and a sidechain called ${_rpc.chain.name}.',
        ),
        const QuestionText(
          'Deposits and withdrawals move bitcoin from one chain to the other. A deposit adds bitcoin to the sidechain, and a withdrawal removes bitcoin from the sidechain.',
        ),
        const QuestionText(
          'When we use the word deposit or withdraw in this application, we always refer to moving coins across chains.',
        ),
        const QuestionText(
          "Only after you have deposited coins to the sidechain, can you start using it's special features! If you're a developer and know your way around a command line, there's a special rpc called createsidechaindeposit that lets you deposit from your parent chain wallet.",
        ),
      ],
    );
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
          model: model,
          searchWidget: SailTextField(
            controller: model.searchController,
            hintText: 'Enter address or transaction id to search',
          ),
        );
      },
    );
  }
}

class TransactionTable extends StatefulWidget {
  final Widget searchWidget;
  final LatestWalletTransactionsViewModel model;

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

  List<CoreTransaction> get sortedEntries {
    final entries = List<CoreTransaction>.from(widget.model.entries);
    entries.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortColumn) {
        case 'height':
          aValue = a.confirmations;
          bValue = b.confirmations;
          break;
        case 'date':
          aValue = a.time;
          bValue = b.time;
          // If timestamps are equal, use txid as secondary sort
          if (aValue == bValue) {
            return sortAscending ? a.txid.compareTo(b.txid) : b.txid.compareTo(a.txid);
          }
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'amount':
          aValue = a.amount;
          bValue = b.amount;
          break;
        default:
          aValue = a.time;
          bValue = b.time;
      }
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
                  getRowId: (index) => entries[index].txid,
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
                    final entry = entries[row];
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
                  rowCount: entries.length,
                  columnWidths: const [110, 150, 200, 150],
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
                    final utxo = entries.firstWhere(
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
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
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
  final bool loading;

  const BalanceRow({
    super.key,
    required this.label,
    required this.amount,
    required this.ticker,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary15(label),
          SailSkeletonizer(
            enabled: loading,
            description: 'Waiting for thunder to boot...',
            child: SailText.secondary15('${formatBitcoin(amount)} $ticker'),
          ),
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
            model: model,
            searchWidget: SailTextField(
              controller: model.searchController,
              hintText: 'Enter address or transaction id to search',
            ),
          );
        },
      ),
    );
  }
}

class UTXOsTab extends StatelessWidget {
  const UTXOsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<LatestUTXOsViewModel>.reactive(
          viewModelBuilder: () => LatestUTXOsViewModel(),
          builder: (context, model, child) {
            return UTXOTable(
              entries: model.entries,
              model: model,
            );
          },
        );
      },
    );
  }
}

class UTXOTable extends StatefulWidget {
  final List<SidechainUTXO> entries;
  final LatestUTXOsViewModel model;

  const UTXOTable({
    super.key,
    required this.entries,
    required this.model,
  });

  @override
  State<UTXOTable> createState() => _UTXOTableState();
}

class _UTXOTableState extends State<UTXOTable> {
  String sortColumn = 'output';
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    sortEntries();
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
    widget.entries.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortColumn) {
        case 'output':
          aValue = a.outpoint;
          bValue = b.outpoint;
          break;
        case 'address':
          aValue = a.address;
          bValue = b.address;
          break;
        case 'value':
          aValue = a.valueSats;
          bValue = b.valueSats;
          break;
        case 'type':
          aValue = a.type;
          bValue = b.type;
          break;
        default:
          aValue = a.valueSats;
          bValue = b.valueSats;
      }
      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Your UTXOs',
      bottomPadding: false,
      child: Column(
        children: [
          Expanded(
            child: SailSkeletonizer(
              description: 'Waiting for enforcer to start and wallet to sync..',
              enabled: widget.model.loading,
              child: SailTable(
                shrinkWrap: true,
                getRowId: (index) => widget.entries[index].outpoint.split(':').first,
                headerBuilder: (context) => [
                  SailTableHeaderCell(name: 'Type', onSort: () => onSort('type')),
                  SailTableHeaderCell(name: 'Output', onSort: () => onSort('output')),
                  SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
                  SailTableHeaderCell(name: 'Amount', onSort: () => onSort('value')),
                ],
                rowBuilder: (context, row, selected) {
                  final utxo = widget.entries[row];
                  final formattedAmount = formatBitcoin(
                    satoshiToBTC(utxo.valueSats),
                    symbol: '',
                  );
                  return [
                    SailTableCell(value: utxo.type.name, monospace: true),
                    SailTableCell(
                      value: '${utxo.outpoint.substring(0, 6)}..:${utxo.outpoint.split(':').last}',
                      copyValue: utxo.outpoint,
                    ),
                    SailTableCell(value: utxo.address, monospace: true),
                    SailTableCell(value: formattedAmount, monospace: true),
                  ];
                },
                rowCount: widget.entries.length,
                columnWidths: const [120, 120, 320, 120],
                drawGrid: true,
                sortColumnIndex: [
                  'type',
                  'output',
                  'address',
                  'value',
                ].indexOf(sortColumn),
                sortAscending: sortAscending,
                onSort: (columnIndex, ascending) {
                  onSort(['type', 'output', 'address', 'value'][columnIndex]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LatestUTXOsViewModel extends BaseViewModel with ChangeTrackingMixin {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  final EnforcerRPC _enforcerRPC = GetIt.I<EnforcerRPC>();

  List<SidechainUTXO> get entries {
    if (loading) {
      return [
        SidechainUTXO(
          outpoint: 'ef96ff0ab79d3666b7ea55d832bfa36947f0839cdf1708e4f4087cb89d6e0716:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
          type: OutpointType.regular,
        ),
        SidechainUTXO(
          outpoint: 'ef96ff0ab79d3666b7ea55d832bfa36947f0839cdf1708e4f4087cb89d6e0716:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
          type: OutpointType.regular,
        ),
        SidechainUTXO(
          outpoint: 'ef96ff0ab79d3666b7ea55d832bfa36947f0839cdf1708e4f4087cb89d6e0716:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
          type: OutpointType.regular,
        ),
      ];
    }

    return _txProvider.utxos.toList();
  }

  String sortColumn = 'output';
  bool sortAscending = true;

  LatestUTXOsViewModel() {
    initChangeTracker();
    _txProvider.addListener(_onChange);
  }

  void _onChange() {
    track('entries', entries);
    track('loading', loading);
    notifyIfChanged();
  }

  bool get loading => _enforcerRPC.initializingBinary;

  @override
  void dispose() {
    _txProvider.removeListener(_onChange);
    super.dispose();
  }
}
