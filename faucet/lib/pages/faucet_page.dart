import 'package:auto_route/auto_route.dart';
import 'package:faucet/api/api_base.dart';
import 'package:faucet/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:faucet/gen/faucet/v1/faucet.pb.dart';
import 'package:faucet/gen/google/protobuf/timestamp.pb.dart';
import 'package:faucet/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class FaucetViewModel extends BaseViewModel {
  ClientSettings get _clientSettings => GetIt.I.get<ClientSettings>();
  API get api => GetIt.I.get<API>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();

  final addressController = TextEditingController();
  final amountController = TextEditingController();
  String? dispenseErr;
  bool hideDeposits = true;
  SailThemeValues theme = SailThemeValues.light;

  List<GetTransactionResponse> get claims => _transactionsProvider.claims;

  FaucetViewModel() {
    _init();
    _transactionsProvider.addListener(notifyListeners);
    addressController.addListener(notifyListeners);
    amountController.addListener(_capAmount);
  }

  void _init() async {
    theme = (await _clientSettings.getValue(ThemeSetting())).value;
  }

  final maxAmount = 5;
  void _capAmount() {
    String currentInput = amountController.text;

    if ((double.tryParse(currentInput) != null && double.parse(currentInput) > maxAmount)) {
      amountController.text = maxAmount.toString();
      amountController.selection = TextSelection.fromPosition(TextPosition(offset: amountController.text.length));
    } else {
      notifyListeners();
    }
  }

  void setHideDeposits(bool to) {
    hideDeposits = to;
    notifyListeners();
  }

  Future<String?> claim(BuildContext context) async {
    try {
      dispenseErr = null;
      if (isBusy) {
        return null;
      }
      setBusy(true);

      final amount = double.parse(amountController.text);
      final txid = await api.clients.faucet.dispenseCoins(
        DispenseCoinsRequest(
          destination: addressController.text,
          amount: amount,
        ),
      );

      if (!context.mounted) return '';

      final url = 'https://explorer.drivechain.info/tx/${txid.txid}';
      showSnackBar(
        context,
        '',
        widget: Row(
          children: [
            SailText.primary13('Dispensed $amount BTC in '),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(url)),
                child: SailText.primary13(
                  txid.txid,
                  color: context.sailTheme.colors.info,
                  underline: true,
                ),
              ),
            ),
          ],
        ),
      );

      return txid.txid;
    } catch (error) {
      dispenseErr = error.toString();
    } finally {
      setBusy(false);
      notifyListeners();
    }
    return null;
  }

  Future<void> clearAll() async {
    addressController.clear();
    amountController.clear();
    notifyListeners();
  }

  void onMaxAmount() {
    amountController.text = maxAmount.toString();
    amountController.selection = TextSelection.fromPosition(TextPosition(offset: amountController.text.length));
    notifyListeners();
  }

  @override
  void dispose() {
    _transactionsProvider.removeListener(notifyListeners);
    addressController.removeListener(notifyListeners);
    amountController.removeListener(_capAmount);
    addressController.dispose();
    amountController.dispose();
    super.dispose();
  }
}

@RoutePage()
class FaucetPage extends StatefulWidget {
  const FaucetPage({super.key});

  @override
  State<FaucetPage> createState() => _FaucetPageState();
}

