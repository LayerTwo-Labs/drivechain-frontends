import 'package:faucet/api/api.dart';
import 'package:faucet/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/theme/theme_data.dart';
import 'package:sail_ui/widgets/components/dashboard_group.dart';
import 'package:sail_ui/widgets/core/sail_snackbar.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:stacked/stacked.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange),
        child: MaterialApp(
          title: 'Drivechain Faucet',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const FaucetPage(title: 'Drivechain Faucet'),
        ));
  }
}

class FaucetViewModel extends BaseViewModel {
  API get api => GetIt.I.get<API>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();

  final addressController = TextEditingController();
  final amountController = TextEditingController();
  String? dispenseErr;

  List<UTXO> get utxos => _transactionsProvider.claims;

  FaucetViewModel() {
    _transactionsProvider.addListener(notifyListeners);
    addressController.addListener(notifyListeners);
    amountController.addListener(_capAmount);
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
      dispenseErr = "could not dispense coins: ${error.toString()}";
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
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => FaucetViewModel(),
        builder: ((context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(widget.title),
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
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Enter address',
                              ),
                            ),
                            TextField(
                              controller: viewModel.amountController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Enter amount (max 1 BTC)',
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
                            SailText.background13(viewModel.dispenseErr ?? '', customColor: SailColorScheme.red),
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
                              utxo: viewModel.utxos[index],
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
