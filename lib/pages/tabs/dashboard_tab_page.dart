import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_snackbar.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/routing/router.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class DashboardTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const DashboardTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomePageViewModel(),
      builder: ((context, viewModel, child) {
        return SailPage(
          title: '',
          widgetTitle: Row(
            children: [
              SailText.primary13(
                'Balance: ${viewModel.sidechainBalance} SBTC',
                bold: true,
              ),
              Expanded(child: Container()),
              SailText.primary13(
                'Unconfirmed balance: ${viewModel.sidechainPendingBalance} SBTC',
                bold: true,
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: SailStyleValues.padding30),
                  child: Column(
                    children: [
                      DashboardGroup(
                        title: 'Actions',
                        children: [
                          ActionTile(
                            title: 'Peg-out to mainchain',
                            category: Category.mainchain,
                            icon: Icons.remove,
                            onTap: () {
                              viewModel.pegOut(context);
                            },
                          ),
                          ActionTile(
                            title: 'Peg-in from mainchain',
                            category: Category.mainchain,
                            icon: Icons.add,
                            onTap: () {
                              viewModel.pegIn(context);
                            },
                          ),
                          ActionTile(
                            title: 'Send on sidechain',
                            category: Category.sidechain,
                            icon: Icons.remove,
                            onTap: () {
                              viewModel.send(context);
                            },
                          ),
                          ActionTile(
                            title: 'Receive on sidechain',
                            category: Category.sidechain,
                            icon: Icons.add,
                            onTap: () {
                              viewModel.receive(context);
                            },
                          ),
                        ],
                      ),
                      const SailSpacing(SailStyleValues.padding30),
                      DashboardGroup(
                        title: 'Transactions',
                        widgetTrailing: SailText.secondary13(viewModel.transactions.length.toString()),
                        children: [
                          SailColumn(
                            spacing: 0,
                            withDivider: true,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final tx in viewModel.transactions)
                                TxView(
                                  tx: tx,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: DashboardNodeConnection(
                  onChipPressed: () async {
                    // TODO
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class DashboardNodeConnection extends ViewModelWidget<HomePageViewModel> {
  final VoidCallback onChipPressed;

  const DashboardNodeConnection({super.key, required this.onChipPressed});

  @override
  Widget build(BuildContext context, HomePageViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding20),
      child: SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          if (viewModel.sidechainConnected)
            const ConnectionSuccessChip(chain: 'sidechain')
          else
            ConnectionErrorChip(
              chain: 'sidechain',
              onPressed: onChipPressed,
            ),
          if (viewModel.mainchainConnected)
            const ConnectionSuccessChip(chain: 'mainchain')
          else
            ConnectionErrorChip(
              chain: 'mainchain',
              onPressed: onChipPressed,
            ),
        ],
      ),
    );
  }
}

class TxView extends StatefulWidget {
  final Transaction tx;

  const TxView({super.key, required this.tx});

  @override
  State<TxView> createState() => _TxViewState();
}

class _TxViewState extends State<TxView> {
  bool expanded = false;
  late Map<String, dynamic> decodedTx;
  @override
  void initState() {
    super.initState();
    decodedTx = jsonDecode(widget.tx.raw);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SailStyleValues.padding15,
        horizontal: SailStyleValues.padding10,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailScaleButton(
            onPressed: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: SingleValueView(
              width: expanded ? 95 : 70,
              icon: widget.tx.confirmations >= 1
                  ? Tooltip(
                      message: '${widget.tx.confirmations} confirmations',
                      child: SailSVG.icon(SailSVGAsset.iconConfirmed, width: 13),
                    )
                  : Tooltip(
                      message: 'Unconfirmed',
                      child: SailSVG.icon(SailSVGAsset.iconPending, width: 13),
                    ),
              copyable: false,
              label: widget.tx.category,
              value: extractTXTitle(widget.tx),
              trailingText: DateFormat('dd MMM HH:mm').format(widget.tx.time),
            ),
          ),
          if (expanded)
            ExpandedTXView(
              decodedTX: decodedTx,
              width: 95,
            ),
        ],
      ),
    );
  }

  String extractTXTitle(Transaction tx) {
    String title = '${tx.amount.toStringAsFixed(8)} SBTC';

    if (tx.address.isEmpty) {
      return '$title in ${tx.txid}';
    }

    if (tx.amount.isNegative || tx.amount == 0) {
      return '$title to ${tx.address}';
    }

    return '+$title from ${tx.address}';
  }
}

class ExpandedTXView extends StatelessWidget {
  final Map<String, dynamic> decodedTX;
  final double width;

  const ExpandedTXView({
    super.key,
    required this.decodedTX,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: decodedTX.keys.where((key) => key != 'walletconflicts').map((key) {
        return SingleValueView(
          label: key,
          value: decodedTX[key],
          width: width,
        );
      }).toList(),
    );
  }
}

class SingleValueView extends StatelessWidget {
  final String label;
  final dynamic value;
  final double width;
  final String? trailingText;
  final Widget? icon;
  final bool copyable;

  const SingleValueView({
    super.key,
    required this.label,
    required this.value,
    required this.width,
    this.trailingText,
    this.icon,
    this.copyable = true,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        if (icon != null)
          icon!
        else
          const SizedBox(
            width: 13,
          ),
        SizedBox(
          width: width,
          child: SailText.secondary12(label),
        ),
        SailScaleButton(
          onPressed: copyable
              ? () {
                  Clipboard.setData(ClipboardData(text: value.toString()));
                  showSnackBar(context, 'Copied $label');
                }
              : null,
          child: SailText.primary12(value.toString()),
        ),
        Expanded(child: Container()),
        if (trailingText != null) SailText.secondary12(trailingText!),
      ],
    );
  }
}

class HomePageViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  SidechainRPC get _sideRPC => GetIt.I.get<SidechainRPC>();
  MainchainRPC get _mainRPC => GetIt.I.get<MainchainRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();

  bool get sidechainConnected => _sideRPC.connected;
  bool get mainchainConnected => _mainRPC.connected;

  String get sidechainBalance => _balanceProvider.balance.toStringAsFixed(8);
  String get sidechainPendingBalance => _balanceProvider.pendingBalance.toStringAsFixed(8);

  List<Transaction> get transactions => _transactionsProvider.transactions;

  HomePageViewModel() {
    // by adding a listener, we subscribe to changes to the balance
    // provider. We don't use the updates for anything other than
    // showing the new value though, so we keep it simple, and just
    // pass notifyListeners of this view model directly
    _balanceProvider.addListener(notifyListeners);
    _transactionsProvider.addListener(notifyListeners);
    _sideRPC.addListener(notifyListeners);
    _mainRPC.addListener(notifyListeners);
  }

  void pegOut(BuildContext context) async {
    final theme = SailTheme.of(context);

    await showDialog(
      context: context,
      barrierColor: theme.colors.background.withOpacity(0.4),
      builder: (BuildContext context) {
        return const PegOutAction();
      },
    );
  }

  void pegIn(BuildContext context) async {
    final theme = SailTheme.of(context);
    await showDialog(
      context: context,
      barrierColor: theme.colors.background.withOpacity(0.4),
      builder: (BuildContext context) {
        return const PegInAction();
      },
    );
  }

  void send(BuildContext context) async {
    final theme = SailTheme.of(context);
    await showDialog(
      context: context,
      barrierColor: theme.colors.background.withOpacity(0.4),
      builder: (BuildContext context) {
        return const SendOnSidechainAction();
      },
    );
  }

  void receive(BuildContext context) async {
    final theme = SailTheme.of(context);
    await showDialog(
      context: context,
      barrierColor: theme.colors.background.withOpacity(0.4),
      builder: (BuildContext context) {
        return const ReceiveOnSidechainAction();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _balanceProvider.removeListener(notifyListeners);
    _transactionsProvider.removeListener(notifyListeners);
    _sideRPC.removeListener(notifyListeners);
    _mainRPC.removeListener(notifyListeners);
  }
}