class _FaucetPageState extends State<FaucetPage> {
  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => FaucetViewModel(),
        builder: ((context, model, child) {
          return SailColumn(
            spacing: SailStyleValues.padding16,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SailCard(
                title: 'Dispense Drivechain Coins',
                subtitle: 'Send Drivechain coins to your L1-address',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SailTextField(
                      label: 'Pay To',
                      controller: model.addressController,
                      hintText: 'Enter a L1-address (e.g. 1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L)',
                      size: TextFieldSize.small,
                      suffixWidget: PasteButton(
                        onPaste: (text) {
                          model.addressController.text = text;
                        },
                      ),
                    ),
                    const SizedBox(height: SailStyleValues.padding16),
                    SailRow(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: SailStyleValues.padding08,
                      children: [
                        Expanded(
                          child: NumericField(
                            label: 'Amount',
                            controller: model.amountController,
                            suffixWidget: SailButton(
                              label: 'MAX',
                              variant: ButtonVariant.link,
                              onPressed: () async {
                                model.onMaxAmount();
                              },
                            ),
                            inputFormatters: [
                              CommaReplacerInputFormatter(),
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SailStyleValues.padding16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SailButton(
                              label: 'Send',
                              onPressed: () => model.claim(context),
                              disabled: model.isBusy ||
                                  model.amountController.text == '' ||
                                  model.addressController.text == '',
                            ),
                            const SizedBox(width: SailStyleValues.padding08),
                            SailButton(
                              variant: ButtonVariant.secondary,
                              label: 'Clear All',
                              onPressed: model.clearAll,
                            ),
                          ],
                        ),
                        // Balance
                      ],
                    ),
                    if (model.dispenseErr != null) const SizedBox(height: SailStyleValues.padding16),
                    if (model.dispenseErr != null && model.dispenseErr!.isNotEmpty)
                      SailInfoBox(
                        text: model.dispenseErr!,
                        type: InfoType.error,
                      ),
                  ],
                ),
              ),
              SailCard(
                bottomPadding: false,
                title: 'Latest Transactions',
                subtitle: 'View the latest faucet dispensations',
                child: SizedBox(
                  height: 300,
                  child: LatestTransactionTable(
                    entries: model.claims,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class LatestTransactionTable extends StatefulWidget {
  final List<GetTransactionResponse> entries;

  const LatestTransactionTable({
    super.key,
    required this.entries,
  });

  @override
  State<LatestTransactionTable> createState() => _LatestTransactionTableState();
}

class _LatestTransactionTableState extends State<LatestTransactionTable> {
  String sortColumn = 'time';
  bool sortAscending = false;
  List<GetTransactionResponse> entries = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    entries = widget.entries;
    sortEntries();
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
        case 'amount':
          aValue = a.amount;
          bValue = b.amount;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'confirmations':
          aValue = a.confirmations;
          bValue = b.confirmations;
          break;
        case 'category':
          aValue = a.details.isEmpty ? '' : a.details.first.category;
          bValue = b.details.isEmpty ? '' : b.details.first.category;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  String formatTime(Timestamp timestamp) {
    final dateTime = timestamp.toDateTime().toLocal();
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => entries[index].txid,
      headerBuilder: (context) => [
        SailTableHeaderCell(
          name: 'Time',
          onSort: () => onSort('time'),
        ),
        SailTableHeaderCell(
          name: 'TxID',
          onSort: () => onSort('txid'),
        ),
        SailTableHeaderCell(
          name: 'Amount',
          onSort: () => onSort('amount'),
        ),
        SailTableHeaderCell(
          name: 'Confirmations',
          onSort: () => onSort('confirmations'),
        ),
      ],
      rowBuilder: (context, row, selected) {
        final entry = entries[row];

        final url = 'https://explorer.drivechain.info/tx/${entry.txid}';
        return [
          SailTableCell(value: formatTime(entry.time)),
          SailTableCell(
            value: '',
            copyValue: entry.txid,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(url)),
                child: SailText.primary12(
                  '${entry.txid.substring(0, 10)}...',
                  color: context.sailTheme.colors.info,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          SailTableCell(value: formatBitcoin(entry.amount.toInt())),
          SailTableCell(value: entry.confirmations.toString()),
        ];
      },
      contextMenuItems: (rowId) {
        return [
          MempoolMenuItem(txid: rowId),
        ];
      },
      rowCount: entries.length,
      drawGrid: true,
      sortColumnIndex: ['time', 'amount', 'category', 'confirmations', 'txid'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['time', 'amount', 'category', 'confirmations', 'txid'][columnIndex]);
      },
    );
  }

  @override
  void didUpdateWidget(LatestTransactionTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries != oldWidget.entries) {
      entries = widget.entries;
      sortEntries();
      setState(() {});
    }
  }
}
