import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_snackbar.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/providers/transactions_provider.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/tabs/dashboard_tab_widgets.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class DashboardTabPage extends StatelessWidget {
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
          body: Column(
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
                titleTrailing: viewModel.transactions.length.toString(),
                endWidget: SailToggle(label: 'Show raw', value: viewModel.showRaw, onChanged: viewModel.toggleRaw),
                children: [
                  SailColumn(
                    spacing: 0,
                    withDivider: true,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final tx in viewModel.transactions)
                        TxView(
                          showRAW: viewModel.showRaw,
                          tx: tx,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class TxView extends StatefulWidget {
  final bool showRAW;
  final Transaction tx;

  const TxView({super.key, required this.showRAW, required this.tx});

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
              label: 'label',
              value: extractTXTitle(widget.tx),
            ),
          ),
          if (expanded) ExpandedTXView(decodedTX: decodedTx),
        ],
      ),
    );
  }

  String extractTXTitle(Transaction tx) {
    String title = '${tx.category} ${tx.amount.toStringAsFixed(8)} SBTC';

    if (tx.address.isEmpty) {
      return '$title in ${tx.txid}';
    }

    if (tx.amount.isNegative || tx.amount == 0) {
      return '$title to ${tx.address}';
    }

    return '$title from ${tx.address}';
  }
}

class ExpandedTXView extends StatelessWidget {
  final Map<String, dynamic> decodedTX;

  const ExpandedTXView({super.key, required this.decodedTX});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: decodedTX.keys.map((key) {
        return SingleValueView(label: key, value: decodedTX[key]);
      }).toList(),
    );
  }
}

class SingleValueView extends StatelessWidget {
  final String label;
  final dynamic value;
  final Widget? icon;
  final bool copyable;

  const SingleValueView({
    super.key,
    required this.label,
    required this.value,
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
          width: 110,
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
      ],
    );
  }
}

class HomePageViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  TransactionsProvider get _transactionsProvider => GetIt.I.get<TransactionsProvider>();

  String get sidechainBalance => _balanceProvider.balance.toStringAsFixed(8);
  String get sidechainPendingBalance => _balanceProvider.pendingBalance.toStringAsFixed(8);
  List<Transaction> get transactions => _transactionsProvider.transactions;

  bool showRaw = false;

  HomePageViewModel() {
    // by adding a listener, we subscribe to changes to the balance
    // provider. We don't use the updates for anything other than
    // showing the new value though, so we keep it simple, and just
    // pass notifyListeners of this view model directly
    _balanceProvider.addListener(notifyListeners);
    _transactionsProvider.addListener(notifyListeners);
  }

  void toggleRaw(bool value) {
    showRaw = value;
    notifyListeners();
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
  }
}
