import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/wallet/denial_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class DeniabilityTab extends StatelessWidget {
  final SailWindow? newWindowButton;

  const DeniabilityTab({
    super.key,
    required this.newWindowButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<DeniabilityViewModel>.reactive(
          viewModelBuilder: () => DeniabilityViewModel(),
          onViewModelReady: (model) => WidgetsBinding.instance.addPostFrameCallback((_) => model.postInit()),
          builder: (context, model, child) {
            final error = model.error('deniability');

            return SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DenyAllButton(
                        onPressed: () => model.showDenyAllDialog(context),
                        utxoCount: model.utxosWithoutDenial.length,
                      ),
                    ),
                    const SizedBox(width: SailStyleValues.padding16),
                    Expanded(
                      child: ConsolidateButton(
                        onPressed: () => model.showConsolidateDialog(context),
                        utxoCount: model.utxos.length,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: DeniabilityTable(
                    newWindowButton: newWindowButton,
                    error: error,
                    utxos: model.utxos,
                    model: model,
                    onDeny: (output, valueSats) => model.showDenyDialog(context, output, valueSats),
                    onCancel: model.cancelDenial,
                    onPause: model.pauseDenial,
                    onResume: model.resumeDenial,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class DenyAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int utxoCount;

  const DenyAllButton({
    super.key,
    required this.onPressed,
    required this.utxoCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return InkWell(
      onTap: utxoCount > 0 ? onPressed : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: SailStyleValues.borderRadius,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              theme.colors.orange.withValues(alpha: utxoCount > 0 ? 0.25 : 0.1),
              theme.colors.orangeLight.withValues(alpha: utxoCount > 0 ? 0.25 : 0.1),
            ],
          ),
          border: Border.all(
            color: utxoCount > 0 ? theme.colors.orange : theme.colors.divider,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            SailRow(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.icon(
                  SailSVGAsset.iconSend,
                  color: utxoCount > 0 ? theme.colors.text : theme.colors.textTertiary,
                  height: 24,
                ),
                SailText.primary24(
                  'Deny All',
                  bold: true,
                  color: utxoCount > 0 ? null : theme.colors.textTertiary,
                ),
              ],
            ),
            SailText.secondary13(
              utxoCount > 0
                  ? 'Click here to start deniability on all $utxoCount UTXOs'
                  : 'All UTXOs already have active deniability',
              color: theme.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class ConsolidateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int utxoCount;

  const ConsolidateButton({
    super.key,
    required this.onPressed,
    required this.utxoCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final canConsolidate = utxoCount > 1;

    return InkWell(
      onTap: canConsolidate ? onPressed : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: SailStyleValues.borderRadius,
          color: theme.colors.backgroundSecondary,
          border: Border.all(
            color: canConsolidate ? theme.colors.primary : theme.colors.divider,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            SailRow(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.icon(
                  SailSVGAsset.iconReceive,
                  color: canConsolidate ? theme.colors.text : theme.colors.textTertiary,
                  height: 24,
                ),
                SailText.primary24(
                  'Consolidate',
                  bold: true,
                  color: canConsolidate ? null : theme.colors.textTertiary,
                ),
              ],
            ),
            SailText.secondary13(
              canConsolidate
                  ? 'Click here to merge all $utxoCount UTXOs into one'
                  : 'Need more than 1 UTXO to consolidate',
              color: theme.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class DeniabilityTable extends StatefulWidget {
  final SailWindow? newWindowButton;
  final String? error;
  final List<UnspentOutput> utxos;
  final void Function(String output, int valueSats) onDeny;
  final void Function(Int64) onCancel;
  final void Function(Int64) onPause;
  final void Function(Int64) onResume;
  final DeniabilityViewModel model;

  const DeniabilityTable({
    super.key,
    required this.error,
    required this.utxos,
    required this.model,
    required this.onDeny,
    required this.onCancel,
    required this.onPause,
    required this.onResume,
    required this.newWindowButton,
  });

  @override
  State<DeniabilityTable> createState() => _DeniabilityTableState();
}

class _DeniabilityTableState extends State<DeniabilityTable> {
  String sortColumn = 'txid';
  bool sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();

    return SailCard(
      title: 'Your UTXOs with denial info',
      subtitle: 'List of your UTXOs with information about their deniability status.',
      error: widget.error,
      bottomPadding: false,
      newWindow: widget.newWindowButton,
      child: Column(
        children: [
          SailSpacing(SailStyleValues.padding16),
          Expanded(
            child: ListenableBuilder(
              listenable: formatter,
              builder: (context, child) => SailTable(
                getRowId: (index) => widget.utxos.isEmpty
                    ? '0'
                    : '${widget.utxos[index].output}:${widget.utxos[index].denialInfo.executions.length}',
                headerBuilder: (context) => [
                  SailTableHeaderCell(
                    name: 'Denial ID',
                    onSort: () => onSort('id'),
                  ),
                  SailTableHeaderCell(
                    name: 'Hops',
                    onSort: () => onSort('hops'),
                  ),
                  SailTableHeaderCell(
                    name: 'UTXO',
                    onSort: () => onSort('txid'),
                  ),
                  SailTableHeaderCell(
                    name: 'Amount',
                    onSort: () => onSort('amount'),
                  ),
                  SailTableHeaderCell(
                    name: 'Next Execution',
                    onSort: () => onSort('next'),
                  ),
                  SailTableHeaderCell(
                    name: 'Status',
                    onSort: () => onSort('status'),
                  ),
                  SailTableHeaderCell(
                    name: 'Timestamp',
                    onSort: () => onSort('timestamp'),
                  ),
                  const SailTableHeaderCell(name: 'Actions'),
                ],
                cellHeight: 36.0,
                rowBuilder: (context, row, selected) {
                  final utxo = widget.utxos[row];
                  final hasDenialInfo = utxo.hasDenialInfo();

                  String status = '-';
                  String nextExecution = '-';
                  String hops = '0';
                  bool canControl = false;
                  bool isPaused = false;
                  bool isTip = false;

                  if (hasDenialInfo) {
                    final completedHops = utxo.denialInfo.hopsCompleted;
                    final totalHops = utxo.denialInfo.numHops;
                    hops = '$completedHops/$totalHops';
                    if (utxo.denialInfo.nextExecutionTime.toDateTime().second == 0) {
                      hops = '$completedHops';
                    }

                    isPaused = utxo.denialInfo.hasPausedAt();
                    isTip = !utxo.denialInfo.isChange;

                    status = utxo.denialInfo.hasCancelTime()
                        ? 'Cancelled'
                        : isPaused
                        ? 'Paused'
                        : utxo.denialInfo.nextExecutionTime.toDateTime().second == 0
                        ? 'Completed'
                        : 'Ongoing';
                    nextExecution = utxo.denialInfo.hasNextExecutionTime()
                        ? utxo.denialInfo.nextExecutionTime.toDateTime().toLocal().toString()
                        : '-';
                    // Only the tip can be controlled (paused/resumed/cancelled)
                    canControl = isTip && (status == 'Ongoing' || status == 'Paused');

                    if (status == 'Cancelled') {
                      hops = '$completedHops';
                    }
                  }

                  return [
                    SailTableCell(
                      value: '${utxo.denialInfo.id == 0 ? '-' : utxo.denialInfo.id}',
                      copyValue: utxo.denialInfo.id.toString(),
                    ),
                    SailTableCell(
                      value: hops,
                    ),
                    SailTableCell(
                      value: '${utxo.output.substring(0, 6)}..:${utxo.output.split(':').last}',
                      copyValue: utxo.output,
                    ),
                    SailTableCell(
                      value: formatter.formatSats(utxo.valueSats.toInt()),
                      monospace: true,
                    ),
                    SailTableCell(
                      value: nextExecution,
                    ),
                    Tooltip(
                      message: utxo.denialInfo.cancelReason,
                      child: SailTableCell(
                        value: status,
                      ),
                    ),
                    SailTableCell(
                      value: formatDate(utxo.receivedAt.toDateTime()),
                    ),
                    SailTableCell(
                      value: canControl ? (isPaused ? 'Resume' : 'Pause') : 'Deny',
                      child: canControl
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SailButton(
                                  label: isPaused ? 'Resume' : 'Pause',
                                  onPressed: () async => isPaused
                                      ? widget.onResume(utxo.denialInfo.id)
                                      : widget.onPause(utxo.denialInfo.id),
                                  insideTable: true,
                                ),
                                const SizedBox(width: 4),
                                SailButton(
                                  label: 'Cancel',
                                  onPressed: () async => widget.onCancel(utxo.denialInfo.id),
                                  insideTable: true,
                                  variant: ButtonVariant.secondary,
                                ),
                              ],
                            )
                          : SailButton(
                              label: 'Deny',
                              onPressed: () async => widget.onDeny(utxo.output, utxo.valueSats.toInt()),
                              insideTable: true,
                            ),
                    ),
                  ];
                },
                rowCount: widget.utxos.length,
                emptyPlaceholder: 'No UTXOs available',
                drawGrid: true,
                sortColumnIndex: [
                  'id',
                  'txid',
                  'vout',
                  'amount',
                  'next',
                  'status',
                  'actions',
                ].indexOf(sortColumn),
                sortAscending: sortAscending,
                onSort: (columnIndex, ascending) {
                  onSort(['id', 'txid', 'vout', 'amount', 'next', 'status', 'actions'][columnIndex]);
                },
                onDoubleTap: (rowId) {
                  if (widget.utxos.isEmpty) return;
                  final utxo = widget.utxos.firstWhere(
                    (u) => u.output == rowId,
                  );
                  _showUtxoDetails(context, utxo);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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
    widget.utxos.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'id':
          aValue = a.denialInfo.id;
          bValue = b.denialInfo.id;
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);

        case 'txid':
          // Sort by combined txid:vout string
          final aKey = a.output;
          final bKey = b.output;
          return sortAscending ? aKey.compareTo(bKey) : bKey.compareTo(aKey);
        case 'amount':
          return sortAscending ? a.valueSats.compareTo(b.valueSats) : b.valueSats.compareTo(a.valueSats);
        case 'hops':
          if (!a.hasDenialInfo() && !b.hasDenialInfo()) return 0;
          if (!a.hasDenialInfo()) return sortAscending ? 1 : -1;
          if (!b.hasDenialInfo()) return sortAscending ? -1 : 1;
          aValue = a.denialInfo.executions.length;
          bValue = b.denialInfo.executions.length;
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        case 'next':
          if (!a.hasDenialInfo() && !b.hasDenialInfo()) return 0;
          if (!a.hasDenialInfo()) return sortAscending ? 1 : -1;
          if (!b.hasDenialInfo()) return sortAscending ? -1 : 1;
          if (!a.denialInfo.hasNextExecutionTime() && !b.denialInfo.hasNextExecutionTime()) return 0;
          if (!a.denialInfo.hasNextExecutionTime()) return sortAscending ? 1 : -1;
          if (!b.denialInfo.hasNextExecutionTime()) return sortAscending ? -1 : 1;
          return sortAscending
              ? a.denialInfo.nextExecutionTime.toDateTime().compareTo(b.denialInfo.nextExecutionTime.toDateTime())
              : b.denialInfo.nextExecutionTime.toDateTime().compareTo(a.denialInfo.nextExecutionTime.toDateTime());
        case 'status':
          if (!a.hasDenialInfo() && !b.hasDenialInfo()) return 0;
          if (!a.hasDenialInfo()) return sortAscending ? 1 : -1;
          if (!b.hasDenialInfo()) return sortAscending ? -1 : 1;
          aValue = a.denialInfo.hasCancelTime()
              ? 'Cancelled'
              : a.denialInfo.hasPausedAt()
              ? 'Paused'
              : (a.denialInfo.nextExecutionTime.toDateTime().second == 0 ? 'Completed' : 'Ongoing');
          bValue = b.denialInfo.hasCancelTime()
              ? 'Cancelled'
              : b.denialInfo.hasPausedAt()
              ? 'Paused'
              : (b.denialInfo.nextExecutionTime.toDateTime().second == 0 ? 'Completed' : 'Ongoing');
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        default:
          return 0;
      }
    });
  }

  void _showUtxoDetails(BuildContext context, UnspentOutput utxo) {
    final formatter = GetIt.I<FormatterProvider>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'UTXO Details',
            subtitle: 'UTXO and Deniability Information',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'TxID', value: utxo.output.split(':').first),
                  DetailRow(label: 'Output Index', value: utxo.output.split(':').last),
                  DetailRow(label: 'Amount', value: formatter.formatSats(utxo.valueSats.toInt())),
                  if (utxo.hasDenialInfo()) ...[
                    const SailSpacing(SailStyleValues.padding16),
                    BorderedSection(
                      title: 'Deniability Info',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailRow(label: 'Status', value: _getDeniabilityStatus(utxo)),
                          DetailRow(label: 'Completed Hops', value: '${utxo.denialInfo.executions.length}'),
                          DetailRow(label: 'Total Hops', value: '${utxo.denialInfo.numHops}'),
                          if (utxo.denialInfo.hasNextExecutionTime())
                            DetailRow(
                              label: 'Next Execution',
                              value: formatDate(utxo.denialInfo.nextExecutionTime.toDateTime()),
                            ),
                          if (utxo.denialInfo.hasCancelTime())
                            DetailRow(
                              label: 'Cancel Reason',
                              value: utxo.denialInfo.cancelReason,
                            ),
                        ],
                      ),
                    ),
                    if (utxo.denialInfo.executions.isNotEmpty) ...[
                      const SailSpacing(SailStyleValues.padding16),
                      SailText.primary13('Deniability Transactions:'),
                      const SailSpacing(SailStyleValues.padding08),
                      SizedBox(
                        height: 300,
                        child: SelectionContainer.disabled(
                          child: TXIDTransactionTable(
                            transactions: utxo.denialInfo.executions
                                .map((e) => e.fromTxid)
                                .where((txid) => txid.isNotEmpty)
                                .toList(),
                            onTransactionSelected: (txid) => _showTransactionDetails(context, txid),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, String txid) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(
        txid: txid,
      ),
    );
  }

  String _getDeniabilityStatus(UnspentOutput utxo) {
    if (!utxo.hasDenialInfo()) return 'No deniability';
    if (utxo.denialInfo.hasCancelTime()) return 'Cancelled';
    if (utxo.denialInfo.hasPausedAt()) return 'Paused';

    final completedHops = utxo.denialInfo.executions.length;
    final totalHops = utxo.denialInfo.numHops;

    if (utxo.denialInfo.nextExecutionTime.toDateTime().second == 0) return 'Completed';
    return 'Ongoing ($completedHops/$totalHops hops)';
  }
}

class DeniabilityViewModel extends BaseViewModel {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final TransactionProvider transactionProvider = GetIt.I.get<TransactionProvider>();

  List<UnspentOutput> get utxos => transactionProvider.utxos;

  List<UnspentOutput> get utxosWithoutDenial => utxos.where((u) {
    if (!u.hasDenialInfo()) return true;
    // Has denial info but it's cancelled or completed
    if (u.denialInfo.hasCancelTime()) return true;
    if (u.denialInfo.nextExecutionTime.toDateTime().second == 0) return true;
    return false;
  }).toList();

  DeniabilityViewModel() {
    transactionProvider.addListener(notifyListeners);
    transactionProvider.addListener(errorListener);
  }

  void init() {
    // Set busy state to show loading indicator
    setBusy(true);
  }

  // Post-frame initialization for async operations
  Future<void> postInit() async {
    await transactionProvider.fetch();
  }

  void errorListener() {
    setErrorForObject('deniability', transactionProvider.error);
  }

  void showDenyDialog(BuildContext context, String output, int valueSats) {
    showDialog(
      context: context,
      builder: (context) => DenialDialog(output: output, valueSats: valueSats),
    );
  }

  void showDenyAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DenialDialog(utxos: utxosWithoutDenial),
    );
  }

  void showConsolidateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConsolidateDialog(utxos: utxos),
    );
  }

  void cancelDenial(Int64 id) async {
    try {
      await api.bitwindowd.cancelDenial(id);
      await transactionProvider.fetch();
    } catch (e) {
      setError(e.toString());
    }
  }

  void pauseDenial(Int64 id) async {
    try {
      await api.bitwindowd.pauseDenial(id);
      await transactionProvider.fetch();
    } catch (e) {
      setError(e.toString());
    }
  }

  void resumeDenial(Int64 id) async {
    try {
      await api.bitwindowd.resumeDenial(id);
      await transactionProvider.fetch();
    } catch (e) {
      setError(e.toString());
    }
  }
}
