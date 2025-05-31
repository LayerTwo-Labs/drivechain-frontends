import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:zside/pages/tabs/home_page.dart';
import 'package:zside/pages/tabs/sidechain_overview_page.dart';
import 'package:zside/pages/tabs/zcash/zcash_transfer_page.dart';
import 'package:zside/providers/zcash_provider.dart';
import 'package:zside/routing/router.dart';
import 'package:zside/widgets/containers/tabs/zcash_tab_widgets.dart';

@RoutePage()
class ZCashOperationStatusesTabPage extends StatelessWidget {
  AppRouter get router => GetIt.I.get<AppRouter>();

  const ZCashOperationStatusesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => OperationStatusesiewModel(),
      builder: ((context, model, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return SailPage(
          scrollable: true,
          widgetTitle: ZCashWidgetTitle(
            depositNudgeAction: () => tabsRouter.setActiveIndex(Tabs.ParentChainPeg.index),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: SailStyleValues.padding32),
            child: SailColumn(
              spacing: SailStyleValues.padding32,
              children: [
                SailCard(
                  title: 'Operation statuses',
                  subtitle: 'List of zero-knowledge operations and their status',
                  bottomPadding: false,
                  widgetHeaderEnd: SailRow(
                    spacing: SailStyleValues.padding12,
                    children: [
                      SailButton(
                        label: 'Clear',
                        variant: ButtonVariant.ghost,
                        onPressed: () => model.clear(),
                      ),
                      HelpButton(onPressed: () async => model.operationHelp(context)),
                    ],
                  ),
                  child: SizedBox(
                    height: 300,
                    child: SailTable(
                      getRowId: (index) => model.operations[index].id,
                      headerBuilder: (context) => const [
                        SailTableHeaderCell(name: 'Date'),
                        SailTableHeaderCell(name: 'Method'),
                        SailTableHeaderCell(name: 'Status'),
                        SailTableHeaderCell(name: 'Operation ID'),
                      ],
                      rowBuilder: (context, row, selected) {
                        final operation = model.operations[row];

                        return [
                          SailTableCell(
                            value: DateFormat('dd MMM HH:mm:ss').format(operation.creationTime),
                            monospace: true,
                          ),
                          SailTableCell(
                            value: operation.method,
                            monospace: true,
                          ),
                          SailTableCell(
                            value: operation.status,
                            textColor: operation.status == 'success' ? SailColorScheme.green : SailColorScheme.red,
                            monospace: true,
                            child: operation.status == 'success'
                                ? Tooltip(
                                    message: 'Success',
                                    child: SailSVG.icon(SailSVGAsset.iconSuccess, width: 13),
                                  )
                                : Tooltip(
                                    message: 'Failed',
                                    child: SailSVG.icon(SailSVGAsset.iconFailed, width: 13),
                                  ),
                          ),
                          SailTableCell(
                            value: operation.id,
                            monospace: true,
                          ),
                        ];
                      },
                      rowCount: model.operations.length,
                      columnWidths: const [150, 100, 100, 200],
                      drawGrid: true,
                      onDoubleTap: (rowId) {
                        final operation = model.operations.firstWhere((op) => op.id == rowId);

                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: SailCard(
                                title: 'Operation Details',
                                subtitle: 'Details of the selected operation',
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      DetailRow(label: 'Operation ID', value: operation.id),
                                      DetailRow(label: 'Method', value: operation.method),
                                      DetailRow(label: 'Status', value: operation.status),
                                      DetailRow(
                                        label: 'Creation Time',
                                        value: DateFormat('dd MMM HH:mm:ss').format(operation.creationTime),
                                      ),
                                      DetailRow(
                                        label: 'Raw Data',
                                        value: const JsonEncoder.withIndent('  ').convert(operation.raw),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SailCard(
                    title: 'Transparent transactions',
                    subtitle: '${model.transactions.length} transactions',
                    child: Column(
                      children: [
                        SailSpacing(SailStyleValues.padding16),
                        Expanded(
                          child: SailTable(
                            getRowId: (index) => model.transactions[index].txid,
                            headerBuilder: (context) => [
                              const SailTableHeaderCell(name: 'Transaction ID'),
                              const SailTableHeaderCell(name: 'Amount'),
                              const SailTableHeaderCell(name: 'Type'),
                              const SailTableHeaderCell(name: 'Time'),
                            ],
                            rowBuilder: (context, row, selected) {
                              final tx = model.transactions[row];
                              return [
                                SailTableCell(
                                  value: tx.txid,
                                  monospace: true,
                                ),
                                SailTableCell(
                                  value: formatBitcoin(satoshiToBTC(tx.amount.toInt()), symbol: model.chain.ticker),
                                  monospace: true,
                                ),
                                SailTableCell(
                                  value: tx.category,
                                  monospace: true,
                                ),
                                SailTableCell(
                                  value: tx.time.toLocal().toString(),
                                  monospace: true,
                                ),
                              ];
                            },
                            rowCount: model.transactions.length,
                            columnWidths: const [-1, -1, -1, -1],
                            drawGrid: true,
                            onDoubleTap: (rowId) {
                              final tx = model.transactions.firstWhere(
                                (tx) => tx.txid == rowId,
                              );
                              _showTransactionDetails(context, tx, model.chain);
                            },
                            contextMenuItems: (rowId) {
                              final tx = model.transactions.firstWhere(
                                (tx) => tx.txid == rowId,
                              );
                              return [
                                SailMenuItem(
                                  onSelected: () {
                                    _showTransactionDetails(context, tx, model.chain);
                                  },
                                  child: SailText.primary12('Show Details'),
                                ),
                                MempoolMenuItem(txid: tx.txid),
                              ];
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showTransactionDetails(BuildContext context, CoreTransaction tx, Binary chain) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'Transaction Details',
            subtitle: tx.txid,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'Transaction ID', value: tx.txid),
                  DetailRow(
                    label: 'Amount',
                    value: formatBitcoin(tx.amount, symbol: chain.ticker),
                  ),
                  DetailRow(label: 'Type', value: tx.category),
                  DetailRow(label: 'Time', value: tx.time.toLocal().toString()),
                  DetailRow(label: 'Confirmations', value: tx.confirmations.toString()),
                  DetailRow(
                    label: 'Fee',
                    value: formatBitcoin(tx.fee, symbol: chain.ticker),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OperationStatusesiewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  ZCashProvider get _zcashProvider => GetIt.I.get<ZCashProvider>();
  ZCashRPC get _rpc => GetIt.I.get<ZCashRPC>();

  List<OperationStatus> get operations => _zcashProvider.operations.reversed.toList();
  List<CoreTransaction> get transactions => _zcashProvider.transparentTransactions;
  Binary get chain => _rpc.chain;

  OperationStatusesiewModel() {
    _zcashProvider.addListener(notifyListeners);
  }

  Future<void> clear() async {
    _zcashProvider.operations = List.empty();
    notifyListeners();
  }

  void operationHelp(BuildContext context) async {
    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return const OperationHelp();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _zcashProvider.removeListener(notifyListeners);
  }
}
