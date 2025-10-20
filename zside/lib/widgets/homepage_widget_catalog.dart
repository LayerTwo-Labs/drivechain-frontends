import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/providers/transactions_provider.dart';

class ZSideWidgetCatalog {
  static final Map<String, HomepageWidgetInfo> _widgets = {
    'balance_card': HomepageWidgetInfo(
      id: 'balance_card',
      name: 'Balance Card',
      description: 'Shows ZSide balance',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconWallet,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          final formatter = GetIt.I<FormatterProvider>();

          return ListenableBuilder(
            listenable: formatter,
            builder: (context, child) => SizedBox(
              height: 200,
              child: SailCard(
                title: 'Balance',
                child: SailColumn(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary24(
                      '${formatter.formatBTC(model.totalBalance)} ${model.ticker}',
                      bold: true,
                    ),
                    const SizedBox(height: 4),
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
          );
        },
      ),
    ),

    'transparent_receive_card': HomepageWidgetInfo(
      id: 'transparent_receive_card',
      name: 'Receive Transparent',
      description: 'Shows transparent receive address',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconReceive,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 150,
            child: SailCard(
              title: 'Receive - Transparent Address',
              error: model.receiveError,
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: SailTextField(
                      controller: TextEditingController(text: model.transparentReceiveAddress),
                      hintText: 'Generating transparent address...',
                      readOnly: true,
                      suffixWidget: model.isGeneratingTransparentAddress
                          ? const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: LoadingIndicator(),
                              ),
                            )
                          : CopyButton(
                              text: model.transparentReceiveAddress ?? '',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'shielded_receive_card': HomepageWidgetInfo(
      id: 'shielded_receive_card',
      name: 'Receive Private',
      description: 'Shows shielded receive address',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconReceive,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 150,
            child: SailCard(
              title: 'Receive - Private Address',
              error: model.shieldedReceiveError,
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  Expanded(
                    child: SailTextField(
                      controller: TextEditingController(text: model.shieldedReceiveAddress),
                      hintText: 'Generating private address...',
                      readOnly: true,
                      suffixWidget: model.isGeneratingShieldedAddress
                          ? const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: LoadingIndicator(),
                              ),
                            )
                          : CopyButton(
                              text: model.shieldedReceiveAddress ?? '',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'send_card': HomepageWidgetInfo(
      id: 'send_card',
      name: 'Send Card',
      description: 'Send ZSide',
      size: WidgetSize.half,
      icon: SailSVGAsset.iconSend,
      builder: (_) => ViewModelBuilder<OverviewTabViewModel>.reactive(
        viewModelBuilder: () => OverviewTabViewModel(),
        builder: (context, model, child) {
          return SizedBox(
            height: 300,
            child: SailCard(
              title: 'Send on Sidechain',
              error: model.sendError,
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                children: [
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SailText.secondary15('Pay to'),
                      if (model.addressType.isNotEmpty) ...[
                        SailText.secondary13(
                          '(${model.addressType})',
                          color: model.isShieldedAddress
                              ? SailTheme.of(context).colors.success
                              : SailTheme.of(context).colors.info,
                        ),
                      ],
                    ],
                  ),
                  SailTextField(
                    controller: model.bitcoinAddressController,
                    hintText: 'Enter a transparent or private address',
                  ),
                  NumericField(
                    label: 'Amount',
                    controller: model.bitcoinAmountController,
                    hintText: '0.00',
                  ),
                  SailButton(
                    label: model.isShieldedAddress ? 'Send Private' : 'Send Transparent',
                    onPressed: () async => model.executeSendOnSidechain(context),
                    loading: model.isSending,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),

    'transactions_table': HomepageWidgetInfo(
      id: 'transactions_table',
      name: 'Transaction History',
      description: 'Shows transaction history',
      size: WidgetSize.full,
      icon: SailSVGAsset.iconTransactions,
      builder: (_) => SizedBox(
        height: 400,
        child: const TransactionsTab(),
      ),
    ),
  };

  static Map<String, HomepageWidgetInfo> getCatalogMap() {
    return Map.from(_widgets);
  }
}

// ViewModel and widget components moved from sidechain_overview_page.dart

class OverviewTabViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();
  ZSideRPC get _rpc => GetIt.I.get<ZSideRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  final bitcoinAddressController = TextEditingController();
  final bitcoinAmountController = TextEditingController();
  final labelController = TextEditingController();

  // Address type detection
  bool _isValidBitcoinAddress(String address) {
    if (address.isEmpty) return false;

    // Bitcoin/transparent addresses typically:
    // - Start with 1, 3, bc1, tb1, or t (for testnet transparent)
    // - Have specific length ranges (25-62 for base58, up to 90 for bech32)
    // - Use base58 or bech32 character sets

    final validPrefixes = ['1', '3', 'bc1', 'tb1', 't'];
    final hasValidPrefix = validPrefixes.any((prefix) => address.startsWith(prefix));

    if (!hasValidPrefix) return false;

    // Reasonable length check for Bitcoin addresses
    if (address.length < 25 || address.length > 90) return false;

    // Check for valid base58 or bech32 characters
    final base58Regex = RegExp(r'^[123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]+$');
    final bech32Regex = RegExp(r'^[a-z0-9]+$');

    return base58Regex.hasMatch(address) || bech32Regex.hasMatch(address);
  }

  bool get isShieldedAddress {
    final address = bitcoinAddressController.text.trim();
    // If it looks like a valid Bitcoin/transparent address, it's transparent
    // Otherwise assume it's shielded/private
    return !_isValidBitcoinAddress(address) && address.isNotEmpty;
  }

  String get addressType {
    if (bitcoinAddressController.text.trim().isEmpty) return '';
    return isShieldedAddress ? 'Private' : 'Transparent';
  }

  String? transparentReceiveAddress;
  String? shieldedReceiveAddress;
  double? sidechainFee;
  String? sendError;
  String? receiveError;
  String? shieldedReceiveError;

  // Properties for sending
  double? get sendAmount => double.tryParse(bitcoinAmountController.text);
  double? get maxAmount => max(_balanceProvider.balance - (sidechainFee ?? 0), 0);
  String get ticker => _rpc.chain.ticker;
  String get sidechainName => _rpc.chain.name;
  List<CoreTransaction> get transactions => _transactionsProvider.sidechainTransactions;

  String get totalBitcoinAmount {
    final formatter = GetIt.I<FormatterProvider>();
    return '${formatter.formatBTC((double.tryParse(bitcoinAmountController.text) ?? 0) + (sidechainFee ?? 0))} $ticker';
  }

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;
  double get totalBalance => balance + pendingBalance;

  bool isSending = false;
  bool isGeneratingTransparentAddress = false;
  bool isGeneratingShieldedAddress = false;

  OverviewTabViewModel() {
    _initControllers();
    _initFees();
    _transactionsProvider.addListener(ensureAddress);
    _balanceProvider.addListener(ensureAddress);
    _rpc.addListener(_onRpcConnectionChanged);
    generateTransparentAddress();
    generateShieldedAddress();
  }

  void _onRpcConnectionChanged() {
    // When RPC connection status changes, try to generate addresses if they're missing
    if (_rpc.connected) {
      if (transparentReceiveAddress == null && !isGeneratingTransparentAddress) {
        generateTransparentAddress();
      }
      if (shieldedReceiveAddress == null && !isGeneratingShieldedAddress) {
        generateShieldedAddress();
      }
    }
  }

  void _initControllers() {
    bitcoinAddressController.addListener(notifyListeners);
    bitcoinAmountController.addListener(_capAmount);
  }

  Future<void> _initFees() async {
    await Future.wait([estimateSidechainFee()]);
  }

  void ensureAddress() {
    if (transparentReceiveAddress == null) {
      generateTransparentAddress();
    }
    if (shieldedReceiveAddress == null) {
      generateShieldedAddress();
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

  Future<void> generateTransparentAddress() async {
    try {
      isGeneratingTransparentAddress = true;
      receiveError = null;
      notifyListeners();

      // Check if RPC is connected before attempting to generate address
      if (!_rpc.connected) {
        log.d('RPC not connected yet, waiting for connection...');
        receiveError = 'Waiting for ZSide connection...';
        transparentReceiveAddress = null;
        return;
      }

      transparentReceiveAddress = await _rpc.getNewTransparentAddress();
      receiveError = null;
    } catch (error) {
      log.e('Failed to generate transparent address', error: error);
      receiveError = error.toString();
      transparentReceiveAddress = null;
    } finally {
      isGeneratingTransparentAddress = false;
      notifyListeners();
    }
  }

  Future<void> generateShieldedAddress() async {
    try {
      isGeneratingShieldedAddress = true;
      shieldedReceiveError = null;
      notifyListeners();

      // Check if RPC is connected before attempting to generate address
      if (!_rpc.connected) {
        log.d('RPC not connected yet, waiting for connection...');
        shieldedReceiveError = 'Waiting for ZSide connection...';
        shieldedReceiveAddress = null;
        return;
      }

      shieldedReceiveAddress = await _rpc.getNewShieldedAddress();
      shieldedReceiveError = null;
    } catch (error) {
      log.e('Failed to generate shielded address', error: error);
      shieldedReceiveError = error.toString();
      shieldedReceiveAddress = null;
    } finally {
      isGeneratingShieldedAddress = false;
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
    final isShielded = isShieldedAddress;
    final transferType = isShielded ? 'shielded' : 'transparent';
    log.i('doing sidechain $transferType transfer: $amount $ticker to $address with $sidechainFee SC fee');

    try {
      final String sendTXID;

      if (isShielded) {
        // Use shielded transfer for private addresses
        sendTXID = await _rpc.sendShielded(
          address,
          btcToSatoshi(amount).toDouble(),
          btcToSatoshi(sidechainFee ?? 0.00001).toDouble(),
        );
      } else {
        // Use transparent transfer for transparent addresses
        sendTXID = await _rpc.sendTransparent(
          address,
          btcToSatoshi(amount).toDouble(),
          btcToSatoshi(sidechainFee ?? 0.00001).toDouble(),
        );
      }

      unawaited(_balanceProvider.fetch());
      unawaited(_transactionsProvider.fetch());

      return sendTXID;
    } catch (error) {
      log.e('Could not execute $transferType transfer', error: error);
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
    _rpc.removeListener(_onRpcConnectionChanged);
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
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => LayoutBuilder(
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
                      final amount = formatter.formatBTC(satoshiToBTC(entry.amount.toInt()));

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
      ),
    );
  }

  void _showUtxoDetails(BuildContext context, CoreTransaction utxo) {
    final formatter = GetIt.I<FormatterProvider>();
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
                  DetailRow(label: 'Amount', value: formatter.formatBTC(satoshiToBTC(utxo.amount.toInt()))),
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
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SailText.secondary15(label),
            SailText.secondary15('${formatter.formatBTC(amount)} $ticker'),
          ],
        ),
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
