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
  final NewWindowIdentifier? newWindowIdentifier;

  const DeniabilityTab({
    super.key,
    required this.newWindowIdentifier,
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

            return DeniabilityTable(
              newWindowIdentifier: newWindowIdentifier,
              error: error,
              utxos: model.utxos,
              onDeny: (output) => model.showDenyDialog(context, output),
              onCancel: model.cancelDenial,
            );
          },
        );
      },
    );
  }
}

class DeniabilityTable extends StatefulWidget {
  final NewWindowIdentifier? newWindowIdentifier;
  final String? error;
  final List<UnspentOutput> utxos;
  final void Function(String output) onDeny;
  final void Function(Int64) onCancel;

  const DeniabilityTable({
    super.key,
    required this.error,
    required this.utxos,
    required this.onDeny,
    required this.onCancel,
    required this.newWindowIdentifier,
  });

  @override
  State<DeniabilityTable> createState() => _DeniabilityTableState();
}

class _DeniabilityTableState extends State<DeniabilityTable> {
  String sortColumn = 'txid';
  bool sortAscending = true;

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
          if (!a.denialInfo.hasNextExecution() && !b.denialInfo.hasNextExecution()) return 0;
          if (!a.denialInfo.hasNextExecution()) return sortAscending ? 1 : -1;
          if (!b.denialInfo.hasNextExecution()) return sortAscending ? -1 : 1;
          return sortAscending
              ? a.denialInfo.nextExecution.toDateTime().compareTo(b.denialInfo.nextExecution.toDateTime())
              : b.denialInfo.nextExecution.toDateTime().compareTo(a.denialInfo.nextExecution.toDateTime());
        case 'status':
          if (!a.hasDenialInfo() && !b.hasDenialInfo()) return 0;
          if (!a.hasDenialInfo()) return sortAscending ? 1 : -1;
          if (!b.hasDenialInfo()) return sortAscending ? -1 : 1;
          aValue = a.denialInfo.hasCancelTime()
              ? 'Cancelled'
              : (a.denialInfo.nextExecution.toDateTime().second == 0 ? 'Completed' : 'Ongoing');
          bValue = b.denialInfo.hasCancelTime()
              ? 'Cancelled'
              : (b.denialInfo.nextExecution.toDateTime().second == 0 ? 'Completed' : 'Ongoing');
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        default:
          return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'UTXOs and Denials',
      subtitle: 'List of your UTXOs with information about their deniability status.',
      error: widget.error,
      bottomPadding: false,
      inSeparateWindow: widget.newWindowIdentifier == null,
      newWindowIdentifier: widget.newWindowIdentifier,
      child: Column(
        children: [
          SailSpacing(SailStyleValues.padding16),
          Expanded(
            child: SailTable(
              getRowId: (index) => widget.utxos.isEmpty
                  ? '0'
                  : '${widget.utxos[index].output}:${widget.utxos[index].denialInfo.executions.length}',
              headerBuilder: (context) => [
                SailTableHeaderCell(
                  name: 'UTXO',
                  onSort: () => onSort('txid'),
                ),
                SailTableHeaderCell(
                  name: 'Amount',
                  onSort: () => onSort('amount'),
                ),
                SailTableHeaderCell(
                  name: 'Hops',
                  onSort: () => onSort('hops'),
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
                // If there are no UTXOs, return a single row with an empty cell message
                if (widget.utxos.isEmpty) {
                  return [
                    const SailTableCell(value: 'No UTXOs available'),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                  ];
                }

                final utxo = widget.utxos[row];
                final hasDenialInfo = utxo.hasDenialInfo();

                String status = '-';
                String nextExecution = '-';
                String hops = '0';
                bool canCancel = false;

                if (hasDenialInfo) {
                  final completedHops = utxo.denialInfo.executions.length;
                  final totalHops = utxo.denialInfo.numHops;
                  hops = '$completedHops/$totalHops';
                  if (utxo.denialInfo.nextExecution.toDateTime().second == 0) {
                    hops = '$completedHops';
                  }

                  status = utxo.denialInfo.hasCancelTime()
                      ? 'Cancelled'
                      : utxo.denialInfo.nextExecution.toDateTime().second == 0
                          ? 'Completed'
                          : 'Ongoing';
                  nextExecution = utxo.denialInfo.hasNextExecution()
                      ? utxo.denialInfo.nextExecution.toDateTime().toLocal().toString()
                      : '-';
                  canCancel = status == 'Ongoing';

                  if (status == 'Cancelled') {
                    hops = '$completedHops';
                  }
                }

                return [
                  SailTableCell(
                    value: '${utxo.output.substring(0, 6)}..:${utxo.output.split(':').last}',
                    copyValue: utxo.output,
                  ),
                  SailTableCell(
                    value: formatBitcoin(satoshiToBTC(utxo.valueSats.toInt())),
                    monospace: true,
                  ),
                  SailTableCell(
                    value: hops,
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
                    value: canCancel ? 'Cancel' : '-',
                    child: canCancel
                        ? SailButton(
                            label: 'Cancel',
                            onPressed: () async => widget.onCancel(utxo.denialInfo.id),
                          )
                        : SailButton(
                            label: 'Deny',
                            onPressed: () async => widget.onDeny(utxo.output),
                          ),
                  ),
                ];
              },
              rowCount: widget.utxos.isEmpty ? 1 : widget.utxos.length, // Show one row when empty
              drawGrid: true,
              sortColumnIndex: [
                'txid',
                'vout',
                'amount',
                'next',
                'status',
                'actions',
              ].indexOf(sortColumn),
              sortAscending: sortAscending,
              onSort: (columnIndex, ascending) {
                onSort(['txid', 'vout', 'amount', 'next', 'status', 'actions'][columnIndex]);
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showUtxoDetails(BuildContext context, UnspentOutput utxo) {
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
                  DetailRow(label: 'Amount', value: formatBitcoin(satoshiToBTC(utxo.valueSats.toInt()))),
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
                          if (utxo.denialInfo.hasNextExecution())
                            DetailRow(
                              label: 'Next Execution',
                              value: formatDate(utxo.denialInfo.nextExecution.toDateTime()),
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

    final completedHops = utxo.denialInfo.executions.length;
    final totalHops = utxo.denialInfo.numHops;

    if (utxo.denialInfo.nextExecution.toDateTime().second == 0) return 'Completed';
    return 'Ongoing ($completedHops/$totalHops hops)';
  }
}

class DeniabilityViewModel extends BaseViewModel {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final TransactionProvider transactionProvider = GetIt.I.get<TransactionProvider>();

  List<UnspentOutput> get utxos => transactionProvider.utxos;

  DeniabilityViewModel() {
    transactionProvider.addListener(notifyListeners);
    transactionProvider.addListener(errorListener);
  }

  void init() {
    // Set busy state to show loading indicator
    setBusy(true);
    notifyListeners();
  }

  // Post-frame initialization for async operations
  Future<void> postInit() async {
    try {
      // Fetch data
      await transactionProvider.fetch();
    } catch (e) {
      setErrorForObject('deniability', e.toString());
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void errorListener() {
    setErrorForObject('deniability', transactionProvider.error);
  }

  void showDenyDialog(BuildContext context, String output) {
    showDialog(
      context: context,
      builder: (context) => DenialDialog(output: output),
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
}
