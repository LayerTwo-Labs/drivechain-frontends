import 'dart:convert';

import 'package:faucet/api/api.dart';
import 'package:faucet/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:faucet/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/theme/theme_data.dart';
import 'package:sail_ui/widgets/components/dashboard_group.dart';
import 'package:sail_ui/widgets/core/sail_padding.dart';
import 'package:sail_ui/widgets/core/sail_snackbar.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
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

  Widget themeIcon(SailThemeData? currentTheme) {
    SailSVGAsset icon;
    if (theme == SailThemeValues.system) {
      if (currentTheme == null || currentTheme.name == 'light') {
        // what, default to sun
        icon = SailSVGAsset.iconLightMode;
      } else {
        icon = SailSVGAsset.iconDarkMode;
      }
    } else if (theme == SailThemeValues.light) {
      icon = SailSVGAsset.iconLightMode;
    } else {
      icon = SailSVGAsset.iconDarkMode;
    }

    return SailSVG.fromAsset(icon);
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

  void setTheme(SailThemeValues newTheme) async {
    theme = newTheme;
    await _clientSettings.setValue(ThemeSetting().withValue(theme));
    notifyListeners();
  }

  void setHideDeposits(bool to) {
    hideDeposits = to;
    notifyListeners();
  }

  Future<String?> claim() async {
    try {
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
    final app = SailApp.of(context);
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
        viewModelBuilder: () => FaucetViewModel(),
        builder: ((context, viewModel, child) {
          return Scaffold(
            backgroundColor: theme.colors.background,
            appBar: AppBar(
              backgroundColor: theme.colors.background,
              title: SailText.primary22(widget.title),
              actions: [
                SailScaleButton(
                    onPressed: () {
                      SailThemeValues nextTheme = viewModel.theme.toggleTheme();
                      viewModel.setTheme(nextTheme);
                      app.loadTheme(nextTheme);
                    },
                    child: Tooltip(
                        message: 'Current theme: ${viewModel.theme.toReadable()}',
                        child: SailPadding(
                            padding: const EdgeInsets.only(
                              right: SailStyleValues.padding10,
                            ),
                            child: viewModel.themeIcon(app.theme)))),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SailStyleValues.padding10, vertical: SailStyleValues.padding10),
                      child: SailColumn(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: SailStyleValues.padding10,
                          children: <Widget>[
                            TextField(
                              controller: viewModel.addressController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: theme.colors.text.withOpacity(0.3),
                                )),
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
                              controller: viewModel.amountController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: theme.colors.text.withOpacity(0.3),
                                )),
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
                              viewModel.addressController.text == ""
                                  ? "Insert address first"
                                  : viewModel.amountController.text == ""
                                      ? "Choose amount first"
                                      : "Dispense Drivechain Coins",
                              onPressed: () async {
                                final txid = await viewModel.claim();
                                if (txid != null) {
                                  if (!context.mounted) {
                                    return;
                                  }
                                  showSnackBar(context, 'Sent in txid=$txid');
                                  viewModel._transactionsProvider.fetch();
                                }
                              },
                              size: ButtonSize.large,
                              disabled: viewModel.isBusy ||
                                  viewModel.amountController.text == "" ||
                                  viewModel.addressController.text == "",
                              loading: viewModel.isBusy,
                            ),
                            SailText.primary13(viewModel.dispenseErr ?? '', color: SailColorScheme.red),
                          ])),
                  DashboardGroup(
                    title: 'Latest Transactions',
                    widgetTrailing: SailText.secondary13(viewModel.utxos.length.toString()),
                    children: [
                      SailColumn(
                        spacing: 0,
                        withDivider: true,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: viewModel.utxos.length,
                            itemBuilder: (context, index) => UTXOView(
                              key: ValueKey<String>(viewModel.utxos[index].txid),
                              utxo: transactionResponseToUTXO(viewModel.utxos[index]),
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
        }));
  }
}

UTXO transactionResponseToUTXO(GetTransactionResponse response) {
  // Extract details, assuming first detail is the relevant one.
  var detail = response.details.isNotEmpty ? response.details[0] : null;

  return UTXO(
    txid: response.txid,
    vout: detail?.vout ?? 0,
    address: detail?.address ?? '',
    account: '', // Not available in GetTransactionResponse, set empty
    redeemScript: '', // Not available in GetTransactionResponse, set empty
    scriptPubKey: '', // Not available in GetTransactionResponse, set empty
    amount: response.amount,
    confirmations: response.confirmations,
    spendable: false,
    solvable: false,
    safe: true, // Default to true, or adjust based on other data
    time: response.time.seconds.toInt(),
    raw: jsonEncode(response.toProto3Json()), // Convert to raw JSON
  );
}
