import 'dart:convert';

import 'package:faucet_client/api/api.dart';
import 'package:faucet_client/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:faucet_client/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class FaucetViewModel extends BaseViewModel {
  ClientSettings get _clientSettings => GetIt.I.get<ClientSettings>();
  API get api => GetIt.I.get<API>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();

  final addressController = TextEditingController();
  final amountController = TextEditingController();
  String? dispenseErr;
  bool hideDeposits = true;
  SailThemeValues theme = SailThemeValues.light;

  List<GetTransactionResponse> get utxos => _transactionsProvider.claims;

  FaucetViewModel() {
    _init();
    _transactionsProvider.addListener(notifyListeners);
    addressController.addListener(notifyListeners);
    amountController.addListener(_capAmount);
  }

  void _init() async {
    theme = (await _clientSettings.getValue(ThemeSetting())).value;
  }

  void _capAmount() {
    const maxAmount = 1;
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

  Future<String?> claim() async {
    try {
      dispenseErr = null;
      if (isBusy) {
        return null;
      }
      setBusy(true);

      final amount = double.parse(amountController.text);
      final txid = await api.claim(addressController.text, amount);
      return txid;
    } catch (error) {
      dispenseErr = error.toString();
    } finally {
      setBusy(false);
      notifyListeners();
    }
    return null;
  }
}

class FaucetPage extends StatefulWidget {
  const FaucetPage({super.key, required this.title});

  final String title;

  @override
  State<FaucetPage> createState() => _FaucetPageState();
}

class _FaucetPageState extends State<FaucetPage> {
  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => FaucetViewModel(),
      builder: ((context, model, child) {
        return Scaffold(
          backgroundColor: theme.colors.background,
          appBar: AppBar(
            backgroundColor: theme.colors.background,
            title: SailText.primary22(widget.title),
            actions: const [
              ToggleThemeButton(),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SailStyleValues.padding10,
                    vertical: SailStyleValues.padding10,
                  ),
                  child: SailColumn(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: SailStyleValues.padding10,
                    children: <Widget>[
                      TextField(
                        controller: model.addressController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colors.text.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colors.text.withOpacity(0.6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.colors.text.withOpacity(0.9)), // Set focused border color
                          ),
                          labelText: 'Enter address',
                          focusColor: theme.colors.text,
                        ),
                        cursorColor: theme.colors.primary,
                        style: TextStyle(color: theme.colors.text),
                      ),
                      TextField(
                        controller: model.amountController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colors.text.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colors.text.withOpacity(0.6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.colors.text.withOpacity(0.9)), // Set focused border color
                          ),
                          labelText: 'Enter amount (max 1 BTC)',
                          focusColor: theme.colors.text,
                        ),
                        cursorColor: theme.colors.primary,
                        style: TextStyle(
                          color: theme.colors.text,
                        ),
                        inputFormatters: [
                          CommaReplacerInputFormatter(),
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
                        ],
                      ),
                      SailButton.primary(
                        model.addressController.text == ''
                            ? 'Insert address first'
                            : model.amountController.text == ''
                                ? 'Choose amount first'
                                : 'Dispense Drivechain Coins',
                        onPressed: () async {
                          final txid = await model.claim();
                          if (txid != null) {
                            if (!context.mounted) {
                              return;
                            }
                            showSnackBar(context, 'Sent in txid=$txid');
                            await model._transactionsProvider.fetch();
                          }
                        },
                        size: ButtonSize.large,
                        disabled:
                            model.isBusy || model.amountController.text == '' || model.addressController.text == '',
                        loading: model.isBusy,
                      ),
                      SailText.primary13(model.dispenseErr ?? '', color: SailColorScheme.red),
                    ],
                  ),
                ),
                DashboardGroup(
                  title: 'Latest Transactions',
                  widgetTrailing: SailText.secondary13(model.utxos.length.toString()),
                  children: [
                    SailColumn(
                      spacing: 0,
                      withDivider: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: model.utxos.length,
                          itemBuilder: (context, index) => CoreTransactionView(
                            key: ValueKey<String>(model.utxos[index].txid),
                            tx: transactionResponseToUTXO(model.utxos[index]),
                            ticker: 'BTC',
                            externalDirection: true,
                          ),
                        ),
                      ],
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

CoreTransaction transactionResponseToUTXO(GetTransactionResponse response) {
  // Extract details, assuming first detail is the relevant one.
  var detail = response.details.isNotEmpty ? response.details[0] : null;

  return CoreTransaction(
    txid: response.txid,
    vout: detail?.vout ?? 0,
    address: detail?.address ?? '',
    category: extractNameFromEnum(
      detail?.category.name ?? '',
    ),
    amount: detail?.amount ?? 0,
    fee: detail?.fee ?? 0,
    confirmations: response.confirmations,
    blockhash: response.blockHash,
    blockindex: response.blockIndex,
    blocktime: response.blockTime.seconds.toInt(),
    time: DateTime.fromMillisecondsSinceEpoch(response.time.seconds.toInt() * 1000),
    timereceived: DateTime.fromMillisecondsSinceEpoch(response.timeReceived.seconds.toInt() * 1000),
    bip125Replaceable: extractNameFromEnum(response.bip125Replaceable.name),
    raw: jsonEncode(response.toProto3Json()), // Convert to raw JSON

    label: '', // Not available in GetTransactionResponse
    abandoned: false, // Not available in GetTransactionResponse
    comment: '', // Not available in GetTransactionResponse
    trusted: false, // Not available in GetTransactionResponse
  );
}

String extractNameFromEnum(String enumName) {
  return enumName.split('_').last;
}
